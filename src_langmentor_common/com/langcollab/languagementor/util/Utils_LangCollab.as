/*
    Copyright 2020 Brightworks, Inc.

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
package com.langcollab.languagementor.util {
import com.brightworks.util.Log;
import com.brightworks.util.Utils_AIR;
import com.brightworks.util.Utils_File;
import com.brightworks.util.Utils_System;
import com.brightworks.util.audio.MP3FileInfo;
import com.brightworks.constant.Constant_AppConfiguration;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.controller.audio.AudioController;
import com.langcollab.languagementor.controller.lessondownload.LessonDownloadController;
import com.langcollab.languagementor.model.MainModel;
import com.langcollab.languagementor.model.appstatepersistence.AppStatePersistenceManager;

import flash.filesystem.File;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;

public class Utils_LangCollab {

   // ****************************************************
   //
   //          Getters / Setters
   //
   // ****************************************************

   public static function get appVersion():String {
      var result:String = Utils_AIR.appVersionLabel;
      if (Utils_System.isAlphaOrBetaVersion())
         result += " " + Constant_AppConfiguration.APP_RELEASE_TYPE;
      return result;
   }

   public static function get downloadedLessonsDirectoryURL():String {
      return Utils_AIR.applicationStorageDirectory + File.separator + Constant_LangMentor_Misc.FILEPATHINFO__DOCUMENT_STORAGE_FOLDER_NAME + File.separator + Constant_LangMentor_Misc.FILEPATHINFO__DOWNLOADED_LESSONS_FOLDER_NAME;
   }

   public static function get sqLiteDatabaseFileDirectoryURL():String {
      return Utils_AIR.applicationStorageDirectory + File.separator + Constant_LangMentor_Misc.FILEPATHINFO__DB_FOLDER_NAME;
   }

   public static function get sqLiteDatabaseFileURL():String {
      return sqLiteDatabaseFileDirectoryURL + File.separator + Constant_LangMentor_Misc.FILEPATHINFO__DB_FILE_FILE_NAME;
   }

   public static function get tempAudioFileDirectoryURL():String {
      return Utils_AIR.applicationStorageDirectory + File.separator + Constant_LangMentor_Misc.FILEPATHINFO__TEMP_AUDIO_FOLDER_NAME;
   }

   public static function get tempAudioFileURL():String {
      return tempAudioFileDirectoryURL + File.separator + Constant_LangMentor_Misc.FILEPATHINFO__TEMP_AUDIO_FILE_FILE_NAME;
   }

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public static function appendLogInfoToLogSummaryString(s:String):String {
      s += appVersion + "\n";
      s += "played chunks: " + MainModel.getInstance().chunksCount_PlayedInSession + "\n";
      s += "bandwidth time period: " + Constant_AppConfiguration.BANDWIDTH_LIMITING__TIME_PERIOD_IN_MINUTES + "m" + "\n";
      s += "bandwidth MB allowed: " + LessonDownloadController.bandwidthThrottling_BytesAllowedPerTimePeriod / (1024 * 1024) + "\n";
      return s;
   }

   /**
    * param fileInfo A dictionary with one property for each chunk file in the lesson version,
    *                where the value for each property is the length of the file in milliseconds.
    * returns A string that is created by concatenating the last 3 digits of all file lengths.
    */
   public static function computeLessonVersionSignature(lessonVersionId:String, fileInfo:Dictionary):String {
      var result:String = lessonVersionId + "_";
      var iFileCount:int = 0;
      var sFileId:String;
      var sFileLength:String;
      var sFileSignature:String;
      // We can't count on the properties of a Dict always being accessed in same order, so we take the preliminary step
      // of sorting the info by sFileId - this will ensure that a given lesson version will always have the same signature
      var tempArrayCollection:ArrayCollection = new ArrayCollection();
      var sort:Sort = new Sort();
      var sortField:SortField = new SortField("sFileId");
      sort.fields = [sortField];
      tempArrayCollection.sort = sort;
      tempArrayCollection.refresh();
      for (sFileId in fileInfo) {
         iFileCount++;
         if (iFileCount > Constant_LangMentor_Misc.MAX_ALLOWED_CHUNKS_PER_LESSON_VERSION)
            Log.fatal(["Utils_LangCollab.computeLessonVersionSignature(): lessonVersion contains too many chunks", fileInfo]); /// throw error instead and handle by informing user - perhaps even catch before saving files
         sFileLength = String(MP3FileInfo(fileInfo[sFileId]).duration);
         sFileSignature = sFileLength.substring(sFileLength.length - 3, sFileLength.length);
         tempArrayCollection.addItem(
               {
                  sFileId: sFileId,
                  sFileSignature: sFileSignature
               }
         )
      }
      var oFileInfo:Object;
      for each (oFileInfo in tempArrayCollection) {
         result = result + oFileInfo.sFileSignature;
      }
      if (result.length == 0)
         Log.fatal(["Utils_LangCollab.computeLessonVersionSignature(): fileInfo has no props", fileInfo]); /// throw error instead and handle by informing user - perhaps even catch before saving files
      // DLM 20091007 - The code below is a little research project that I ran to confirm the need for the sort step
      // implemented above - and the results confirmed that we can't count on the properties of a Dict always being
      // accessed in same order
      //
      /* var resultTest:String = "";
      var fileLength:int;
      for each (fileLength in fileInfo) {
          sFileLength = String(fileLength);
          sFileSignature = sFileLength.substring(sFileLength.length - 3, sFileLength.length);
          resultTest = resultTest + sFileSignature;
      }
      if (resultTest != result) Log.warn(["Utils_LangCollab.computeLessonVersionSignature(): Good news! We've confirmed that can't count on the order in which a Dictionary is read. :)", result, resultTest]); */
      return result;
   }

   public static function getMessage_NoLessonsDownloaded():String {
      var message:String;
      if (LessonDownloadController.getInstance().isUpdateAvailableLessonDownloadsProcessActive ||
            LessonDownloadController.getInstance().isLessonDownloadProcessActive) {
         message = "Lesson downloads are currently in progress - please wait. ";
      } else {
         message = "No lessons have been downloaded yet. You may need to change your options for libraries, lesson downloads, etc. in the More menu.";
      }
      return message;
   }

   public static function wipeData(
         model:MainModel,
         appStatePersistenceManager:AppStatePersistenceManager,
         lessonDownloadController:LessonDownloadController,
         audioController:AudioController ):Boolean {
      model.wipeData();
      audioController.onStopLoopMode();
      audioController.onStopRecordMode();
      lessonDownloadController.wipeData();
      Utils_Database.createNewDBFileFromTemplate(sqLiteDatabaseFileURL, appStatePersistenceManager);
      return Utils_File.deleteDirectory(Utils_AIR.applicationStorageDirectory);
   }


}
}
