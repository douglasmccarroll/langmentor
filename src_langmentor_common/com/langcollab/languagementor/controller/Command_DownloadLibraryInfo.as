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
import com.brightworks.util.Utils_DataConversionComparison;
import com.brightworks.util.Utils_Dispose;
import com.brightworks.util.Utils_System;
import com.brightworks.util.Utils_XML;
import com.brightworks.util.download.FileDownloader;
import com.brightworks.util.download.FileDownloaderErrorReport;
import com.brightworks.util.download.FileSetDownloader;
import com.brightworks.util.download.FileSetDownloaderErrorReport;
import com.brightworks.util.download.FileSetDownloaderFileInfo;
import com.brightworks.util.download.FileSetDownloaderFilesInfo;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.constant.Constant_TextDisplayTypeNames;
import com.langcollab.languagementor.model.LessonDownloadInfo_Lesson;
import com.langcollab.languagementor.model.LessonDownloadInfo_Library;
import com.langcollab.languagementor.util.ChunkXMLConsistencyChecker;

import flash.events.TimerEvent;
import flash.system.Security;
import flash.system.System;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

public class Command_DownloadLibraryInfo extends Command_Base__LangMentor {
   public static const STATUS__COMPLETE:String = "status_Complete";
   public static const STATUS__DOWNLOADING_LESSON_LIST_XML:String = "status_DownloadingLessonListXML";
   public static const STATUS__DOWNLOADING_LESSON_XML:String = "status_DownloadingLessonXML";
   public static const STATUS__DOWNLOADING_LIBRARY_XML:String = "status_DownloadingLibraryXML";
   public static const STATUS__PARSING_LESSON_LIST_XML:String = "status_ParsingLessonListXML";
   public static const STATUS__PARSING_LESSON_XML:String = "status_ParsingLessonXML";
   public static const STATUS__PARSING_LIBRARY_XML:String = "status_ParsingLibraryXML";

   private static const _LESSON_TYPE__DUAL_LANGUAGE:String = "lessonListFileId_DualLanguageLessons";
   private static const _LESSON_TYPE__SINGLE_LANGUAGE:String = "lessonListFileId_SingleLanguageLessons";
   private static const _TIMER_TIMEOUT_MS:int = 15000;

   public var techReport:Command_DownloadLibraryInfoTechReport;
   public var status:String;

   private var _downloadFailureCount:int = 0;
   private var _includeLessonInfo:Boolean;
   private var _index_lessonId_to_lessonDownloadFolderURL:Dictionary = new Dictionary();
   private var _index_lessonId_to_lessonPublishedVersion:Dictionary = new Dictionary();
   private var _index_lessonId_to_lessonType:Dictionary = new Dictionary();
   private var _index_lessonId_to_lessonXML:Dictionary = new Dictionary();
   private var _isDisposed:Boolean = false;
   private var _lessonFileSetDownloader:FileSetDownloader;
   private var _lessonDownloadInfo_Library:LessonDownloadInfo_Library;
   private var _lessonListFileSetDownloader:FileSetDownloader;
   private var _lessonListXML_DualLanguage:XML;
   private var _lessonListXML_SingleLanguage:XML;
   private var _libraryFileDownloader:FileDownloader;
   private var _libraryFolderUrl:String;
   private var _libraryName:String;
   private var _libraryXML:XML;
   private var _successfulLessonXMLFileDownloadCount:uint = 0;

   // --------------------------------------------
   //
   //           Public Methods
   //
   // --------------------------------------------

   // This command's task is to download the library info list, lesson lists,
   // and lesson XML files.
   // We store the info from these files in a LessonDownloadInfo_Library
   // instance, and its LessonDownloadInfo_Lesson instances.
   // LessonDownloadInfo_Library instances are stored in
   // lessonDownloadController.lessonDownloadInfo_Libraries.index_libraryFolderURL_to_lessonDownloadInfo_library
   public function Command_DownloadLibraryInfo(libraryFolderUrl:String, includeLessonInfo:Boolean, callbacks:Callbacks) {
      super();
      Log.debug("Command_DownloadLibraryInfo constructor - class has XML props");
      _libraryFolderUrl = libraryFolderUrl;
      _includeLessonInfo = includeLessonInfo;
      this.callbacks = callbacks;
      techReport = new Command_DownloadLibraryInfoTechReport();
   }

   override public function dispose():void {
      Log.debug("Command_DownloadLibraryInfo.dispose() - class has XML props");
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      // techReport's dispose() method is called by
      //   Command_UpdateAvailableLessonDownloadsInfoTechReport's dispose() method.
      model = null;
      techReport = null;
      if (_index_lessonId_to_lessonDownloadFolderURL) {
         Utils_Dispose.disposeDictionary(_index_lessonId_to_lessonDownloadFolderURL, true);
         _index_lessonId_to_lessonDownloadFolderURL = null;
      }
      if (_index_lessonId_to_lessonPublishedVersion) {
         Utils_Dispose.disposeDictionary(_index_lessonId_to_lessonPublishedVersion, true);
         _index_lessonId_to_lessonPublishedVersion = null;
      }
      if (_index_lessonId_to_lessonType) {
         Utils_Dispose.disposeDictionary(_index_lessonId_to_lessonType, true);
         _index_lessonId_to_lessonType = null;
      }
      if (_index_lessonId_to_lessonXML) {
         Utils_Dispose.disposeDictionary(_index_lessonId_to_lessonXML, true);
         _index_lessonId_to_lessonXML = null;
      }
      if (_lessonFileSetDownloader) {
         _lessonFileSetDownloader.dispose();
         _lessonFileSetDownloader = null;
      }
      if (_lessonListFileSetDownloader) {
         _lessonListFileSetDownloader.dispose();
         _lessonListFileSetDownloader = null;
      }
      if (_lessonListXML_DualLanguage) {
         System.disposeXML(_lessonListXML_DualLanguage);
         _lessonListXML_DualLanguage = null;
      }
      if (_lessonListXML_SingleLanguage) {
         System.disposeXML(_lessonListXML_SingleLanguage);
         _lessonListXML_SingleLanguage = null;
      }
      if (_libraryFileDownloader) {
         _libraryFileDownloader.dispose();
         _libraryFileDownloader = null;
      }
      if (_libraryXML) {
         System.disposeXML(_libraryXML);
         _libraryXML = null;
      }
   }

