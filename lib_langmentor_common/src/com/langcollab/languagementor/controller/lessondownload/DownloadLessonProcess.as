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
   import com.brightworks.component.mobilealert.MobileAlert;
   import com.brightworks.db.SQLiteQueryData_Insert;
   import com.brightworks.event.BwEvent;
   import com.brightworks.interfaces.IDisposable;
   import com.brightworks.util.IPercentCompleteReporter;
   import com.brightworks.util.Log;
   import com.brightworks.util.Utils_ArrayVectorEtc;
   import com.brightworks.util.Utils_DateTime;
   import com.brightworks.util.Utils_Dispose;
   import com.brightworks.util.Utils_String;
   import com.brightworks.util.Utils_System;
   import com.brightworks.util.audio.FileSetMP3DataExtractor;
   import com.brightworks.util.audio.FileSetMP3Saver;
   import com.brightworks.util.audio.FileSetMP3SaverTechReport;
   import com.brightworks.util.audio.MP3FileInfo;
   import com.brightworks.util.download.FileDownloader;
   import com.brightworks.util.download.FileDownloaderErrorReport;
   import com.brightworks.vo.IVO;
   import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
   import com.langcollab.languagementor.controller.Command_DeleteLessonVersion;
   import com.langcollab.languagementor.controller.Command_DeleteLessonVersionTechReport;
   import com.langcollab.languagementor.controller.audio.AudioController;
   import com.langcollab.languagementor.model.MainModel;
   import com.langcollab.languagementor.model.MainModelDBOperationReport;
   import com.langcollab.languagementor.model.currentlessons.CurrentLessons;
   import com.langcollab.languagementor.util.Utils_LangCollab;
   import com.langcollab.languagementor.view.View_PlayLessons;
   import com.langcollab.languagementor.vo.ChunkFileVO;
   import com.langcollab.languagementor.vo.ChunkVO;
   import com.langcollab.languagementor.vo.LessonVersionNativeLanguageVO;
   import com.langcollab.languagementor.vo.LessonVersionTargetLanguageVO;
   import com.langcollab.languagementor.vo.LessonVersionVO;

   import deng.fzip.FZip;
   import deng.fzip.FZipErrorEvent;
   import deng.fzip.FZipFile;

   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Timer;

   import mx.binding.utils.BindingUtils;
   import mx.binding.utils.ChangeWatcher;
   import mx.collections.ArrayCollection;
   import mx.collections.Sort;
   import mx.collections.SortField;
   import mx.core.FlexGlobals;

   import spark.components.ViewNavigatorApplication;

   public class DownloadLessonProcess extends EventDispatcher implements IPercentCompleteReporter, IDisposable {
      public static const STATUS__COMPLETE:String = "Complete";
      public static const STATUS__DISPOSED:String = "Disposed";
      public static const STATUS__DELETING_LESSON:String = "Deleting Lesson";
      public static const STATUS__DOWNLOADING:String = "Downloading";
      public static const STATUS__EXTRACTING_MP3_DATA:String = "Extract MP3 Data";
      public static const STATUS__FAILED:String = "Failed";
      public static const STATUS__SAVING_DATA_TO_DB:String = "Saving To DB";
      public static const STATUS__SAVING_MP3_FILES:String = "Saving Mp3 Files";
      public static const STATUS__UNZIPPING:String = "Unzipping";
      public static const STATUS__VERSION_UPGRADE_STUFF:String = "Version Upgrade Stuff";
      public static const STATUS__WAITING:String = "Waiting";


      public var currentLessons:CurrentLessons;
      public var downloadLessonProcessInfo:DownloadLessonProcessInfo;
      public var techReport:DownloadLessonProcessTechReport;

      private var _alertDisplayTimer:Timer;
      // 	_alphabetizedChunkFileNameRootList is a temp list that looks like this:
      //								[
      //									"abcd001",
      //									"abcd002",
      //									"abcd003",
      //									etc...
      //								],
      private var _alphabetizedChunkFileNameRootList:ArrayCollection;
      private var _audioController:AudioController = AudioController.getInstance();
      private var _downloadedZippedFileData:ByteArray;
      private var _fileDownloader:FileDownloader;
      private var _fileSetMP3DDataExtractor:FileSetMP3DataExtractor;
      private var _fileSetMP3Saver:FileSetMP3Saver;
      private var _fileUnzipper:FZip;
      private var _index_fileNameRoot_to_chunkXMLNode:Dictionary = new Dictionary();
      private var _isDisposed:Boolean;
      private var _isUpdateOfPreviouslyDownloadedLesson:Boolean;
      private var _lessonDownloadController:LessonDownloadController = LessonDownloadController.getInstance();
      private var _lessonVersionSignature:String;
      private var _model:MainModel = MainModel.getInstance();
      private var _queuedProcessFunction:Function;
      private var _queuedProcessFunctionTimer:Timer;
      private var _unzipFailureCount:int = 0;
      // _unzippedAudioFileDataList:
      //     - props  = file IDs
      //     - values = MP3FileInfo instances
      //     - created after zip file is unzipped - MP3FileInfo.fileName, .fileFolder and 
      //       .mp3FormattedByteData are set at this point
      //     - used in 'save files' process - data isn't changed, just saved to hard disk
      //     - used in 'extract data' process - MP3FileInfo.milliseconds
      //       are set at this point
      private var _unzippedAudioFileDataList:Dictionary;
      private var _watcher_PauseStart:ChangeWatcher; /// kludge

      // ---------------------------------------------------------
      //
      //         Getters / Setter
      //
      // ---------------------------------------------------------

      private var _status:String;

      private function get status():String {
         return _status;
      }

      private function set status(value:String):void {
         _status = value;
         if ((_model) && (Utils_System.isAlphaVersion()))
            _model.mostRecentDownloadLessonProcessStatus = value;
      }

      // ---------------------------------------------------------
      //
      //         Public Methods
      //
      // ---------------------------------------------------------

      public function DownloadLessonProcess() {
         super();
      }

      public function dispose():void {
         if (_isDisposed)
            return;
         _isDisposed = true;
         // techReport should be disposed by client code
         techReport = null;
         if (_audioController) {
            _audioController = null;
         }
         _model = null;
         _downloadedZippedFileData = null;
         if (_fileDownloader) {
            _fileDownloader.dispose();
            _fileDownloader = null;
         }
         if (_fileSetMP3DDataExtractor) {
            _fileSetMP3DDataExtractor.dispose();
            _fileSetMP3DDataExtractor = null;
         }
         if (_fileSetMP3Saver) {
            _fileSetMP3Saver.dispose();
            _fileSetMP3Saver = null;
         }
         if (_index_fileNameRoot_to_chunkXMLNode) {
            Utils_Dispose.disposeDictionary(_index_fileNameRoot_to_chunkXMLNode, true);
         }
         _queuedProcessFunction = null;
         if (_unzippedAudioFileDataList) {
            Utils_Dispose.disposeDictionary(_unzippedAudioFileDataList, true);
            _unzippedAudioFileDataList = null;
         }
         if (_watcher_PauseStart) {
            _watcher_PauseStart.unwatch();
            _watcher_PauseStart = null;
         }
         cleanupFileUnzipper();
         status = STATUS__DISPOSED;
      }

      public function getPercentComplete():int {
         if (isCompleteOrFailed()) {
            return 100;
         } else if (_fileDownloader.getPercentComplete() < 100) {
            return Math.floor(_fileDownloader.getPercentComplete() * .75);
         } else {
            return 75;
         }
      }

      public function isCompleteOrFailed():Boolean {
         return ((status == STATUS__COMPLETE) || (status == STATUS__FAILED));
      }

      public function get lessonVersionSignature():String {
         if (downloadLessonProcessInfo.isAlphaReviewVersion)
            return "AlphaReview_" + downloadLessonProcessInfo.downloadFileNameBody;
         var result:String;
         switch (status) {
            case STATUS__COMPLETE:
            case STATUS__SAVING_DATA_TO_DB:  {
               if (_lessonVersionSignature == null) {
                  _lessonVersionSignature = Utils_LangCollab.computeLessonVersionSignature(_unzippedAudioFileDataList);
               }
               result = _lessonVersionSignature;
               break;
            }
            default:  {
               result = null;
            }
         }
         return result;
      }

      public function start():void {
         Log.info("DownloadLessonProcess.start() - " + downloadLessonProcessInfo.publishedLessonVersionId);
         status = STATUS__WAITING;
         techReport = new DownloadLessonProcessTechReport();
         techReport.downloadLessonProcessInfo = downloadLessonProcessInfo;
         techReport.time_StartEntireProcess = Utils_DateTime.getCurrentMS_AppActive();
         techReport.contentProviderId = downloadLessonProcessInfo.contentProviderId;
         techReport.downloadFileExtension = downloadLessonProcessInfo.downloadFileNameExtension;
         techReport.downloadURLRoot = downloadLessonProcessInfo.downloadFolderURL;
         techReport.isAlphaReviewVersion = downloadLessonProcessInfo.isAlphaReviewVersion;
         techReport.publishedLessonVersionId = downloadLessonProcessInfo.publishedLessonVersionId;
         populateChunkInfo();
         if (downloadLessonProcessInfo.isAlphaReviewVersion) {
            initProcessFunctionProcess(startProcess_VersionUpgradeStuff);
         } else {
            /// kludge
            _watcher_PauseStart = BindingUtils.bindSetter(onDownloadProcessStartAllowedEvent, _model, "mostRecentDownloadProcessStartAllowedEventTime");
            initProcessFunctionProcess(startProcess_LessonFileDownload);
         }
      }

      // ---------------------------------------------------------
      //
      //         Private Methods
      //
      // ---------------------------------------------------------

      private function callQueuedProcessFunctionIfAllowed(event:Event = null):void {
         if (_isDisposed)
            return;
         var isAllowed:Boolean = true;
         if (currentLessons.isLessonPlaying) {
            if (event is TimerEvent) {
               // Audio is playing, and we're not in playbackMode, so we allow the call at the start of 'pause' leafs,
               // but not when pinged by the timer.
               isAllowed = currentLessons.isLessonPaused;
            }
         }
         if (isAllowed) {
            if (_queuedProcessFunctionTimer) {
               _queuedProcessFunctionTimer.stop();
               _queuedProcessFunctionTimer.removeEventListener(TimerEvent.TIMER, callQueuedProcessFunctionIfAllowed);
               _queuedProcessFunctionTimer = null;
            } else {
               // We've come here by way of a 'pause start' ...
            }
            _queuedProcessFunction();
         }
      }

      private function checkChunkInfoConsistencyAndOrPopulateLists():Boolean {
         var isError:Boolean = false;
         var isFileNameAndChunkXMLConsistencyError:Boolean = false;
         var isFileNameConsistencyError:Boolean = false;
         var isFileNamingError:Boolean = false;
         var isUnallowedLanguageFileError:Boolean = false;
         var langCode_Native:String = downloadLessonProcessInfo.iso639_3Code_NativeLanguage;
         var langCode_Target:String = downloadLessonProcessInfo.iso639_3Code_TargetLanguage;
         var chunkFileNameRootList_FromNativeLangFiles:ArrayCollection = new ArrayCollection();
         var chunkFileNameRootList_FromTargetLangFiles:ArrayCollection = new ArrayCollection();
         var nameRootListList:Array = [_alphabetizedChunkFileNameRootList, chunkFileNameRootList_FromNativeLangFiles, chunkFileNameRootList_FromTargetLangFiles];
         for each (var nameRootList:ArrayCollection in nameRootListList) {
            var sort:Sort = new Sort();
            sort.fields = [new SortField(null, true)];
            nameRootList.sort = sort;
            nameRootList.refresh();
         }
         for (var fileName:String in _unzippedAudioFileDataList) {
            var minimumFileNameLength:uint = Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_LANGUAGE_CODE_LENGTH + Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_EXTENSION.length + 3;
            if (fileName.length < minimumFileNameLength) {
               isError = true;
               isFileNamingError = true;
               techReport.errorData_InsuffientlyLongFileNameList.push(fileName);
               continue;
            }
            if (!Utils_String.isStringEndsWith(fileName, "." + Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_EXTENSION)) {
               isError = true;
               isFileNamingError = true;
               techReport.errorData_IncorrectFileNameList.push(fileName);
               continue;
            }
            var fileNameRoot:String = getFileNameRootFromFileName(fileName);
            var languageCodeSubstring:String = getLanguageCodeSubstringFromFileName(fileName);
            var isLanguageCodeSubstringNativeOrTargetLanguage:Boolean = false;
            if (languageCodeSubstring == langCode_Native) {
               isLanguageCodeSubstringNativeOrTargetLanguage = true;
               chunkFileNameRootList_FromNativeLangFiles.addItem(fileNameRoot);
            }
            if (languageCodeSubstring == langCode_Target) {
               isLanguageCodeSubstringNativeOrTargetLanguage = true;
               chunkFileNameRootList_FromTargetLangFiles.addItem(fileNameRoot);
            }
            if (!isLanguageCodeSubstringNativeOrTargetLanguage) {
               isError = true;
               isUnallowedLanguageFileError = true;
               techReport.errorData_UnallowedLanguageFileFileNameList.push(fileName);
            }
         }
         // dmccarroll 20120616
         // If chunks XML exists, and it has chunk nodes, each chunk node will have a fileNameRoot node 
         // This was confirmed before lesson download was started, in Command_DownloadLibraryInfo
         // Confirm that name roots in the chunk nodes match the name roots of actual files.
         // Search for another 'dmccarroll 20120616' comment if you'd like info on how and why we determine which 
         // types of text are available for lesson before we download the lesson file.
         // Of course, we didn't have the audio files at that point, so we need to make sure that the file 
         // names and the XML fileNameRoot info correlate correctly.
         if ((!isError) && (!downloadLessonProcessInfo.isAlphaReviewVersion) && (downloadLessonProcessInfo.isDualLanguage)) {
            var inconsistencyList:Array = [];
            if (!Utils_ArrayVectorEtc.isArrayCollectionsContainEqualItemsInSameOrder(chunkFileNameRootList_FromNativeLangFiles, chunkFileNameRootList_FromTargetLangFiles, inconsistencyList)) {
               isError = true;
               isFileNameConsistencyError = true;
               if (chunkFileNameRootList_FromNativeLangFiles.length != chunkFileNameRootList_FromTargetLangFiles.length) {
                  techReport.errorData_Inconsistencies_NativeAndTargetChunkFileNames = ["Lists are different lengths", chunkFileNameRootList_FromNativeLangFiles, chunkFileNameRootList_FromTargetLangFiles];
               } else {
                  techReport.errorData_Inconsistencies_NativeAndTargetChunkFileNames = inconsistencyList;
               }
            }
         }
         var isHasChunkXML:Boolean = isLessonHasChunkXML();
         if ((!isError) && isHasChunkXML) {
            inconsistencyList = [];
            if ((!downloadLessonProcessInfo.isAlphaReviewVersion) && 
               (!Utils_ArrayVectorEtc.isArrayCollectionsContainEqualItemsInSameOrder(_alphabetizedChunkFileNameRootList, chunkFileNameRootList_FromTargetLangFiles, inconsistencyList))) {
               isError = true;
               isFileNameAndChunkXMLConsistencyError = true;
               if (_alphabetizedChunkFileNameRootList.length != chunkFileNameRootList_FromTargetLangFiles.length) {
                  techReport.errorData_Inconsistencies_ChunkFileNameAndXML = ["Lists are different lengths", _alphabetizedChunkFileNameRootList, chunkFileNameRootList_FromTargetLangFiles];
               } else {
                  techReport.errorData_Inconsistencies_ChunkFileNameAndXML = inconsistencyList;
               }
            }
         }
         if (isError)
            techReport.isErrorReported = true;
         if (isFileNameAndChunkXMLConsistencyError)
            techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__AUDIO_FILE_NAME_AND_XML_CHUNK_CONSISTENCY);
         if (isFileNameConsistencyError)
            techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__AUDIO_FILE_NAME_CONSISTENCY);
         if (isFileNamingError)
            techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__AUDIO_FILE_NAMING);
         if (isUnallowedLanguageFileError)
            techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__UNALLOWED_LANGUAGE_FILE_INCLUDED);
         return !isError;
      }

      private function cleanupFileUnzipper():void {
         if (_fileUnzipper) {
            _fileUnzipper.removeEventListener(Event.COMPLETE, onUnzipComplete);
            _fileUnzipper.removeEventListener(FZipErrorEvent.PARSE_ERROR, onUnzipFailure);
            _fileUnzipper = null;
         }
         // Don't do this here - this is the data that we give to FileSetMP3Saver
         // Utils_Dispose.disposeDictionary(_unzippedAudioFileDataList);
         // _unzippedAudioFileDataList = null;
      }

      private function closeDownloadingPopup():void {
         MobileAlert.close(1000);
      }

      private function extractChunkInfoFromUnzippedFileDataList():Dictionary {
         // Format for result:
         //		{
         //			"0000000001.000" : 	{
         //									locationInOrder : 1,
         //                                  textNativeLanguage : "",
         //                                  textTargetLanguage : "",
         //                                  textTargetLanguagePhonetic : "",
         //									languageFileData :	{
         //															cmn: 	{
         //																		duration:	  2031,
         //																		languageCode: "cmn"
         //																	},
         //															eng: 	{
         //																		duration:	  1883,
         //																		languageCode: "eng"
         //																	}
         //														}
         //								},
         //			"0000000001.001" : 	{
         //									locationInOrder : 2,
         //                                  textNativeLanguage : "",
         //                                  textTargetLanguage : "",
         //                                  textTargetLanguagePhonetic : "",
         //									languageFileData :	{
         //															cmn: 	{
         //																		duration:	  3290,
         //																		languageCode: "cmn"
         //																	},
         //															eng: 	{
         //																		duration:	  3522,
         //																		languageCode: "eng"
         //																	}
         //														}
         //								},
         //			etc...
         //
         //

         var result:Dictionary = new Dictionary();
         var fileName:String;
         var fileNameRoot:String;
         for (fileName in _unzippedAudioFileDataList) {
            // File names are checked after unzipping in checkChunkInfoConsistencyAndOrPopulateLists()
            fileNameRoot = getFileNameRootFromFileName(fileName);
            if (!_alphabetizedChunkFileNameRootList.contains(fileNameRoot)) {
               _alphabetizedChunkFileNameRootList.addItem(fileNameRoot);
            }
         }
         var chunkCount:int = _alphabetizedChunkFileNameRootList.length;
         var chunkInfoObject:Object;
         var currentChunk:int;
         for (currentChunk = 0; currentChunk < chunkCount; currentChunk++) {
            fileNameRoot = _alphabetizedChunkFileNameRootList[currentChunk];
            chunkInfoObject = {locationInOrder: currentChunk + 1, languageFileData: {}}
            result[fileNameRoot] = chunkInfoObject;
            if (downloadLessonProcessInfo.isHasText_Native || downloadLessonProcessInfo.isHasText_Target || downloadLessonProcessInfo.isHasText_TargetPhonetic) {
               var chunkNode:XML = _index_fileNameRoot_to_chunkXMLNode[fileNameRoot];
               if (downloadLessonProcessInfo.isHasText_Native)
                  chunkInfoObject.textNativeLanguage = chunkNode.textNativeLanguage[0].toString();
               else
                  chunkInfoObject.textNativeLanguage = null;
               if (downloadLessonProcessInfo.isHasText_Target)
                  chunkInfoObject.textTargetLanguage = chunkNode.textTargetLanguage[0].toString();
               else
                  chunkInfoObject.textTargetLanguage = null;
               if (downloadLessonProcessInfo.isHasText_TargetPhonetic)
                  chunkInfoObject.textTargetLanguagePhonetic = chunkNode.textTargetLanguagePhonetic[0].toString();
               else
                  chunkInfoObject.textTargetLanguagePhonetic = null;
            }
         }
         var languageCode:String;
         var languageFileData:Object;
         for (fileName in _unzippedAudioFileDataList) {
            // File names are checked after unzipping in checkChunkInfoConsistencyAndOrPopulateLists()
            var oneFilesData:MP3FileInfo = _unzippedAudioFileDataList[fileName];
            fileNameRoot = Utils_String.removeCharsFromEndOfString(fileName, Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_LANGUAGE_CODE_LENGTH + Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_EXTENSION.length + 2);
            languageCode = extractLanguageCodeFromFullFileName(fileName);
            if (!oneFilesData.duration is int)
               return null;
            languageFileData = result[fileNameRoot].languageFileData;
            languageFileData[languageCode] = {duration: oneFilesData.duration, languageCode: languageCode}
         }
         return result;
      }

      private function extractLanguageCodeFromFullFileName(fileName:String):String {
         var startIndex:int = fileName.length - (Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_LANGUAGE_CODE_LENGTH + Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_EXTENSION.length + 1);
         var endIndex:int = fileName.length - (Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_EXTENSION.length + 1);
         var result:String = fileName.substring(startIndex, endIndex);
         return result;
      }

      private function getAllVOs():Array {
         var result:Array = [];
         var chunkInfoDict:Dictionary = extractChunkInfoFromUnzippedFileDataList();
         if (!chunkInfoDict)
            return null;
         result.push(getLessonVersionVO());
         result = result.concat(getLessonVersionNativeLanguageVOs(chunkInfoDict));
         result = result.concat(getLessonVersionTargetLanguageVOs(chunkInfoDict));
         result = result.concat(getChunkAndChunkFileVOs(chunkInfoDict));
         return result;
      }

      private function getChunkAndChunkFileVOs(chunkInfoDict:Dictionary):Array {
         var result:Array = [];
         var chunkInfo:Object;
         var chunkVO:ChunkVO;
         var chunkFileVO:ChunkFileVO;
         var fileNameRoot:String;
         var languageCode:String;
         var languageFileInfo:Object;
         for (fileNameRoot in chunkInfoDict) {
            chunkInfo = chunkInfoDict[fileNameRoot];
            chunkVO = new ChunkVO();
            result.push(chunkVO);
            chunkVO.contentProviderId = downloadLessonProcessInfo.contentProviderId;
            chunkVO.fileNameRoot = fileNameRoot;
            chunkVO.locationInOrder = chunkInfo.locationInOrder;
            chunkVO.lessonVersionSignature = lessonVersionSignature;
            chunkVO.textNativeLanguage = chunkInfo.textNativeLanguage;
            chunkVO.textTargetLanguage = chunkInfo.textTargetLanguage;
            chunkVO.textTargetLanguagePhonetic = chunkInfo.textTargetLanguagePhonetic;
            for each (languageFileInfo in chunkInfo.languageFileData) {
               chunkFileVO = new ChunkFileVO();
               result.push(chunkFileVO);
               languageCode = languageFileInfo.languageCode;
               chunkFileVO.chunkLocationInOrder = chunkInfo.locationInOrder;
               chunkFileVO.contentProviderId = downloadLessonProcessInfo.contentProviderId;
               chunkFileVO.duration = languageFileInfo.duration;
               chunkFileVO.iso639_3Code = languageCode;
               chunkFileVO.languageId = _model.getLanguageIdFromIso639_3Code(languageCode);
               chunkFileVO.lessonVersionSignature = lessonVersionSignature;
            }
         }
         return result;
      }

      private function getFileNameRootFromFileName(fileName:String):String {
         var result:String = Utils_String.removeCharsFromEndOfString(fileName, Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_LANGUAGE_CODE_LENGTH + Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_EXTENSION.length + 2);
         return result;
      }

      private function getLanguageCodeSubstringFromFileName(fileName:String):String {
         var fileExtensionLength:int = Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_EXTENSION.length;
         var languageCodeSubstringEndIndex:int = fileName.length - (fileExtensionLength + 1);
         var languageCodeSubstringStartIndex:int = languageCodeSubstringEndIndex - 3;
         var result:String = fileName.substring(languageCodeSubstringStartIndex, languageCodeSubstringEndIndex);
         return result;
      }

      private function getLessonVersionNativeLanguageVOs(chunkInfoDict:Dictionary):Array {
         var result:Array = [];
         var vo:LessonVersionNativeLanguageVO;
         vo = new LessonVersionNativeLanguageVO();
         vo.allChunksHaveAudioFile = isAllChunksHaveAudioFileForLanguage(downloadLessonProcessInfo.iso639_3Code_NativeLanguage, chunkInfoDict);
         vo.contentProviderId = downloadLessonProcessInfo.contentProviderId;
         vo.contentProviderName = downloadLessonProcessInfo.nativeLanguageContentProviderName;
         vo.creditsXML = downloadLessonProcessInfo.credits;
         vo.iso639_3Code = downloadLessonProcessInfo.iso639_3Code_NativeLanguage;
         vo.languageId = _model.getLanguageIdFromIso639_3Code(downloadLessonProcessInfo.iso639_3Code_NativeLanguage);
         vo.lessonName = downloadLessonProcessInfo.nativeLanguageLessonName;
         vo.lessonSortName = downloadLessonProcessInfo.nativeLanguageLessonSortName;
         vo.lessonVersionSignature = lessonVersionSignature;
         vo.libraryName = downloadLessonProcessInfo.nativeLanguageLibraryName;
         vo.description = downloadLessonProcessInfo.description;
         if (vo.allChunksHaveAudioFile) {
            vo.totalAudioFileDuration = getTotalAudioFileDurationForLanguage(downloadLessonProcessInfo.iso639_3Code_NativeLanguage, chunkInfoDict);
         }
         result.push(vo);
         return result;
      }

      private function getLessonVersionTargetLanguageVOs(chunkInfoDict:Dictionary):Array {
         var result:Array = [];
         var vo:LessonVersionTargetLanguageVO;
         vo = new LessonVersionTargetLanguageVO();
         vo.allChunksHaveAudioFile = isAllChunksHaveAudioFileForLanguage(downloadLessonProcessInfo.iso639_3Code_TargetLanguage, chunkInfoDict);
         vo.contentProviderId = downloadLessonProcessInfo.contentProviderId;
         vo.iso639_3Code = downloadLessonProcessInfo.iso639_3Code_TargetLanguage;
         vo.languageId = _model.getLanguageIdFromIso639_3Code(downloadLessonProcessInfo.iso639_3Code_TargetLanguage);
         vo.lessonVersionSignature = lessonVersionSignature;
         if (vo.allChunksHaveAudioFile) {
            vo.totalAudioFileDuration = getTotalAudioFileDurationForLanguage(downloadLessonProcessInfo.iso639_3Code_TargetLanguage, chunkInfoDict);
         }
         result.push(vo);
         return result;
      }

      private function getLessonVersionVO():LessonVersionVO {
         var vo:LessonVersionVO = new LessonVersionVO();
         vo.contentProviderId = downloadLessonProcessInfo.contentProviderId;
         vo.defaultTextDisplayTypeId = downloadLessonProcessInfo.defaultTextDisplayTypeId;
         vo.isAlphaReviewVersion = downloadLessonProcessInfo.isAlphaReviewVersion;
         vo.isDualLanguage = downloadLessonProcessInfo.isDualLanguage;
         vo.isHasText_DefaultTextDisplayType = downloadLessonProcessInfo.isHasText_DefaultTextDisplayType;
         vo.isHasText_Native = downloadLessonProcessInfo.isHasText_Native;
         vo.isHasText_Target = downloadLessonProcessInfo.isHasText_Target;
         vo.isHasText_TargetPhonetic = downloadLessonProcessInfo.isHasText_TargetPhonetic;
         vo.lessonVersionSignature = lessonVersionSignature;
         vo.levelId = downloadLessonProcessInfo.levelId;
         vo.nativeLanguageAudioVolumeAdjustmentFactor = downloadLessonProcessInfo.nativeLanguageAudioVolumeAdjustmentFactor;
         vo.publishedLessonVersionId = downloadLessonProcessInfo.publishedLessonVersionId;
         vo.publishedLessonVersionVersion = downloadLessonProcessInfo.publishedLessonVersionVersion;
         vo.targetLanguageAudioVolumeAdjustmentFactor = downloadLessonProcessInfo.targetLanguageAudioVolumeAdjustmentFactor;
         vo.uploaded = false;
         return vo;
      }

      private function getTotalAudioFileDurationForLanguage(iso639_3Code:String, chunkInfoDict:Dictionary):int {
         var result:int = 0;
         var chunkInfo:Object;
         for each (chunkInfo in chunkInfoDict) {
            result += chunkInfo.languageFileData[iso639_3Code].duration;
         }
         return result;
      }

      private function initProcessFunctionProcess(func:Function = null):void {
         _queuedProcessFunction = func;
         _queuedProcessFunctionTimer = new Timer(1000);
         _queuedProcessFunctionTimer.addEventListener(TimerEvent.TIMER, onQueuedProcessFunctionTimer);
         _queuedProcessFunctionTimer.start();
      }

      private function isAllChunksHaveAudioFileForLanguage(iso639_3Code:String, chunkInfoDict:Dictionary):Boolean {
         var chunkInfo:Object;
         for each (chunkInfo in chunkInfoDict) {
            if (!chunkInfo.languageFileData.hasOwnProperty(iso639_3Code))
               return false;
         }
         return true;
      }

      private function isLessonHasChunkXML():Boolean {
         if (!(downloadLessonProcessInfo.chunks is XML))
            return false;
         var result:Boolean = (XMLList(downloadLessonProcessInfo.chunks.chunk).length() > 0)
         return result;
      }

      private function onDownloadComplete(event:BwEvent):void {
         Log.debug("DownloadLessonProcess.onDownloadComplete() - " + downloadLessonProcessInfo.publishedLessonVersionId + " - create/start FZip instance");
         if (_isDisposed)
            return;
         if (_model.isDataWipeActivityBlockActive)
            return;
         techReport.duration_FileDownload = Utils_DateTime.getCurrentMS_AppActive() - techReport.time_StartFileDownload;
         techReport.zipFileSizeInBytes = FileDownloader(event.target).fileData.length;
         _downloadedZippedFileData = FileDownloader(event.target).fileData;
         status = STATUS__WAITING;
         initProcessFunctionProcess(startProcess_UnzipFile);
      }

      private function onDownloadFailure(event:BwEvent):void {
         Log.info("DownloadLessonProcess.onDownloadFailure() - " + downloadLessonProcessInfo.publishedLessonVersionId + " - reportFailed()");
         if (_isDisposed)
            return;
         techReport.isErrorReported = true;
         techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__DOWNLOAD_FAILED);
         techReport.errorData_FileDownloaderErrorReport = FileDownloaderErrorReport(event.techReport);
         reportFailed();
      }

      private function onDownloadProcessStartAllowedEvent(newValue:Date):void {
         if (_queuedProcessFunction is Function)
            callQueuedProcessFunctionIfAllowed();
      }

      private function onFileSetMP3DataExtractionComplete(event:BwEvent):void {
         Log.debug("DownloadLessonProcess.onFileSetMP3DataExtractionComplete() - " + downloadLessonProcessInfo.publishedLessonVersionId);
         if (_isDisposed)
            return;
         if (_model.isDataWipeActivityBlockActive)
            return;
         status = STATUS__WAITING;
         techReport.duration_ExtractMP3FileData = Utils_DateTime.getCurrentMS_AppActive() - techReport.time_StartExtractMP3FileData;
         initProcessFunctionProcess(startProcess_SaveDataToDB);
      }

      private function onFileSetMP3SaveComplete(event:BwEvent):void {
         Log.debug("DownloadLessonProcess.onFileSetMP3SaveComplete() - " + downloadLessonProcessInfo.publishedLessonVersionId);
         if (_isDisposed)
            return;
         if (_model.isDataWipeActivityBlockActive)
            return;
         status = STATUS__WAITING;
         techReport.duration_SaveMP3Files = Utils_DateTime.getCurrentMS_AppActive() - techReport.time_StartSaveMP3Files;
         initProcessFunctionProcess(startProcess_ExtractMP3FileData);
         //closeDownloadingPopup();
      }

      private function onFileSetMP3SaveFailure(event:BwEvent):void {
         Log.info("DownloadLessonProcess.onFileSetMP3SaveFailure() - " + downloadLessonProcessInfo.publishedLessonVersionId + " - reportFailed()");
         if (_isDisposed)
            return;
         techReport.isErrorReported = true;
         techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__SAVE_FILES_TO_DISK);
         techReport.errorData_FileSetMP3SaverTechReport = FileSetMP3SaverTechReport(event.techReport);
         reportFailed();
      }

      private function onQueuedProcessFunctionTimer(event:TimerEvent):void {
         if (_isDisposed)
            return;
         if (_queuedProcessFunction is Function)
            callQueuedProcessFunctionIfAllowed(event);
      }

      private function onUnzipComplete(event:Event):void {
         Log.debug("DownloadLessonProcess.onUnzipComplete() - " + downloadLessonProcessInfo.publishedLessonVersionId);
         if (_isDisposed)
            return;
         if (_model.isDataWipeActivityBlockActive)
            return;
         techReport.duration_UnzipFile = Utils_DateTime.getCurrentMS_AppActive() - techReport.time_StartUnzipFile;
         _unzippedAudioFileDataList = new Dictionary();
         var fileCount:int = _fileUnzipper.getFileCount();
         var fileName:String;
         var oneFilesInfo:MP3FileInfo;
         var i:int;
         var fzipFile:FZipFile;
         Log.debug("DownloadLessonProcess.onUnzipComplete(): fileCount = " + fileCount);
         for (i = 0; i < fileCount; i++) {
            fzipFile = _fileUnzipper.getFileAt(i);
            if (fzipFile.filename == downloadLessonProcessInfo.publishedLessonVersionId + ".xml")
               continue;
            if (fzipFile.filename.indexOf("__MACOSX/") != -1)  // Zipping files w/ Mac Archive utility causes this
               continue;
            fileName = fzipFile.filename;
            oneFilesInfo = new MP3FileInfo();
            oneFilesInfo.fileFolder = downloadLessonProcessInfo.saveFolderFilePath;
            oneFilesInfo.fileName = fileName;
            oneFilesInfo.mp3FormattedByteData = fzipFile.content;
            _unzippedAudioFileDataList[fileName] = oneFilesInfo;
         }
         cleanupFileUnzipper();
         if (!checkChunkInfoConsistencyAndOrPopulateLists()) {
            Log.info("DownloadLessonProcess.onUnzipComplete() - checkChunkInfoConsistencyAndOrPopulateLists() returned 'false'");
            reportFailed();
            _queuedProcessFunction = null;
            return;
         }
         status = STATUS__WAITING;
         initProcessFunctionProcess(startProcess_VersionUpgradeStuff);
      }

      private function onUnzipFailure(event:FZipErrorEvent):void {
         _unzipFailureCount++
         Log.info("DownloadLessonProcess.onUnzipFailure() #" + _unzipFailureCount + " - " + downloadLessonProcessInfo.publishedLessonVersionId + " - reportFailed()");
         if (_isDisposed)
            return;
         techReport.errorData_UnzipFailedErrorText = event.text;
         techReport.errorData_UnzipFailedErrorType = event.type;
         techReport.isErrorReported = true;
         techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__UNZIP_FAILED);
         reportFailed();
         cleanupFileUnzipper();
      }

      private function openDownloadingPopup():void {
         var message:String;
         if (status == STATUS__SAVING_DATA_TO_DB) {
            message = "Saving:\n";
         } else {
            message = 
               _isUpdateOfPreviouslyDownloadedLesson ?
               "Updating:\n" :
               "Downloading:\n";

         }
         message += downloadLessonProcessInfo.nativeLanguageLessonName;
         MobileAlert.open(message, false);
      }

      private function populateChunkInfo():void {
         _alphabetizedChunkFileNameRootList = new ArrayCollection();
         _index_fileNameRoot_to_chunkXMLNode = new Dictionary();
         var chunkNodeList:XMLList = downloadLessonProcessInfo.chunks.chunk;
         for each (var chunkNode:XML in chunkNodeList) {
            var fileNameRoot:String = chunkNode.fileNameRoot[0];
            _alphabetizedChunkFileNameRootList.addItem(fileNameRoot);
            _index_fileNameRoot_to_chunkXMLNode[fileNameRoot] = chunkNode;
         }
      }

      private function processLessonDescriptionNodeForStorageInVO(sNode:String):String {
         // If node content contains a link, extracted string will contain the enclosing tags
         sNode = Utils_String.replaceAll(sNode, "<description>", "");
         sNode = Utils_String.replaceAll(sNode, "</description>", "");
         sNode = Utils_String.removeLineBreaks(sNode);
         // We want to add underlining to links
         sNode = Utils_String.replaceAll(sNode, "<a", "<u><a ");
         sNode = Utils_String.replaceAll(sNode, "</a>", "</a></u>");
         // Some double spaces come through
         sNode = Utils_String.replaceAll(sNode, "  ", " ");
         return sNode;
      }

      private function reportComplete():void {
         closeDownloadingPopup();
         status = STATUS__COMPLETE;
         techReport.duration_EntireProcess = Utils_DateTime.getCurrentMS_AppActive() - techReport.time_StartEntireProcess;
         Log.info(["DownloadLessonProcess.reportComplete()", techReport]);
         downloadLessonProcessInfo.processSuccessful = true;
         dispatchEvent(new BwEvent(BwEvent.COMPLETE, techReport));
      }

      private function reportFailed():void {
         // methods that call this method should add error info to .techReport
         closeDownloadingPopup();
         status = STATUS__FAILED;
         techReport.duration_EntireProcess = Utils_DateTime.getCurrentMS_AppActive() - techReport.time_StartEntireProcess;
         Log.info(["DownloadLessonProcess.reportFailed()", techReport]);
         var e:BwEvent = new BwEvent(BwEvent.FAILURE, techReport);
         dispatchEvent(e);
      }

      private function startAlertDisplayTimer(callback:Function):void {
         _alertDisplayTimer = new Timer(500, 1);
         _alertDisplayTimer.addEventListener(TimerEvent.TIMER, callback);
         _alertDisplayTimer.start();
      }

      private function startProcess_ExtractMP3FileData():void {
         _queuedProcessFunction = null;
         if (_isDisposed)
            return;
         if (_model.isDataWipeActivityBlockActive)
            return;
         Log.debug("DownloadLessonProcess.startProcess_ExtractMP3FileData() - " + downloadLessonProcessInfo.publishedLessonVersionId);
         status = STATUS__EXTRACTING_MP3_DATA;
         techReport.time_StartExtractMP3FileData = Utils_DateTime.getCurrentMS_AppActive();
         _fileSetMP3DDataExtractor = new FileSetMP3DataExtractor();
         _fileSetMP3DDataExtractor.fileData = _unzippedAudioFileDataList;
         _fileSetMP3DDataExtractor.addEventListener(BwEvent.COMPLETE, onFileSetMP3DataExtractionComplete);
         var delay:uint =
            (ViewNavigatorApplication(FlexGlobals.topLevelApplication).navigator.activeView is View_PlayLessons) ?
            50 :
            150;
         _fileSetMP3DDataExtractor.start(delay);
      }

      private function startProcess_LessonFileDownload():void {
         _queuedProcessFunction = null;
         if (_isDisposed)
            return;
         if (_model.isDataWipeActivityBlockActive)
            return;
         Log.debug("DownloadLessonProcess.startProcess_LessonFileDownload() - " + downloadLessonProcessInfo.publishedLessonVersionId + " - create/start FileDownloader");
         status = STATUS__DOWNLOADING;
         techReport.time_StartFileDownload = Utils_DateTime.getCurrentMS_AppActive();
         _fileDownloader = new FileDownloader();
         _fileDownloader.downloadFolderURL = downloadLessonProcessInfo.downloadFolderURL;
         _fileDownloader.downloadFileName = downloadLessonProcessInfo.publishedLessonVersionId;
         _fileDownloader.downloadFileExtension = downloadLessonProcessInfo.downloadFileNameExtension;
         _fileDownloader.addEventListener(BwEvent.COMPLETE, onDownloadComplete);
         _fileDownloader.addEventListener(BwEvent.FAILURE, onDownloadFailure);
         Log.debug("DownloadLessonProcess.start(): starting _fileDownloader - " + _fileDownloader.fullFileURL);
         _fileDownloader.start();
      }

      private function startProcess_SaveDataToDB():void {
         _queuedProcessFunction = null;
         status = STATUS__SAVING_DATA_TO_DB;
         openDownloadingPopup();
         startAlertDisplayTimer(startProcess_SaveDataToDB_Continued);
      }

      private function startProcess_SaveDataToDB_Continued(event:TimerEvent):void {
         stopAlertDisplayTimer(startProcess_SaveDataToDB_Continued);
         if (_isDisposed)
            return;
         if (_model.isDataWipeActivityBlockActive)
            return;
         Log.debug("DownloadLessonProcess.startProcess_SaveDataToDB_Continued() - " + downloadLessonProcessInfo.publishedLessonVersionId);
         if (!_model.isDataInitialized) {
            // dmccarroll 20120704
            // This can happen if the user does a 'delete all data' operation while this download is in progress.
            Log.debug("DownloadLessonProcess.startProcess_SaveDataToDB_Continued() - model's data isn't initialized.");
            techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__SAVE_DATA_TO_DB__MODEL_DATA_NOT_INITIALIZED);
            status = STATUS__FAILED;
            reportFailed();
            return;
         }
         techReport.time_StartSaveDataToDB = Utils_DateTime.getCurrentMS_AppActive();
         var queryDataListForDB:Array = [];
         var queryDataVOList:Array = getAllVOs();
         if (!queryDataVOList) {
            techReport.isErrorReported = true;
            techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__GETALLVOS_FAILED);
            reportFailed();
            return;
         }
         for each (var queryDataVO:IVO in queryDataVOList) {
            var queryData:SQLiteQueryData_Insert = new SQLiteQueryData_Insert(queryDataVO, 1, 1);
            queryDataListForDB.push(queryData);
         }
         Log.debug("DownloadLessonrProcess.startProcess_SaveDataToDB_Continued(): sending " + String(queryDataListForDB.length) + " queries into DB");
         var modelReport:MainModelDBOperationReport = _model.insertData("DownloadLessonProcess.startProcess_SaveDataToDB_Continued", queryDataListForDB, downloadLessonProcessInfo.downloadFileNameBody);
         if (modelReport.isAnyProblems) {
            Log.info(["DownloadLessonProcess.startProcess_SaveDataToDB_Continued(): insertData() reports problem: " + downloadLessonProcessInfo.publishedLessonVersionId, modelReport]);
            techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__SAVE_DATA_TO_DB);
            techReport.errorData_MainModelDBOperationReport = modelReport;
            status = STATUS__FAILED;
            reportFailed();
         } else {
            Log.debug("DownloadLessonProcess.startProcess_SaveDataToDB_Continued() - insertData() reports success: " + downloadLessonProcessInfo.publishedLessonVersionId);
            _model.addLessonVersionVOToCache(getLessonVersionVO());
            status = STATUS__COMPLETE;
            techReport.duration_SaveDataToDB = Utils_DateTime.getCurrentMS_AppActive() - techReport.time_StartSaveDataToDB;
            modelReport.dispose();
            reportComplete();
         }
      }

      private function startProcess_SaveMP3Files():void {
         _queuedProcessFunction = null;
         if (_isDisposed)
            return;
         if (_model.isDataWipeActivityBlockActive)
            return;
         Log.debug("DownloadLessonProcess.startProcess_SaveMP3Files() - " + downloadLessonProcessInfo.publishedLessonVersionId);
         status = STATUS__SAVING_MP3_FILES;
         techReport.time_StartSaveMP3Files = Utils_DateTime.getCurrentMS_AppActive();
         _fileSetMP3Saver = new FileSetMP3Saver();
         _fileSetMP3Saver.fileData = _unzippedAudioFileDataList;
         _fileSetMP3Saver.addEventListener(BwEvent.COMPLETE, onFileSetMP3SaveComplete);
         _fileSetMP3Saver.addEventListener(BwEvent.FAILURE, onFileSetMP3SaveFailure);
         //openDownloadingPopup();
         var delay:uint =
            (ViewNavigatorApplication(FlexGlobals.topLevelApplication).navigator.activeView is View_PlayLessons) ?
            50 :
            150;
         _fileSetMP3Saver.start(delay);
      }

      private function startProcess_UnzipFile():void {
         _queuedProcessFunction = null;
         if (_isDisposed)
            return;
         if (_model.isDataWipeActivityBlockActive)
            return;
         Log.debug("DownloadLessonProcess.startProcess_UnzipFile() - " + downloadLessonProcessInfo.publishedLessonVersionId);
         status = STATUS__UNZIPPING;
         techReport.time_StartUnzipFile = Utils_DateTime.getCurrentMS_AppActive();
         _fileUnzipper = new FZip();
         _fileUnzipper.addEventListener(Event.COMPLETE, onUnzipComplete);
         _fileUnzipper.addEventListener(FZipErrorEvent.PARSE_ERROR, onUnzipFailure);
         _fileUnzipper.loadBytes(_downloadedZippedFileData);
         // We don't do this here, because this is a synchronous process, and by the time we set this to null, it holds
         // the next process function, so we thus be aborting the process.
         //_queuedProcessFunction = null;
      }

      private function startProcess_VersionUpgradeStuff():void {
         _queuedProcessFunction = null;
         openDownloadingPopup();
         startAlertDisplayTimer(startProcess_VersionUpgradeStuff_Continued);
      }

      private function startProcess_VersionUpgradeStuff_Continued(event:TimerEvent):void {
         stopAlertDisplayTimer(startProcess_VersionUpgradeStuff_Continued);
         if (_isDisposed)
            return;
         if (_model.isDataWipeActivityBlockActive)
            return;
         Log.debug("DownloadLessonProcess.startProcess_VersionUpgradeStuff_Continued() - " + downloadLessonProcessInfo.publishedLessonVersionId);
         closeDownloadingPopup();
         status = STATUS__VERSION_UPGRADE_STUFF;
         if (_model.autoDownloadLessons || _lessonDownloadController.isUserInitiatedDownloadProcessActive) {
            var existingLVVO:LessonVersionVO = _model.getSingleOrNoLessonVersionVOFromContentProviderIdAndPublishedLessonVersionId(downloadLessonProcessInfo.contentProviderId, downloadLessonProcessInfo.publishedLessonVersionId);
            if ((existingLVVO) && (!currentLessons.contains(existingLVVO))) {
               _isUpdateOfPreviouslyDownloadedLesson = true;
               techReport.isUpdateOfPreviouslyDownloadedLesson = true;
               techReport.time_StartDeleteExistingVersionOfLesson = Utils_DateTime.getCurrentMS_AppActive();
               var c:Command_DeleteLessonVersion = new Command_DeleteLessonVersion(existingLVVO);
               status = STATUS__DELETING_LESSON;
               var commandReport:Command_DeleteLessonVersionTechReport = c.execute();
               if (commandReport.isSuccess) {
                  if (_model.isDataWipeActivityBlockActive)
                     return;
                  Log.debug("DownloadLessonProcess.startProcess_VersionUpgradeStuff_Continued() - " + downloadLessonProcessInfo.publishedLessonVersionId + " - save MP3 files");
                  techReport.duration_DeleteExistingVersionOfLesson = Utils_DateTime.getCurrentMS_AppActive() - techReport.time_StartDeleteExistingVersionOfLesson;
                  closeDownloadingPopup();
                  status = STATUS__WAITING;
                  initProcessFunctionProcess(startProcess_SaveMP3Files);
                  commandReport.dispose();
               } else {
                  Log.info("DownloadLessonProcess.startProcess_VersionUpgradeStuff_Continued() - " + downloadLessonProcessInfo.publishedLessonVersionId + " - reportFailed()");
                  if (_isDisposed)
                     return;
                  techReport.isErrorReported = true;
                  techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__DELETE_EXISTING_VERSION_0F_LESSON_FAILED);
                  techReport.errorData_DeleteExistingLessonVersionTechReport = commandReport;
                  reportFailed();
               }
            } else if ((existingLVVO) && (currentLessons.contains(existingLVVO))) {
               // We checked for this before the download, but it appears that the user has selected this lesson while
               // the download was in progress  :)
               techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__USER_SELECTED_LESSON_WHILE_DOWNLOAD_IN_PROGRESS);
               reportFailed();
            } else {
               closeDownloadingPopup();
               status = STATUS__WAITING;
               initProcessFunctionProcess(startProcess_SaveMP3Files);
            }
         } else {
            techReport.errorTypeList.push(DownloadLessonProcessTechReport.ERROR__NEITHER_AUTO_DOWNLOAD_OR_USER_INITIATED_TRUE);
            reportFailed();
         }

      }

      private function stopAlertDisplayTimer(callback:Function):void {
         _alertDisplayTimer.stop();
         _alertDisplayTimer.removeEventListener(TimerEvent.TIMER, callback);
         _alertDisplayTimer = null;
      }

   }
}





















