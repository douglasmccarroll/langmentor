/*
    Copyright 2021 Brightworks, Inc.

    This file is part of Language Mentor.

    Language Mentor is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Language Mentor is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Language Mentor.  If not, see <http://www.gnu.org/licenses/>.
*/
package com.langcollab.languagementor.controller {
import com.brightworks.base.Callbacks;
import com.brightworks.event.BwEvent;
import com.brightworks.util.Log;
import com.brightworks.constant.Constant_AppConfiguration;
import com.langcollab.languagementor.controller.lessondownload.DownloadLessonProcess;
import com.langcollab.languagementor.controller.lessondownload.DownloadLessonProcessInfo;
import com.langcollab.languagementor.controller.lessondownload.DownloadLessonProcessTechReport;
import com.langcollab.languagementor.controller.lessondownload.DownloadLessonProcessesInfo;
import com.langcollab.languagementor.controller.lessondownload.LessonDownloadController;

import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;

public class Command_DownloadLessons extends Command_Base__LangMentor {
   private static const _MILLISECONDS_IN_MINUTE:Number = 60000;

   public var techReport:Command_DownloadLessonsTechReport;

   private var _currActiveDownloadLessonProcess:DownloadLessonProcess;
   private var _downloadLessonProcessesInfo:DownloadLessonProcessesInfo;
   private var _downloadLessonProcessStack:Vector.<DownloadLessonProcess> = new Vector.<DownloadLessonProcess>();
   private var _isDisposed:Boolean = false;
   private var _startDownloadProcessTimer:Timer;

   // --------------------------------------------
   //
   //           Public Methods
   //
   // --------------------------------------------

   public function Command_DownloadLessons(downloadLessonProcessesInfo:DownloadLessonProcessesInfo, callbacks:Callbacks) {
      super();
      Log.debug("Command_DownloadLessons - Constructor");
      _downloadLessonProcessesInfo = downloadLessonProcessesInfo;
      this.callbacks = callbacks;
   }

   public function abort():void {
      dispose();
   }

   override public function dispose():void {
      Log.debug("Command_DownloadLessons.dispose()");
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      stopStartDownloadProcessTimer();
      if (_currActiveDownloadLessonProcess)
         _currActiveDownloadLessonProcess.dispose();
      if (_downloadLessonProcessesInfo) {
         _downloadLessonProcessesInfo.dispose();
         _downloadLessonProcessesInfo = null;
      }
      model = null;
      // techReport is disposed of by client code, after it has used the data therein.
      techReport = null;
   }

   public function execute():void {
      Log.info("Command_DownloadLessons.execute() - create/start download process manager");
      if (_isDisposed)
         return;
      techReport = new Command_DownloadLessonsTechReport();
      techReport.downloadProcessCount_Started = _downloadLessonProcessesInfo.downloadProcessInfoList.length;
      // We want the easiest lessons to download first
      var tempSortList:ArrayCollection = new ArrayCollection();
      var sort:Sort = new Sort();
      sort.fields = [
         new SortField("levelLocationInLevelsOrder", false, false, true),
         new SortField("nativeLanguageLessonSortName", false, false, false)];
      tempSortList.sort = sort;
      tempSortList.refresh();
      for each (var downloadLessonProcessInfo:DownloadLessonProcessInfo in _downloadLessonProcessesInfo.downloadProcessInfoList) {
         tempSortList.addItem(downloadLessonProcessInfo);
      }
      for each (downloadLessonProcessInfo in tempSortList) {
         var dlp:DownloadLessonProcess = new DownloadLessonProcess();
         dlp.downloadLessonProcessInfo = downloadLessonProcessInfo;
         dlp.currentLessons = currentLessons;
         dlp.addEventListener(BwEvent.COMPLETE, onDownloadLessonProcessCompleteEvent);
         dlp.addEventListener(BwEvent.FAILURE, onDownloadLessonProcessFailedEvent);
         _downloadLessonProcessStack.push(dlp);
      }
      if (_downloadLessonProcessStack.length > 0)
         startDownloadProcess();
   }

   // --------------------------------------------
   //
   //           Private Methods
   //
   // --------------------------------------------

   private function onDownloadLessonProcessCompleteEvent(event:BwEvent):void {
      Log.debug("Command_DownloadLessons.onDownloadLessonProcessCompleteEvent()");
      if (_isDisposed)
         return;
      techReport.techReportList_DownloadProcessSuccesses.push(DownloadLessonProcessTechReport(event.techReport));
      model.downloadBandwidthRecorder.reportDownloadedByteCount(DownloadLessonProcessTechReport(event.techReport).zipFileSizeInBytes);
      techReport.downloadProcessCount_Succeeded++;
      onDownloadLessonProcessCompleteOrFailedEvent();
   }

   private function onDownloadLessonProcessCompleteOrFailedEvent():void {
      Log.debug("Command_DownloadLessons.onDownloadCompleteOrFailedEvent()");
      _currActiveDownloadLessonProcess.dispose();
      if (_downloadLessonProcessStack.length == 0) {
         Log.info("Command_DownloadLessons.onDownloadCompleteOrFailedEvent() - all DownloadLessonProcesses complete or failed");
         techReport.isAllDownloadProcessesSucceededOrFailed = true;
         result(techReport);
         dispose();
      }
      else {
         // In this class the result callback functions as an 'update' callback, i.e. we call it repeatedly
         result(techReport);
         startDownloadProcess();
      }
   }

   private function onDownloadLessonProcessFailedEvent(event:BwEvent):void {
      if (_isDisposed)
         return;
      var dmp:DownloadLessonProcess = DownloadLessonProcess(event.target);
      techReport.techReportList_DownloadProcessFailures.push(DownloadLessonProcessTechReport(event.techReport));
      techReport.downloadProcessCount_Failed++;
      if (DownloadLessonProcessTechReport(event.techReport).zipFileSizeInBytes > 0)
         model.downloadBandwidthRecorder.reportDownloadedByteCount(DownloadLessonProcessTechReport(event.techReport).zipFileSizeInBytes);
      else
         model.downloadBandwidthRecorder.reportDownloadedByteCount(1000000); // Conservative estimate - would be well over 50 chunks in a lesson this size.
      // dmccarroll 20120704
      // Encountering this when I 'delete all data' while a download is in progress
      onDownloadLessonProcessCompleteOrFailedEvent();
   }

   private function startDownloadProcess(event:TimerEvent = null):void {
      if (_isDisposed)
         return;
      stopStartDownloadProcessTimer();
      var bytesDownloadedInPreviousTimePeriod:Number =
            model.downloadBandwidthRecorder.getBytesDownloadedInPreviousMilliseconds(_MILLISECONDS_IN_MINUTE * Constant_AppConfiguration.BANDWIDTH_LIMITING__TIME_PERIOD_IN_MINUTES);
      var bytesAllowed:int = LessonDownloadController.bandwidthThrottling_BytesAllowedPerTimePeriod;
      if (bytesDownloadedInPreviousTimePeriod > bytesAllowed) {
         startStartDownloadProcessTimer();
      }
      else {
         _currActiveDownloadLessonProcess = _downloadLessonProcessStack.shift();
         _currActiveDownloadLessonProcess.start();
      }
   }

   private function startStartDownloadProcessTimer():void {
      _startDownloadProcessTimer = new Timer(30000, 1);
      _startDownloadProcessTimer.addEventListener(TimerEvent.TIMER, startDownloadProcess);
      _startDownloadProcessTimer.start();
   }

   private function stopStartDownloadProcessTimer():void {
      if (_startDownloadProcessTimer) {
         _startDownloadProcessTimer.stop();
         _startDownloadProcessTimer.removeEventListener(TimerEvent.TIMER, startDownloadProcess);
         _startDownloadProcessTimer = null;
      }
   }

}
}