   public function execute():void {
      Log.debug("Command_DownloadLibraryInfo.execute()");
      Security.loadPolicyFile(_libraryFolderUrl + "/" + Constant_LangMentor_Misc.FILEPATHINFO__DOWNLOAD_PERMISSION_FILE_NAME); /// Not used? No such files?
      techReport.libraryFolderUrl = _libraryFolderUrl;
      status = STATUS__DOWNLOADING_LIBRARY_XML;
      _libraryFileDownloader = new FileDownloader();
      _libraryFileDownloader.downloadFolderURL = _libraryFolderUrl;
      _libraryFileDownloader.downloadFileName = Constant_LangMentor_Misc.FILEPATHINFO__LANGUAGE_MENTOR_LIBRARY_FILE_NAME;
      _libraryFileDownloader.downloadFileExtension = "xml";
      _libraryFileDownloader.addEventListener(BwEvent.COMPLETE, onLibraryFileDownloadComplete);
      _libraryFileDownloader.addEventListener(BwEvent.FAILURE, onLibraryFileDownloadFailure);
      Log.info("Command_DownloadLibraryInfo.execute(): starting _libraryFileDownloader - " + _libraryFileDownloader.fullFileURL);
      _libraryFileDownloader.start();
      startOrRestartTimeoutTimer(_TIMER_TIMEOUT_MS, onTimeoutTimerComplete);
   }

   // --------------------------------------------
   //
   //           Private Methods
   //
   // --------------------------------------------

   private function doesDualLanguageLessonInfoIndicateContentForCurrTargetLanguage():Boolean {
      var result:Boolean = false;
      var libraryContentInfoNode:XML = _libraryXML.libraryContentInfo[0];
      if (XMLList(libraryContentInfoNode.dualLanguageLessonInfo).length() == 1) {
         if (XMLList(libraryContentInfoNode.dualLanguageLessonInfo[0].languagePairs).length() == 1) {
            var languagePairsNode:XML = libraryContentInfoNode.dualLanguageLessonInfo[0].languagePairs[0];
            for each (var languagePairNode:XML in languagePairsNode.languagePair) {
               if (languagePairNode.targetLanguage[0].toString() == model.getTargetLanguageIso639_3Code()) {
                  result = true;
                  break;
               }
            }
         }
      }
      return result;
   }

   private function doesSingleLanguageLessonInfoIndicateContentForCurrTargetLanguage():Boolean {
      var result:Boolean = false;
      var libraryContentInfoNode:XML = _libraryXML.libraryContentInfo[0];
      if (XMLList(libraryContentInfoNode.singleLanguageLessonInfo).length() == 1) {
         if (XMLList(libraryContentInfoNode.singleLanguageLessonInfo[0].languages).length() == 1) {
            var languagesNode:XML = libraryContentInfoNode.singleLanguageLessonInfo[0].languages[0];
            for each (var languageNode:XML in languagesNode.language) {
               if (languageNode.toString() == model.getTargetLanguageIso639_3Code()) {
                  result = true;
                  break;
               }
            }
         }
      }
      return result;
   }

   private function getCurrNativeLanguageLanguageNodeOrEnglishLanguageNodeFromLibraryXML():XML {
      var result:XML;
      var languageNode:XML;
      for each (languageNode in _libraryXML.languages[0].language) {
         if (languageNode.iso639_3Code[0].toString() == model.getNativeLanguageIso639_3Code()) {
            result = languageNode;
            break;
         }
      }
      if (!result) {
         for each (languageNode in _libraryXML.languages[0].language) {
            if (languageNode.iso639_3Code[0].toString() == "eng") {
               result = languageNode;
               break;
            }
         }
      }
      return result;
   }

   private function getDualLanguageFolderURL():String {
      return _libraryFolderUrl + model.getTargetLanguageIso639_3Code() + "_" + model.getNativeLanguageIso639_3Code() + "/";
   }

   private function getLanguageFolderURL(lessonType:String):String {
      var result:String;
      switch (lessonType) {
         case _LESSON_TYPE__DUAL_LANGUAGE: {
            result = getDualLanguageFolderURL();
            break;
         }
         case _LESSON_TYPE__SINGLE_LANGUAGE: {
            result = getSingleLanguageFolderURL();
            break;
         }
         default: {
            Log.error("Command_DownloadLibraryInfo.getLanguageFolderURL(): No case for lessonType of '" + lessonType + "'");
         }
      }
      return result;
   }

   private function getSingleLanguageFolderURL():String {
      return _libraryFolderUrl + model.getTargetLanguageIso639_3Code() + "/";
   }

   private function isLessonDefaultTextDisplayTypeAStandardTextDisplayType(typeName:String):Boolean {
      var result:Boolean = model.isTextDisplayTypeExists(typeName);
      return result;
   }

   private function isLessonLevelAStandardLevel(level:String):Boolean {
      var result:Boolean = model.isLessonLevelAStandardLevelLabelToken(level);
      return result;
   }

   private function onLessonFilesDownloadComplete(event:BwEvent):void {
      model.downloadBandwidthRecorder.reportFileSetDownloader(_lessonFileSetDownloader);
      if (_isDisposed)
         return;
      stopTimeoutTimer();
      processDownloadedLessonFilesData(FileSetDownloader(event.target).filesInfo);
   }

   private function onLessonFilesDownloadFailure(event:BwEvent):void {
      model.downloadBandwidthRecorder.reportFileSetDownloader(_lessonFileSetDownloader);
      if (_isDisposed)
         return;
      stopTimeoutTimer();
      processDownloadedLessonFilesData(FileSetDownloader(event.target).filesInfo, FileSetDownloaderErrorReport(event.techReport));
   }

   private function onLessonListFilesDownloadComplete(event:BwEvent):void {
      stopTimeoutTimer();
      model.downloadBandwidthRecorder.reportFileSetDownloader(_lessonListFileSetDownloader);
      if (_isDisposed)
         return;
      processDownloadedLessonListFilesData(FileSetDownloader(event.target).filesInfo);
   }

