/*
Copyright 2008 - 2013 Brightworks, Inc.

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
package com.langcollab.languagementor.controller.lessondownload {
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Dispose;

public class DownloadLessonProcessesInfo implements IDisposable {
   private var _isDisposed:Boolean = false;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private var _downloadProcessInfoList:Array = [];

   public function get downloadProcessInfoList():Vector.<DownloadLessonProcessInfo> {
      var result:Vector.<DownloadLessonProcessInfo> = new Vector.<DownloadLessonProcessInfo>();
      for each (var downloadProcessInfo:DownloadLessonProcessInfo in _downloadProcessInfoList) {
         result.push(downloadProcessInfo);
      }
      return result;
   }

   public function get length():uint {
      var result:uint = 0;
      for each (var downloadProcessInfo:DownloadLessonProcessInfo in _downloadProcessInfoList) {
         result++;
      }
      return result;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function DownloadLessonProcessesInfo() {
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (_downloadProcessInfoList) {
         // No dispose() method - we store these (for successful downloads) in LessonDownloadController's successfulDownloadInfoList... props for the duration of the session
         /*for each (var downloadProcessInfo:DownloadLessonProcessInfo in _downloadProcessInfoList)
         {
             downloadProcessInfo.dispose();
         }*/
         Utils_Dispose.disposeArray(_downloadProcessInfoList, false);
         _downloadProcessInfoList = null;
      }
   }

   public function addDownloadProcessInfo(downloadProcessInfo:DownloadLessonProcessInfo):void {
      if ((!(downloadProcessInfo.contentProviderId)) || (!(downloadProcessInfo.downloadFileNameBody)) || (!(downloadProcessInfo.downloadFileNameExtension)) || (!(downloadProcessInfo.nativeLanguageContentProviderName)) || (!(downloadProcessInfo.nativeLanguageLibraryName)) || (!(downloadProcessInfo.publishedLessonVersionId)) || (!(downloadProcessInfo.publishedLessonVersionVersion)) || (!(downloadProcessInfo.libraryId)) || (!(downloadProcessInfo.saveFolderFilePath))) {
         Log.warn("DownloadLessonProcessesInfo.addDownloadProcessInfo(): downloadProcessInfo arg not fully populated.");
         return;
      }
      if (getDownloadProcessInfo(downloadProcessInfo.contentProviderId, downloadProcessInfo.publishedLessonVersionId) != null) {
         Log.warn("DownloadLessonProcessesInfo.addDownloadProcessInfo(): A DownloadLessonProcessInfo instance with the same contentProviderId and publishedLessonVersionId has already been added. Duplicate values aren't allowed.");
         return;
      }
      _downloadProcessInfoList.push(downloadProcessInfo);
   }

   public function getDownloadProcessInfo(contentProviderId:String, publishedLessonVersionId:String):DownloadLessonProcessInfo {
      var result:DownloadLessonProcessInfo;
      for each (var downloadProcessInfo:DownloadLessonProcessInfo in _downloadProcessInfoList) {
         if ((downloadProcessInfo.contentProviderId == contentProviderId) && (downloadProcessInfo.publishedLessonVersionId == publishedLessonVersionId)) {
            result = downloadProcessInfo;
            break;
         }
      }
      return result;
   }

}
}
