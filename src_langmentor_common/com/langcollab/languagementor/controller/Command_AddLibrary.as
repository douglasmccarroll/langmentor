/*
    Copyright 2018 Brightworks, Inc.

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
import com.brightworks.util.Utils_String;
import com.brightworks.util.Utils_System;
import com.brightworks.util.Utils_URL;
import com.brightworks.util.download.FileDownloader;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.model.MainModelDBOperationReport;
import com.langcollab.languagementor.vo.LibraryVO;

import flash.events.TimerEvent;
import flash.system.Security;

public class Command_AddLibrary extends Command_Base__LangMentor {
   private static const _STATUS__CONFIRMING_INTERNET_ACCESS:String = "status_ConfirmingInternetAccess";
   private static const _STATUS__CONFIRMING_LIBRARY_XML_FILE_EXISTS:String = "status_ConfirmingLibraryXMLFileExists";
   private static const _STATUS__FAILURE__NO_INTERNET_ACCESS:String = "status_Failure_NoInternetAccess";
   private static const _STATUS__FAILURE__LIBRARY_ALREADY_IN_DB:String = "status_Failure_LibraryAlreadyInDB";
   private static const _STATUS__FAILURE__LIBRARY_FILE_DOES_NOT_EXIST:String = "status_Failure_LibraryFileDoesNotExist";
   private static const _STATUS__FAILURE__SAVE_TO_DB_FAILED:String = "status_Failure_SaveToDBFailed";
   private static const _STATUS__SAVING_TO_DB:String = "status_SavingToDB";
   private static const _STATUS__SUCCESS:String = "status_Success";
   private static const _TIMER_TIMEOUT_MS:uint = 10000;

   private var _isDisposed:Boolean = false;
   private var _languageMentorInfoFileDownloader:FileDownloader;
   private var _libraryFileDownloader:FileDownloader;
   private var _libraryUrl:String;
   private var _status:String;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function Command_AddLibrary(libraryUrl:String, callbacks:Callbacks) {
      super();
      Log.debug("Command_AddLibrary - Constructor");
      _libraryUrl = libraryUrl;
      this.callbacks = callbacks;
   }

   override public function dispose():void {
      Log.debug("Command_AddLibrary.dispose()");
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      model = null;
   }

   public function execute():void {
      Log.info("Command_AddLibrary.execute()");
      _libraryUrl = Utils_String.ensureStringEndsWith(_libraryUrl, "/");
      var tempUrl:String = _libraryUrl;
      if (Utils_System.isRunningOnDesktop())
         tempUrl = Utils_URL.convertUrlToDesktopServerUrl(tempUrl);
      if (model.isLibraryWithLibraryURLExists(_libraryUrl)) {
         _status = _STATUS__FAILURE__LIBRARY_ALREADY_IN_DB;
         var errorReport:Command_AddLibraryErrorReport = new Command_AddLibraryErrorReport();
         errorReport.errorType = Command_AddLibraryErrorReport.ERROR_TYPE__LIBRARY_ALREADY_IN_DB;
         fault(errorReport);
         dispose();
      }
      else {
         Security.loadPolicyFile(tempUrl + Constant_LangMentor_Misc.FILEPATHINFO__DOWNLOAD_PERMISSION_FILE_NAME); /// Not used? No such files?
         _status = _STATUS__CONFIRMING_LIBRARY_XML_FILE_EXISTS;
         _libraryFileDownloader = new FileDownloader();
         _libraryFileDownloader.downloadFolderURL = tempUrl;
         _libraryFileDownloader.downloadFileName = Constant_LangMentor_Misc.FILEPATHINFO__LANGUAGE_MENTOR_LIBRARY_FILE_NAME;
         _libraryFileDownloader.downloadFileExtension = "xml";
         _libraryFileDownloader.addEventListener(BwEvent.COMPLETE, onConfirmLibraryXMLFileExistsComplete);
         _libraryFileDownloader.addEventListener(BwEvent.FAILURE, onConfirmLibraryXMLFileExistsFailure);
         Log.info("Command_AddLibrary.execute(): starting _libraryFileDownloader - " + _libraryFileDownloader.fullFileURL);
         _libraryFileDownloader.start();
         startOrRestartTimeoutTimer(_TIMER_TIMEOUT_MS, onTimeoutTimerComplete);
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function onConfirmInternetAccessComplete(o:Object = null):void {
      Log.debug("Command_AddLibrary.onConfirmInternetAccessComplete()");
      stopTimeoutTimer();
      model.downloadBandwidthRecorder.reportFileDownloader(_languageMentorInfoFileDownloader);
      // We've failed to find the library file, but we have access to the Internet...
      _status = _STATUS__FAILURE__LIBRARY_FILE_DOES_NOT_EXIST;
      var errorReport:Command_AddLibraryErrorReport = new Command_AddLibraryErrorReport();
      errorReport.errorType = Command_AddLibraryErrorReport.ERROR_TYPE__CANNOT_FIND_LIBRARY;
      fault(errorReport);
      dispose();
   }

   private function onConfirmInternetAccessFailure(o:Object = null):void {
      Log.info("Command_AddLibrary.onConfirmInternetAccessFailure()");
      stopTimeoutTimer();
      model.downloadBandwidthRecorder.reportFileDownloader(_languageMentorInfoFileDownloader);
      _status = _STATUS__FAILURE__NO_INTERNET_ACCESS;
      var errorReport:Command_AddLibraryErrorReport = new Command_AddLibraryErrorReport();
      errorReport.errorType = Command_AddLibraryErrorReport.ERROR_TYPE__UNABLE_TO_ACCESS_INTERNET;
      fault(errorReport);
      dispose();
   }

   private function onConfirmLibraryXMLFileExistsComplete(o:Object = null):void {
      //// Confirm that library has folders for target lang and/or native/target pair
      Log.debug("Command_AddLibrary.onConfirmLibraryXMLFileExistsComplete()");
      stopTimeoutTimer();
      model.downloadBandwidthRecorder.reportFileDownloader(_libraryFileDownloader);
      _status = _STATUS__SAVING_TO_DB;
      var libraryVO:LibraryVO = new LibraryVO();
      libraryVO.libraryFolderURL = _libraryUrl;
      libraryVO.enabled = true;
      var modelReport:MainModelDBOperationReport = model.insertVO(libraryVO);
      if (modelReport.isAnyProblems) {
         Log.info(["Command_AddLibrary.onConfirmLibraryXMLFileExistsComplete(): DB insert problem", modelReport]);
         _status = _STATUS__FAILURE__SAVE_TO_DB_FAILED;
         var errorReport:Command_AddLibraryErrorReport = new Command_AddLibraryErrorReport();
         errorReport.errorType = Command_AddLibraryErrorReport.ERROR_TYPE__SAVE_TO_DB_FAILED;
         errorReport.mainModelDBOperationReport = modelReport;
         fault(errorReport);
      }
      else {
         Log.debug("Command_AddLibrary.onConfirmLibraryXMLFileExistsComplete(): DB insert success");
         _status = _STATUS__SUCCESS;
         modelReport.dispose();
         result();
      }
      dispose();
   }


   private function onConfirmLibraryXMLFileExistsFailure(o:Object = null):void {
      Log.info("Command_AddLibrary.onConfirmLibraryXMLFileExistsFailure()");
      stopTimeoutTimer();
      model.downloadBandwidthRecorder.reportFileDownloader(_libraryFileDownloader);
      _status = _STATUS__CONFIRMING_INTERNET_ACCESS;
      // See if we have Internet access
      var folderUrl:String = model.getURL_RootInfoFolder();
      _languageMentorInfoFileDownloader = new FileDownloader();
      _languageMentorInfoFileDownloader.downloadFolderURL = folderUrl;
      _languageMentorInfoFileDownloader.downloadFileName = Constant_LangMentor_Misc.FILEPATHINFO__LANGUAGE_MENTOR_ROOT_CONFIG_FILE_NAME;
      _languageMentorInfoFileDownloader.downloadFileExtension = "xml";
      _languageMentorInfoFileDownloader.addEventListener(BwEvent.COMPLETE, onConfirmInternetAccessComplete);
      _languageMentorInfoFileDownloader.addEventListener(BwEvent.FAILURE, onConfirmInternetAccessFailure);
      _languageMentorInfoFileDownloader.start();
      startOrRestartTimeoutTimer(_TIMER_TIMEOUT_MS, onTimeoutTimerComplete);
   }

   private function onTimeoutTimerComplete(event:TimerEvent):void {
      if (_isDisposed)
         return;
      Log.info("Command_AddLibrary.onTimeoutTimerComplete()");
      var errorReport:Command_AddLibraryErrorReport = new Command_AddLibraryErrorReport();
      errorReport.errorType = Command_AddLibraryErrorReport.ERROR_TYPE__TIMEOUT;
      errorReport.commandStatusAtTimeOfFailure = _status;
      fault(errorReport);
      dispose();
   }

}
}


