   private function onLessonListFilesDownloadFailure(event:BwEvent):void {
      // This is called if there are problems downloading _any_ lesson list files. For example, if a library's
      // XML file indicates that there are single-language lessons, but the library has no folder for such lessons.
      model.downloadBandwidthRecorder.reportFileSetDownloader(_lessonListFileSetDownloader);
      if (_isDisposed)
         return;
      stopTimeoutTimer();
      processDownloadedLessonListFilesData(FileSetDownloader(event.target).filesInfo, FileSetDownloaderErrorReport(event.techReport));
   }

   private function onLibraryFileDownloadComplete(event:BwEvent):void {
      model.downloadBandwidthRecorder.reportFileDownloader(_libraryFileDownloader);
      if (_isDisposed)
         return;
      stopTimeoutTimer();
      status = STATUS__PARSING_LIBRARY_XML;
      var libraryXMLFileData:ByteArray = FileDownloader(event.target).fileData;
      if (!validateAndPopulateLibraryXML(libraryXMLFileData)) {
         techReport.isProblemValidatingLibraryXML = true;
         var langNode:XML = XML(getCurrNativeLanguageLanguageNodeOrEnglishLanguageNodeFromLibraryXML());
         if ((langNode) && (langNode.libraryName[0] is XML))
            _libraryName = langNode.libraryName[0].toString();
         reportFaultAndDispose();
         return;
      }
      _lessonDownloadInfo_Library = new LessonDownloadInfo_Library();
      lessonDownloadController.lessonDownloadInfo_Libraries.index_libraryFolderURL_to_lessonDownloadInfo_library[_libraryFolderUrl] = _lessonDownloadInfo_Library;
      _lessonDownloadInfo_Library.libraryFolderUrl = _libraryFolderUrl;
      _lessonDownloadInfo_Library.contentProviderId = _libraryXML.contentProviderId[0].toString();
      _lessonDownloadInfo_Library.libraryId = _libraryXML.libraryId[0].toString();
      _lessonDownloadInfo_Library.contentProviderName = XML(getCurrNativeLanguageLanguageNodeOrEnglishLanguageNodeFromLibraryXML()).contentProviderName[0].toString();
      _libraryName = XML(getCurrNativeLanguageLanguageNodeOrEnglishLanguageNodeFromLibraryXML()).libraryName[0].toString();
      _lessonDownloadInfo_Library.libraryName = _libraryName;
      if (_includeLessonInfo)
         startLessonInfoDownloads();
      else
         reportSuccess();
   }

   private function onLibraryFileDownloadFailure(event:BwEvent):void {
      model.downloadBandwidthRecorder.reportFileDownloader(_libraryFileDownloader);
      if (_isDisposed)
         return;
      stopTimeoutTimer();
      _downloadFailureCount++;
      if (_downloadFailureCount <= 10) {
         _libraryFileDownloader.start();
         startOrRestartTimeoutTimer(_TIMER_TIMEOUT_MS, onTimeoutTimerComplete);
      } else {
         techReport.fileDownloadErrorReportList.push(FileDownloaderErrorReport(event.techReport));
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__DOWNLOAD_FAILURE);
         reportFaultAndDispose();
      }
   }

   private function onTimeoutTimerComplete(event:TimerEvent):void {
      if (_isDisposed)
         return;
      techReport.isProcessTimedOut = true;
      reportFaultAndDispose();
   }

   private function processDownloadedLessonFilesData(filesInfo:FileSetDownloaderFilesInfo, fileSetDownloaderErrorReport:FileSetDownloaderErrorReport = null):void {
      if (fileSetDownloaderErrorReport) {
         var index_lessonFileId_to_fileDownloaderErrorReport:Dictionary = fileSetDownloaderErrorReport.index_fileId_to_fileDownloaderErrorReport;
         techReport.index_lessonFileId_to_fileDownloaderErrorReport = index_lessonFileId_to_fileDownloaderErrorReport;
      }
      // Add _lessonDownloadInfo_Library to model if any lesson info was successfully retrieved.
      // "Successfully retrieved" means that the lesson XML file was successfully downloaded.
      // We store this info in the model but don't persist it. In other words, this is
      // temporary data that will only be used while the user is in the 'download lessons' UI.
      var lessonId:String;
      var bAllLessonInfoFilesSuccessfullyDownloadedAndParsed:Boolean = true;
      var bOneOrMoreLessonInfoFilesSuccessfullyDownloadedAndParsed:Boolean = false;
      for (lessonId in filesInfo.fileInfoList) {
         var problemDescriptionList:Vector.<String>;
         if ((index_lessonFileId_to_fileDownloaderErrorReport) && (index_lessonFileId_to_fileDownloaderErrorReport.hasOwnProperty(lessonId))) {
            problemDescriptionList = new Vector.<String>();
            problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__DOWNLOAD_FAILURE);
            techReport.index_lessonId_to_lessonXmlFileProblemDescriptionList[lessonId] = problemDescriptionList;
            bAllLessonInfoFilesSuccessfullyDownloadedAndParsed = false;
            continue;
         }
         var lessonFileInfo:FileSetDownloaderFileInfo = filesInfo.getFileInfo(lessonId);
         if (!((lessonFileInfo.fileData is ByteArray) && (validateAndPopulateLessonXML(lessonId, lessonFileInfo.fileData)))) {
            // validateAndPopulateLessonXML() creates a problemDescriptionList and adds it to the
            // tech report (similar to above), so we don't have to do it here.
            bAllLessonInfoFilesSuccessfullyDownloadedAndParsed = false;
            continue;
         }
         // dmccarroll 20120616 (ChunkXMLConsistencyCheck)
         // At this point we determine, for each kinds of text that chunks can contain, which of the following is true:
         //    a. Either there are no chunk nodes, or none have that kind of text.
         //    b. All chunk nodes have that kind of text.
         //    c. Some nodes have it, some don't.
         // If the (c) case is found for any type of text this is an error. We'll report the error and won't proceed to download the lesson file.
         // If (a) or (b) is found for any given type of text, this information is passed into DownloadLessonProcess through a rather complex process:
         //    a. We set the appropriate local index_lessonFileId_to_isHasText... index here
         //    b. In the next loop in this method we set lessonIsHasText... props in LessonDownloadInfo_Lesson
         //    c. In LessonDownloadController.startLessonDownloadProcess() we copy these values into DownloadLessonProcessInfo's isHasText... props
         //    d. It is then used in DownloadLessonProcess.getLessonVersionTargetLanguageVOs() and getChunkVOs()
         // Clearly, it would be simpler to parse this information in DownloadLessonProcess. We do it here so that we can abort the download process
         //    at this point, if appropriate.
         var chunksNodesList:XMLList = XML(_index_lessonId_to_lessonXML[lessonId]).chunks;
         _successfulLessonXMLFileDownloadCount++;
         bOneOrMoreLessonInfoFilesSuccessfullyDownloadedAndParsed = true;
      }
      techReport.lessonXMLFileDownloadCount_Successful = _successfulLessonXMLFileDownloadCount;
      var bAllDownloadedLessonInfoFilesValidatedSuccessfully:Boolean = true;
      if (bOneOrMoreLessonInfoFilesSuccessfullyDownloadedAndParsed) {
         for (lessonId in _index_lessonId_to_lessonXML) {
            // _index_lessonId_to_lessonXML will have info for all lessons whose XML files could be parsed, but
            // this doesn't mean that there were no problems in the XML. We only create LessonDownloadInfo_Lesson
            // instances for those lessons where we found no problems in the XML.
            // Parsing is done in validateAndPopulateLessonXML()
            if (techReport.index_lessonId_to_lessonXmlFileProblemDescriptionList[lessonId]) {
               bAllDownloadedLessonInfoFilesValidatedSuccessfully = false;
               continue;
            }
            var lessonXML:XML = _index_lessonId_to_lessonXML[lessonId];
            var lessonDownloadInfo_Lesson:LessonDownloadInfo_Lesson = new LessonDownloadInfo_Lesson();
            lessonDownloadInfo_Lesson.lessonDownloadFolderURL = _index_lessonId_to_lessonDownloadFolderURL[lessonId];
            lessonDownloadInfo_Lesson.lessonIsDualLanguage = _index_lessonId_to_lessonType[lessonId];
            if (XMLList(lessonXML.chunks).length() == 1) {
               lessonDownloadInfo_Lesson.lessonChunks = lessonXML.chunks[0];
            }
            if (XMLList(lessonXML.credits).length() > 0)
               lessonDownloadInfo_Lesson.lessonCredits = lessonXML.credits[0];
            if (XMLList(lessonXML.description).length() > 0)
               lessonDownloadInfo_Lesson.lessonDescription = lessonXML.description[0].toString();
            lessonDownloadInfo_Lesson.lessonId = lessonId;
            lessonDownloadInfo_Lesson.lessonIsAlphaReviewVersion = Utils_XML.readBooleanNode(lessonXML.isAlphaReviewVersion[0]);
            lessonDownloadInfo_Lesson.lessonIsDualLanguage = Utils_XML.readBooleanNode(lessonXML.isDualLanguage[0]);
            lessonDownloadInfo_Lesson.lessonLevelToken = lessonXML.level[0].toString();
            if (XMLList(lessonXML.nativeLanguageAudioVolumeAdjustmentFactor).length() == 1)
               lessonDownloadInfo_Lesson.lessonNativeLanguageAudioVolumeAdjustmentFactor = Utils_XML.readNumberNode(lessonXML.nativeLanguageAudioVolumeAdjustmentFactor[0]);
            else
               lessonDownloadInfo_Lesson.lessonNativeLanguageAudioVolumeAdjustmentFactor = Constant_LangMentor_Misc.AUDIO__DEFAULT_NATIVE_LANGUAGE_AUDIO_VOLUME_ADJUSTMENT_FACTOR;
            lessonDownloadInfo_Lesson.lessonName = lessonXML.lessonName[0].toString();
            if (XMLList(lessonXML.lessonSortName).length() == 1)
               lessonDownloadInfo_Lesson.lessonSortName = lessonXML.lessonSortName[0].toString();
            else
               lessonDownloadInfo_Lesson.lessonSortName = lessonDownloadInfo_Lesson.lessonName;

            lessonDownloadInfo_Lesson.lessonDefaultTextDisplayTypeId =
                  model.getTextDisplayTypeIdFromTypeName(lessonXML.defaultTextDisplayType[0].toString());
            lessonDownloadInfo_Lesson.lessonPublishedLessonVersionVersion = _index_lessonId_to_lessonPublishedVersion[lessonId];
            if (XMLList(lessonXML.tags).length() > 0)
               lessonDownloadInfo_Lesson.lessonTags = lessonXML.tags[0];
            if (XMLList(lessonXML.targetLanguageAudioVolumeAdjustmentFactor).length() == 1)
               lessonDownloadInfo_Lesson.lessonTargetLanguageAudioVolumeAdjustmentFactor = Utils_XML.readNumberNode(lessonXML.targetLanguageAudioVolumeAdjustmentFactor[0]);
            else
               lessonDownloadInfo_Lesson.lessonTargetLanguageAudioVolumeAdjustmentFactor = 1;
            _lessonDownloadInfo_Library.index_LessonIds_To_LessonDownloadInfo_Lessons[lessonId] = lessonDownloadInfo_Lesson;
         }

         // dmccarroll 20120428
         // We're having a 'null object' problem in the final line of code in this if block but the error message, of course,
         // doesn't explain which variable is null. So I'm breaking a single complex line of code into multiple lines and
         // adding a lot of checks with Log.error() calls.
         if (!lessonDownloadController.lessonDownloadInfo_Libraries) {
            Log.error("Command_DownloadLibraryInfo.processDownloadedLessonFilesData(): 'lessonDownloadController.lessonDownloadInfo_Libraries' is null");
         } else if (!(lessonDownloadController.lessonDownloadInfo_Libraries.index_libraryFolderURL_to_lessonDownloadInfo_library is Dictionary)) {
            Log.error("Command_DownloadLibraryInfo.processDownloadedLessonFilesData(): 'lessonDownloadController.lessonDownloadInfo_Libraries.index_libraryFolderURL_to_lessonDownloadInfo_library' is null");
         }
      } else {
         _lessonDownloadInfo_Library.dispose();
      }
      if ((fileSetDownloaderErrorReport) || (!bAllLessonInfoFilesSuccessfullyDownloadedAndParsed) || (!bAllDownloadedLessonInfoFilesValidatedSuccessfully)) {
         reportFaultAndDispose();
      } else {
         reportSuccess();
      }
      if (fileSetDownloaderErrorReport) {
         fileSetDownloaderErrorReport.dispose();
      }
      filesInfo.dispose();
      dispose();
   }

   private function processDownloadedLessonListFilesData(filesInfo:FileSetDownloaderFilesInfo, fileSetDownloaderErrorReport:FileSetDownloaderErrorReport = null):void {


      // New lesson version failing to download?
      // Is it a selected lesson? If so, unselect.   :)


      if (fileSetDownloaderErrorReport) {
         // When the FileSetDownloader is initiated, it's instructed to look for the single and/or dual language lesson list files, based on
         // what we found in the library file. But if it can't find either of these, I don't think that we want to report an error. Essentially,
         // this isn't the user's problem, and they shouldn't worry about it. On the other hand, if a publisher is looking for info on why their
         // lessons aren't found, we'd like them to be able to get that info, so we put it into this command's error report.
         var index_lessonListFileId_to_fileDownloaderErrorReport:Dictionary = fileSetDownloaderErrorReport.index_fileId_to_fileDownloaderErrorReport;
         techReport.index_lessonListFileId_to_fileDownloaderErrorReport = index_lessonListFileId_to_fileDownloaderErrorReport;
      }
      status = STATUS__PARSING_LESSON_LIST_XML;
      var lessonListFilesDownloaderFilesInfoList:Dictionary = filesInfo.fileInfoList;
      if (Log.isLoggingEnabled(Log.LOG_LEVEL__DEBUG)) {
         Log.debug("Command_DownloadLibraryInfo.processDownloadedLessonListFilesData() is creating a new FileSetDownloaderFilesInfo instance for downloading lesson info files. Library URL = " + _lessonDownloadInfo_Library.libraryFolderUrl);
      }
      var lessonFilesInfo:FileSetDownloaderFilesInfo = new FileSetDownloaderFilesInfo();
      var isWillDownloadOneOrMoreLessonXMLFiles:Boolean;
      for each (var lessonType:String in[_LESSON_TYPE__SINGLE_LANGUAGE, _LESSON_TYPE__DUAL_LANGUAGE]) {
         if (!lessonListFilesDownloaderFilesInfoList.hasOwnProperty(lessonType))
            continue;
         var lessonListFileInfo:FileSetDownloaderFileInfo = lessonListFilesDownloaderFilesInfoList[lessonType];
         var lessonListXMLFileData:ByteArray = lessonListFileInfo.fileData;
         if (validateAndPopulateLessonListXML(lessonListXMLFileData, lessonType)) {
            techReport.lessonListFileDownloadCount_Successful++;
            var lessonListXML:XML;
            switch (lessonType) {
               case _LESSON_TYPE__DUAL_LANGUAGE: {
                  lessonListXML = _lessonListXML_DualLanguage;
                  break;
               }
               case _LESSON_TYPE__SINGLE_LANGUAGE: {
                  lessonListXML = _lessonListXML_SingleLanguage;
                  break;
               }
            }
            for each (var lessonNode:XML in lessonListXML.lesson) {
               var lessonId:String = lessonNode.toString();

               // Keep for debugging lesson download failures
               if (lessonId.indexOf("de_jing") != -1) {
                  var foo:int = 0;
               }

               var lessonVersion:String = lessonNode.@version;
               if (lessonVersion == "")
                  lessonVersion = "0";
               if (lessonDownloadController.isLessonEligibleForDownloadingButCurrentlySelected(
                     lessonId,
                     lessonVersion,
                     _lessonDownloadInfo_Library.contentProviderId,
                     model.getLevelIdFromLevelLabelToken(lessonNode.@level))) {
                  techReport.count_LessonUpdatesNotDownloadedBecauseInSelectedLessons++;
               }
               if (!lessonDownloadController.isLessonEligibleForDownloading(
                     lessonId,
                     lessonVersion,
                     _lessonDownloadInfo_Library.contentProviderId,
                     model.getLevelIdFromLevelLabelToken(lessonNode.@level))) {
                  continue;
               }
               isWillDownloadOneOrMoreLessonXMLFiles = true;
               _index_lessonId_to_lessonType[lessonId] = lessonType;
               _index_lessonId_to_lessonPublishedVersion[lessonId] = lessonVersion;
               var fileInfo:FileSetDownloaderFileInfo = new FileSetDownloaderFileInfo();
               fileInfo.fileFolderURL = getLanguageFolderURL(lessonType);
               _index_lessonId_to_lessonDownloadFolderURL[lessonId] = fileInfo.fileFolderURL;
               fileInfo.fileNameBody = lessonId;
               fileInfo.fileNameExtension = "xml";
               lessonFilesInfo.addFileInfo(lessonId, fileInfo);
            }
         } else {
            switch (lessonType) {
               case _LESSON_TYPE__DUAL_LANGUAGE: {
                  techReport.isLessonListXMLPopulationAndValidationFailed_DualLanguage = true;
                  break;
               }
               case _LESSON_TYPE__SINGLE_LANGUAGE: {
                  techReport.isLessonListXMLPopulationAndValidationFailed_SingleLanguage = true;
                  break;
               }
            }
         }
      }
      filesInfo.dispose();
      if (isWillDownloadOneOrMoreLessonXMLFiles) {
         techReport.lessonXMLFileDownloadCount_Attempted = lessonFilesInfo.length;
         status = STATUS__DOWNLOADING_LESSON_XML;
         _lessonFileSetDownloader = new FileSetDownloader(true);
         _lessonFileSetDownloader.filesInfo = lessonFilesInfo;
         _lessonFileSetDownloader.addEventListener(BwEvent.COMPLETE, onLessonFilesDownloadComplete);
         _lessonFileSetDownloader.addEventListener(BwEvent.FAILURE, onLessonFilesDownloadFailure);
         if (Log.isLoggingEnabled(Log.LOG_LEVEL__DEBUG)) {
            Log.debug("Command_DownloadLibraryInfo.processDownloadedLessonListFilesData() is starting its newly created FileSetDownloaderFilesInfo for downloading lesson info files.");
         }
         _lessonFileSetDownloader.start();
         startOrRestartTimeoutTimer(_TIMER_TIMEOUT_MS, onTimeoutTimerComplete);
      } else {
         // The lesson lists are empty, which is fine. We've "succeeded".
         if (Log.isLoggingEnabled(Log.LOG_LEVEL__DEBUG)) {
            Log.debug("Command_DownloadLibraryInfo.processDownloadedLessonListFilesData() isn't using its newly created FileSetDownloaderFilesInfo because the lesson list files had no lessons in their lists.");
         }
         reportSuccess();
         dispose();
      }
   }

   private function reportFaultAndDispose():void {
      techReport.statusAtTimeOfFaultReport = status;
      techReport.libraryName = _libraryName;
      switch (status) {
         case STATUS__DOWNLOADING_LESSON_LIST_XML: {
            if (_lessonListFileSetDownloader) {
               techReport.lessonListFileSetDownloaderErrorReport = _lessonListFileSetDownloader.errorReport;
            } else {
               techReport.miscInfoList.push("Status is STATUS__DOWNLOADING_LESSON_LIST_XML but _lessonListFileSetDownloader is null.");
            }
            break;
         }
         case STATUS__DOWNLOADING_LESSON_XML: {
            if (_lessonFileSetDownloader) {
               techReport.lessonXMLFileSetDownloaderErrorReport = _lessonFileSetDownloader.errorReport;
            } else {
               techReport.miscInfoList.push("Status is STATUS__DOWNLOADING_LESSON_XML but _lessonFileSetDownloader is null.");
            }
            break;
         }
         case STATUS__DOWNLOADING_LIBRARY_XML: {
            if ((_libraryFileDownloader) && (_libraryFileDownloader.errorReport)) {
               techReport.libraryDownloaderErrorReport = _libraryFileDownloader.errorReport;
            } else {
               techReport.miscInfoList.push("Status is STATUS__DOWNLOADING_LIBRARY_XML but either _libraryFileDownloader or _libraryFileDownloader.errorReport is null.");
            }
            break;
         }
      }
      fault(techReport);
      dispose();
   }

   public function reportSuccess():void {
      techReport.isSuccess = true;
      techReport.libraryFolderUrl = _libraryFolderUrl;
      result(techReport);
   }

   private function startLessonInfoDownloads():void {
      var lessonListFileName:String =
            Utils_System.isAlphaOrBetaVersion() ?
                  Constant_LangMentor_Misc.FILEPATHINFO__LESSON_LIST_FILE_NAME__STAGING :
                  Constant_LangMentor_Misc.FILEPATHINFO__LESSON_LIST_FILE_NAME__PRODUCTION;
      _lessonListFileSetDownloader = new FileSetDownloader(true);
      var filesInfo:FileSetDownloaderFilesInfo = new FileSetDownloaderFilesInfo();
      _lessonListFileSetDownloader.filesInfo = filesInfo;
      var fileInfo:FileSetDownloaderFileInfo;
      if (doesSingleLanguageLessonInfoIndicateContentForCurrTargetLanguage()) {
         fileInfo = new FileSetDownloaderFileInfo();
         fileInfo.fileFolderURL = getSingleLanguageFolderURL();
         fileInfo.fileNameBody = lessonListFileName;
         fileInfo.fileNameExtension = "xml";
         filesInfo.addFileInfo(_LESSON_TYPE__SINGLE_LANGUAGE, fileInfo);
      }
      if (doesDualLanguageLessonInfoIndicateContentForCurrTargetLanguage()) {
         fileInfo = new FileSetDownloaderFileInfo();
         fileInfo.fileFolderURL = getDualLanguageFolderURL();
         fileInfo.fileNameBody = lessonListFileName;
         fileInfo.fileNameExtension = "xml";
         filesInfo.addFileInfo(_LESSON_TYPE__DUAL_LANGUAGE, fileInfo);
      }
      if (filesInfo.length == 0) {
         techReport.isLibraryFileDoesNotIndicateLibraryHasContentForTargetLanguage = true;
         reportFaultAndDispose();
         return;
      }
      status = STATUS__DOWNLOADING_LESSON_LIST_XML;
      techReport.lessonListFileDownloadCount_Attempted = filesInfo.length;
      _lessonListFileSetDownloader.addEventListener(BwEvent.COMPLETE, onLessonListFilesDownloadComplete);
      _lessonListFileSetDownloader.addEventListener(BwEvent.FAILURE, onLessonListFilesDownloadFailure);
      Log.debug("Command_DownloadLibraryInfo.onLibraryFileDownloadComplete(): starting _lessonListFileSetDownloader - " + _libraryFolderUrl);
      _lessonListFileSetDownloader.start();
      startOrRestartTimeoutTimer(_TIMER_TIMEOUT_MS, onTimeoutTimerComplete);
   }

   private function validateAndPopulateLessonListXML(lessonListXMLFileData:ByteArray, lessonType:String):Boolean {
      try {
         var lessonListXML:XML = new XML(String(lessonListXMLFileData));
         switch (lessonType) {
            case _LESSON_TYPE__DUAL_LANGUAGE: {
               _lessonListXML_DualLanguage = lessonListXML;
               break;
            }
            case _LESSON_TYPE__SINGLE_LANGUAGE: {
               _lessonListXML_SingleLanguage = lessonListXML;
               break;
            }
            default: {
               Log.fatal("Command_DownloadLibraryInfo.validateAndPopulateLessonListXML() No case for " + lessonType);
            }
         }
      } catch (error:TypeError) {
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_LIST_XML__MALFORMED_XML + ": " + error.message);
         return false;
      }
      var bError:Boolean = false;
      for each (var lessonNode:XML in XMLList(lessonListXML.lesson)) {
         if (lessonNode.@version == "") {
            // version isn't specified, which is fine
         } else if (!Utils_DataConversionComparison.isANumberString(lessonNode.@version)) {
            bError = true;
            techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_LIST_XML__LESSON_VERSION_IS_NOT_A_NUMBER + ": " + lessonNode.toString());
         }
         if (!model.isLessonLevelAStandardLevelLabelToken(lessonNode.@level)) {
            bError = true;
            techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_LIST_XML__LEVEL_IS_NOT_A_STANDARD_LEVEL + ": " + lessonNode.toString());
         }
      }
      return (!bError);
   }

   private function validateAndPopulateLessonXML(lessonId:String, lessonXMLFileData:ByteArray):Boolean {
      var problemDescriptionList:Vector.<String> = new Vector.<String>();
      try {
         var lessonXML:XML = new XML(String(lessonXMLFileData));
      } catch (error:TypeError) {
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MALFORMED_XML);
         problemDescriptionList.push(error.message);
         techReport.index_lessonId_to_lessonXmlFileProblemDescriptionList[lessonId] = problemDescriptionList;
         return false;
      }
      _index_lessonId_to_lessonXML[lessonId] = lessonXML;
      var bError:Boolean = false;
      if (XMLList(lessonXML.lessonName).length() < 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__NO_LESSON_NAME_NODE);
      } else if (XMLList(lessonXML.lessonName).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_LESSON_NAME_NODES);
      }
      if (XMLList(lessonXML.description).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_DESCRIPTION_NODES);
      }
      var lessonTypeBasedOnLibraryFolder:String = _index_lessonId_to_lessonType[lessonId];
      var lessonTypeBasedOnXML:String;
      if (XMLList(lessonXML.isAlphaReviewVersion).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_IS_ALPHA_REVIEW_VERSION_NODES);
      }
      if (XMLList(lessonXML.isDualLanguage).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_IS_DUAL_LANGUAGE_NODES);
      } else if (XMLList(lessonXML.isDualLanguage).length() == 1) {
         lessonTypeBasedOnXML = Utils_XML.readBooleanNode(lessonXML.isDualLanguage[0]) ? _LESSON_TYPE__DUAL_LANGUAGE : _LESSON_TYPE__SINGLE_LANGUAGE;
      } else {
         lessonTypeBasedOnXML = _LESSON_TYPE__SINGLE_LANGUAGE;
      }
      if (lessonTypeBasedOnLibraryFolder == lessonTypeBasedOnXML) {
         switch (lessonTypeBasedOnLibraryFolder) {
            case _LESSON_TYPE__DUAL_LANGUAGE: {
               if (XMLList(lessonXML.nativeLanguageISO639_3Code).length() < 1) {
                  bError = true;
                  problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__NO_NATIVE_LANGUAGE_ISO6393_CODE_NODE_AND_IS_DUAL_LANGUAGE);
               } else if (XMLList(lessonXML.nativeLanguageISO639_3Code).length() > 1) {
                  bError = true;
                  problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_NATIVE_LANGUAGE_ISO6393_CODE_NODES);
               }
               break;
            }
            case _LESSON_TYPE__SINGLE_LANGUAGE:
               break;
            default: {
               Log.error("Command_DownloadLibraryInfo.validateAndPopulateLessonXML(): no case for lessonType of '" + lessonTypeBasedOnLibraryFolder + "'");
            }
         }
      } else {
         bError = true;
         switch (lessonTypeBasedOnXML) {
            case _LESSON_TYPE__DUAL_LANGUAGE: {
               problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__INDICATES_DUAL_LANG_BUT_LESSON_IS_IN_SINGLE_LANG_DOWNLOAD_FOLDER);
               break;
            }
            case _LESSON_TYPE__SINGLE_LANGUAGE: {
               problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__INDICATES_SINGLE_LANG_BUT_LESSON_IS_IN_DUAL_LANG_DOWNLOAD_FOLDER);
               break;
            }
            default: {
               Log.error("Command_DownloadLibraryInfo.validateAndPopulateLessonXML(): no case for lessonType of '" + lessonTypeBasedOnXML + "'");
            }
         }
      }
      if (XMLList(lessonXML.targetLanguageISO639_3Code).length() < 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__NO_TARGET_LANGUAGE_ISO6393_CODE_NODE);
      } else if (XMLList(lessonXML.targetLanguageISO639_3Code).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_TARGET_LANGUAGE_ISO6393_CODE_NODES);
      }
      if (XMLList(lessonXML.level).length() < 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__NO_LEVEL_NODE);
      } else if (XMLList(lessonXML.level).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_LEVEL_NODES);
      } else if ((XMLList(lessonXML.level).length() == 1) && (!isLessonLevelAStandardLevel(lessonXML.level[0].toString()))) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__NONSTANDARD_LEVEL);
      }
      if (XMLList(lessonXML.defaultTextDisplayType).length() < 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__NO_DEFAULT_TEXT_DISPLAY_TYPE_NODE);
      } else if (XMLList(lessonXML.defaultTextDisplayType).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_DEFAULT_TEXT_DISPLAY_TYPE_NODES);
      } else if ((XMLList(lessonXML.defaultTextDisplayType).length() == 1) && (!isLessonDefaultTextDisplayTypeAStandardTextDisplayType(lessonXML.defaultTextDisplayType[0].toString()))) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__NONSTANDARD_DEFAULT_TEXT_DISPLAY_TYPE);
      }
      if (XMLList(lessonXML.tags).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_TAGS_NODES);
      }
      if (XMLList(lessonXML.credits).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_CREDITS_NODES);
      }
      if (XMLList(lessonXML.lessonSortName).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_LESSON_SORT_NAME_NODES);
      }
      if (XMLList(lessonXML.nativeLanguageAudioVolumeAdjustmentFactor).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_NATIVE_LANGUAGE_AUDIO_VOLUME_ADJUSTMENT_FACTOR_NODES);
      } else if ((XMLList(lessonXML.nativeLanguageAudioVolumeAdjustmentFactor).length() == 1) && (!Utils_XML.doesNodeEvaluateToNumber(lessonXML.nativeLanguageAudioVolumeAdjustmentFactor[0]))) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__TYPE_ERROR__NATIVE_LANGUAGE_AUDIO_VOLUME_ADJUSTMENT_FACTOR_NODE);
      }
      if (XMLList(lessonXML.targetLanguageAudioVolumeAdjustmentFactor).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_TARGET_LANGUAGE_AUDIO_VOLUME_ADJUSTMENT_FACTOR_NODES);
      } else if ((XMLList(lessonXML.targetLanguageAudioVolumeAdjustmentFactor).length() == 1) && (!Utils_XML.doesNodeEvaluateToNumber(lessonXML.targetLanguageAudioVolumeAdjustmentFactor[0]))) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__TYPE_ERROR__TARGET_LANGUAGE_AUDIO_VOLUME_ADJUSTMENT_FACTOR_NODE);
      }
      if (XMLList(lessonXML.chunks).length() > 1) {
         bError = true;
         problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_CHUNKS_NODES);
      }
      if (XMLList(lessonXML.chunks).length() == 1) {
         if (XMLList(lessonXML.chunks[0].chunk).length() == 0) {
            bError = true;
            problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__NO_CHUNK_NODES);
         } else {
            for each (var chunkNode:XML in lessonXML.chunks[0].chunk) {
               if (XMLList(chunkNode.fileNameRoot).length() == 0) {
                  bError = true;
                  problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__NO_FILE_NAME_ROOT_NODE);
               } else if (XMLList(chunkNode.fileNameRoot).length() > 1) {
                  bError = true;
                  problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_FILE_NAME_ROOT_NODES);
               }
            }
            if (ChunkXMLConsistencyChecker.isAnyChunkNodesContainMultipleTextNodesOfSameType(lessonXML.chunks[0])) {
               bError = true;
               problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__LESSON_XML__MULTIPLE_TEXT_NODES_OF_SAME_TYPE_IN_CHUNK_NODES);
            }
         }
      }
      if (bError)
         techReport.index_lessonId_to_lessonXmlFileProblemDescriptionList[lessonId] = problemDescriptionList;
      return (!bError);
   }

   private function validateAndPopulateLibraryXML(libraryXMLFileData:ByteArray):Boolean {
      try {
         _libraryXML = new XML(String(libraryXMLFileData));
      } catch (error:TypeError) {
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MALFORMED_XML + ": " + error.message);
         return false;
      }
      var bError:Boolean = false;
      if (XMLList(_libraryXML.contentProviderId).length() < 1) {
         bError = true;
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__NO_CONTENTPROVIDERID_NODE);
      } else if (XMLList(_libraryXML.contentProviderId).length() > 1) {
         bError = true;
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_CONTENT_PROVIDER_ID_NODES);
      } else if (_libraryXML.contentProviderId[0].toString().length < 7) {
         bError = true;
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__CONTENTPROVIDERID_TOO_SHORT);
      }
      if (XMLList(_libraryXML.libraryId).length() < 1) {
         bError = true;
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__NO_LIBRARYID_NODE);
      } else if (XMLList(_libraryXML.libraryId).length() > 1) {
         bError = true;
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_LIBRARY_ID_NODES);
      }
      if (XMLList(_libraryXML.languages).length() < 1) {
         bError = true;
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__NO_LANGUAGES_NODE);
      } else if (XMLList(_libraryXML.languages).length() > 1) {
         bError = true;
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_LANGUAGES_NODES);
      } else if (XMLList(_libraryXML.languages[0].language).length() < 1) {
         bError = true;
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__NO_LANGUAGE_NODES);
      } else {
         for each (var languageNode:XML in _libraryXML.languages[0].language) {
            if (XMLList(languageNode.iso639_3Code).length() < 1) {
               bError = true;
               techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MISSING_ISO6393_CODE);
            } else if (XMLList(languageNode.iso639_3Code).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_ISO6393_CODE_NODES);
            }
            if (XMLList(languageNode.contentProviderName).length() < 1) {
               bError = true;
               techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MISSING_CONTENT_PROVIDER_NAME_NODE);
            } else if (XMLList(languageNode.contentProviderName).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_CONTENT_PROVIDER_NAME_NODES);
            }
            if (XMLList(languageNode.libraryName).length() < 1) {
               bError = true;
               techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__NO_LIBRARYID_NODE);
            } else if (XMLList(languageNode.libraryName).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_LIBRARY_NAME_NODES);
            }
         }
      }
      if (XMLList(_libraryXML.libraryContentInfo).length() < 1) {
         bError = true;
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__NO_LIBRARY_CONTENT_INFO_NODE);
      } else if (XMLList(_libraryXML.libraryContentInfo).length() > 1) {
         bError = true;
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_LIBRARY_CONTENT_INFO_NODES);
      }
      if (XMLList(_libraryXML.libraryContentInfo[0].singleLanguageLessonInfo).length() > 1) {
         bError = true;
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_SINGLE_LANGUAGE_LESSON_INFO_NODES);
      }
      if (XMLList(_libraryXML.libraryContentInfo[0].singleLanguageLessonInfo).length() == 1) {
         if (XMLList(_libraryXML.libraryContentInfo[0].singleLanguageLessonInfo[0].languages).length() > 1) {
            bError = true;
            techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_LANGUAGES_NODES_IN_SINGLE_LANGUAGE_LESSON_INFO_NODE);
         }
      }
      if (XMLList(_libraryXML.libraryContentInfo[0].dualLanguageLessonInfo).length() > 1) {
         bError = true;
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_DUAL_LANGUAGE_LESSON_INFO_NODES);
      }
      if (XMLList(_libraryXML.libraryContentInfo[0].dualLanguageLessonInfo).length() == 1) {
         if (XMLList(_libraryXML.libraryContentInfo[0].dualLanguageLessonInfo[0].languagePairs).length() > 1) {
            bError = true;
            techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_LANGUAGE_PAIRS_NODES_IN_DUAL_LANGUAGE_LESSON_INFO_NODE);
         }
         if (XMLList(_libraryXML.libraryContentInfo[0].dualLanguageLessonInfo[0].languagePairs).length() == 1) {
            for each (var languagePairNode:XML in _libraryXML.libraryContentInfo[0].dualLanguageLessonInfo[0].languagePairs[0].languagePair) {
               if (XMLList(languagePairNode.nativeLanguage).length() < 1) {
                  bError = true;
                  techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MISSING_NATIVE_LANGUAGE_NODE);
               } else if (XMLList(languagePairNode.nativeLanguage).length() > 1) {
                  bError = true;
                  techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_NATIVE_LANGUAGE_NODES);
               }
               if (XMLList(languagePairNode.targetLanguage).length() < 1) {
                  bError = true;
                  techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MISSING_TARGET_LANGUAGE_NODE);
               } else if (XMLList(languagePairNode.targetLanguage).length() > 1) {
                  bError = true;
                  techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__MULTIPLE_TARGET_LANGUAGE_NODES);
               }
            }
         }
      }
      if (!getCurrNativeLanguageLanguageNodeOrEnglishLanguageNodeFromLibraryXML()) {
         techReport.problemDescriptionList.push(Command_DownloadLibraryInfoTechReport.PROB_DESC__REPOS_XML__NO_NATIVE_LANGUAGE_NODE_IS_CURR_NATIVE_LANGUAGE_OR_ENGLISH);
         bError = true;
      }
      return (!bError);
   }
}
}


