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
package com.langcollab.languagementor.controller
{
    import com.brightworks.base.Callbacks;
    import com.brightworks.event.BwEvent;
    import com.brightworks.util.Log;
    import com.brightworks.util.Utils_Dispose;
    import com.brightworks.util.Utils_String;
    import com.brightworks.util.Utils_System;
    import com.brightworks.util.Utils_URL;
    import com.brightworks.util.download.FileSetDownloader;
    import com.brightworks.util.download.FileSetDownloaderErrorReport;
    import com.brightworks.util.download.FileSetDownloaderFileInfo;
    import com.brightworks.util.download.FileSetDownloaderFilesInfo;
    import com.langcollab.languagementor.model.ConfigFileInfoTechReport;
    import com.langcollab.languagementor.model.MainModelDBOperationReport;
    import com.langcollab.languagementor.vo.LibraryVO;

    import flash.events.TimerEvent;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    public class Command_UpdateLibraryInfoBase extends Command_Base__LangMentor
    {
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__MULTIPLE_LIBRARY_NODES_IN_DUAL_LANGUAGE_LESSON_INFO_NODE:String = "problemDescription_LanguageSpecificInfoFile_DualLanguage_MultipleLibraryNodesInDualLanguageLessonInfoNode";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__MULTIPLE_DUAL_LANGUAGE_LESSON_INFO_NODES:String = "problemDescription_LanguageSpecificInfoFile_DualLanguage_MultipleDualLanguageLessonInfoNodes";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__MULTIPLE_LIBRARY_NODES_IN_SINGLE_LANGUAGE_LESSON_INFO_NODE:String = "problemDescription_LanguageSpecificInfoFile_DualLanguage_MultipleLibraryNodesInSingleLanguageLessonInfoNode";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__MULTIPLE_SINGLE_LANGUAGE_LESSON_INFO_NODES:String = "problemDescription_LanguageSpecificInfoFile_DualLanguage_MultipleSingleLanguageLessonInfoNodes";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__NO_LIBRARY_NODE_IN_DUAL_LANGUAGE_LESSON_INFO_NODE:String = "problemDescription_LanguageSpecificInfoFile_DualLanguage_NoLibraryNodeInDualLanguageLessonInfoNode";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__NO_DUAL_LANGUAGE_LESSON_INFO_NODE:String = "problemDescription_LanguageSpecificInfoFile_DualLanguage_NoDualLanguageLessonInfoNode";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__NO_LIBRARY_NODE_IN_SINGLE_LANGUAGE_LESSON_INFO_NODE:String = "problemDescription_LanguageSpecificInfoFile_DualLanguage_NoLibraryNodeInSingleLanguageLessonInfoNode";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__NO_SINGLE_LANGUAGE_LESSON_INFO_NODE:String = "problemDescription_LanguageSpecificInfoFile_DualLanguage_NoSingleLanguageLessonInfoNode";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__LIBRARY_NODE_DOES_NOT_HAVE_EXACTLY_ONE_LIBRARY_URL_NODE:String = "problemDescription_LanguageSpecificInfoFile_LibraryNodeDoesNotHaveExactlyOneLibraryUrlNode";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__LIBRARY_URL_NODE_CONTAINS_MALFORMED_URL:String = "problemDescription_LanguageSpecificInfoFile_LibraryUrlNodeContainsMalformedUrl";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__SINGLE_LANGUAGE__MULTIPLE_LIBRARY_NODES_IN_SINGLE_LANGUAGE_LESSON_INFO_NODE:String = "problemDescription_LanguageSpecificInfoFile_SingleLanguage_MultipleLibraryNodesInSingleLanguageLessonInfoNode";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__SINGLE_LANGUAGE__MULTIPLE_SINGLE_LANGUAGE_LESSON_INFO_NODES:String = "problemDescription_LanguageSpecificInfoFile_SingleLanguage_MultipleSingleLanguageLessonInfoNodes";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__SINGLE_LANGUAGE__NO_LIBRARY_NODE_IN_SINGLE_LANGUAGE_LESSON_INFO_NODE:String = "problemDescription_LanguageSpecificInfoFile_SingleLanguage_NoLibraryNodeInSingleLanguageLessonInfoNode";
        public static const PROB_DESC__LANG_SPECIFIC_INFO_FILE__SINGLE_LANGUAGE__NO_SINGLE_LANGUAGE_LESSON_INFO_NODE:String = "problemDescription_LanguageSpecificInfoFile_SingleLanguage_NoSingleLanguageLessonInfoNode";
        public static const STATUS__DOWNLOADING_LANGUAGE_SPECIFIC_INFO_FILES:String = "status_DownloadingLanguageSpecificInfoFiles";
        public static const STATUS__DOWNLOADING_LIBRARY_AND_LESSON_INFO_FILES:String = "status_DownloadingLibraryAndLessonInfoFiles";
        public static const STATUS__PARSING_LANGUAGE_SPECIFIC_INFO_FILES:String = "status_ParsingLanguageSpecificInfoFiles";
        public static const STATUS__WAITING_FOR_CONFIG_FILE_INFO_LOAD:String = "status_WaitingForConfigFileInfoLoad";

        protected static const LIBRARY_STATUS__FAILURE:String = "libaryStatus_Failure";
        protected static const LIBRARY_STATUS__STARTED:String = "libaryStatus_Started";
        protected static const LIBRARY_STATUS__SUCCESS:String = "libaryStatus_Success";

        private static const _TIMER_TIMEOUT_MS:int = 30000;

        public var status:String;
        public var techReport:Command_UpdateLibraryInfoBaseTechReport;

        protected var includeLessonInfo:Boolean = false;
        protected var includeRecommendedLibraries:Boolean = false;
        protected var includeUserAddedLibraries:Boolean = false;

        private var _downloadFailureCount:uint = 0;
        private var _index_LibraryFolderUrls_To_LibraryInfoDownloadStati:Dictionary = new Dictionary();
        private var _isDisposed:Boolean = false;
        private var _languageSpecificInfoFilesDownloader:FileSetDownloader;
        private var _languageSpecificInfoFileXML_DualLanguage:XML;
        private var _languageSpecificInfoFileXML_SingleLanguage:XML;

        // --------------------------------------------
        //
        //           Public Methods
        //
        // --------------------------------------------

        public function Command_UpdateLibraryInfoBase()
        {
            super();
            Log.debug("Command_UpdateLibraryInfoBase constructor - class has XML props");
        }

        public function abort():void
        {
            dispose();
        }

        override public function dispose():void
        {
            Log.debug("Command_UpdateLibraryInfoBase.dispose() - class has XML props");
            super.dispose();
            if (_isDisposed)
                return;
            _isDisposed = true;
            model = null;
            stopTimeoutTimer();
            if (_index_LibraryFolderUrls_To_LibraryInfoDownloadStati)
            {
                Utils_Dispose.disposeDictionary(_index_LibraryFolderUrls_To_LibraryInfoDownloadStati, true);
                _index_LibraryFolderUrls_To_LibraryInfoDownloadStati = null;
            }
            if (_languageSpecificInfoFilesDownloader)
            {
                _languageSpecificInfoFilesDownloader.dispose();
                _languageSpecificInfoFilesDownloader = null;
            }
        }

        public function execute():void
        {
            Log.info("Command_UpdateLibraryInfoBase.execute()");
            if (_isDisposed)
                return;
            if (model.configFileInfo.isDataLoaded_MentorTypeFile)
            {
                startLanguageSpecificInfoFileDownloads();
            }
            else
            {
                Log.info("Command_UpdateLibraryInfoBase.execute(): Starting config data load");
                var callbacks:Callbacks = new Callbacks(onLoadConfigInfoComplete, onLoadConfigInfoFailure);
                model.configFileInfo.loadData(callbacks);
                status = STATUS__WAITING_FOR_CONFIG_FILE_INFO_LOAD;
                startOrRestartTimeoutTimer(_TIMER_TIMEOUT_MS, onTimeoutTimerComplete);
            }
        }

        // --------------------------------------------
        //
        //           Protected Methods
        //
        // --------------------------------------------

        protected function reportResultsAndDispose():void
        {
            Log.debug("Command_UpdateLibraryInfoBase.reportResultsAndDispose()");
            if (_isDisposed)
                return;
            // We're reporting results in a general sense, but useful "success" data is stored
            // in the model and not reported here. 
            result(techReport);
            dispose();
        }

        protected function startLanguageSpecificInfoFileDownloads():void
        {
            Log.debug("Command_UpdateLibraryInfoBase.startLanguageSpecificInfoFileDownloads()");
            if (_isDisposed)
                return;
            Log.info("Command_UpdateLibraryInfoBase.startLanguageSpecificInfoFileDownloads() - not disposed yet");
            _downloadFailureCount = 0;
            _languageSpecificInfoFilesDownloader = createLanguageSpecificInfoFilesDownloader();
            _languageSpecificInfoFilesDownloader.addEventListener(BwEvent.COMPLETE, onLanguageSpecificInfoFilesDownloadComplete);
            _languageSpecificInfoFilesDownloader.addEventListener(BwEvent.FAILURE, onLanguageSpecificInfoFilesDownloadFailure);
            Log.debug("Command_UpdateLibraryInfoBase.startLanguageSpecificInfoFileDownloads(): starting languageSpecificInfoFilesDownloader");
            _languageSpecificInfoFilesDownloader.start();
            status = STATUS__DOWNLOADING_LANGUAGE_SPECIFIC_INFO_FILES;
            startOrRestartTimeoutTimer(_TIMER_TIMEOUT_MS, onTimeoutTimerComplete);
        }

        // --------------------------------------------
        //
        //           Private Methods
        //
        // --------------------------------------------

        private function addNonDuplicateLibraryURLsFromDBToArray(passedArray:Array):void
        {
            var modelReport:MainModelDBOperationReport = model.selectData("Command_UpdateLibraryInfoBase.addNonDuplicateLibraryURLsFromDBToArray", new LibraryVO());
            if (modelReport.isAnyProblems)
            {
                Log.error(["Command_UpdateLibraryInfoBase.addNonDuplicateLibraryURLsFromDBToArray(): DB operation problem", modelReport]);
                return;
            }
            for each (var libraryVO:LibraryVO in modelReport.resultData)
            {
                var url:String = libraryVO.libraryFolderURL;
                url = Utils_String.ensureStringEndsWith(url, "/");
                if (Utils_System.isRunningOnDesktop())
                    url = Utils_URL.convertUrlToDesktopServerUrl(url);
                if (passedArray.indexOf(url) == -1)
                    passedArray.push(url);
            }
            modelReport.dispose();
        }

        private function addNonDuplicateLibraryURLsFromLanguageSpecificInfoFileLibraryNodesToArray(libraryNodeList:XMLList, passedArray:Array):void
        {
            var libraryNode:XML;
            var libraryUrl:String;
            for each (libraryNode in libraryNodeList)
            {
                if (libraryNode.libraryURL.length() != 1)
                {
                    techReport.problemDescriptionList.push(Command_UpdateLibraryInfoBase.PROB_DESC__LANG_SPECIFIC_INFO_FILE__LIBRARY_NODE_DOES_NOT_HAVE_EXACTLY_ONE_LIBRARY_URL_NODE + ": " + libraryNode.toString());
                    continue;
                }
                libraryUrl = libraryNode.libraryURL[0].toString();
                if (!Utils_URL.isUrlProperlyFormed(libraryUrl))
                {
                    techReport.problemDescriptionList.push(Command_UpdateLibraryInfoBase.PROB_DESC__LANG_SPECIFIC_INFO_FILE__LIBRARY_URL_NODE_CONTAINS_MALFORMED_URL + ": " + libraryNode.libraryURL[0].toString());
                    continue;
                }
                if (Utils_System.isRunningOnDesktop())
                {
                    libraryUrl = Utils_URL.convertUrlToDesktopServerUrl(libraryUrl);
                }
                libraryUrl = Utils_String.ensureStringEndsWith(libraryUrl, "/");
                if (passedArray.indexOf(libraryUrl) == -1)
                    passedArray.push(libraryUrl);
            }
        }

        private function createLanguageSpecificInfoFilesDownloader():FileSetDownloader
        {
            var result:FileSetDownloader = new FileSetDownloader(true);
            var filesInfo:FileSetDownloaderFilesInfo = new FileSetDownloaderFilesInfo();
            result.filesInfo = filesInfo;
            var singleLanguageFileInfo:FileSetDownloaderFileInfo = new FileSetDownloaderFileInfo();
            var dualLanguageFileInfo:FileSetDownloaderFileInfo = new FileSetDownloaderFileInfo();
            singleLanguageFileInfo.fileNameBody = getLanguageSpecificInfoFileName_SingleLanguage();
            dualLanguageFileInfo.fileNameBody = getLanguageSpecificInfoFileName_DualLanguage();
            for each (var fileInfo:FileSetDownloaderFileInfo in[singleLanguageFileInfo, dualLanguageFileInfo])
            {
                fileInfo.fileFolderURL = model.getURL_MainConfigFolder();
                fileInfo.fileNameExtension = "xml";
                filesInfo.addFileInfo(fileInfo.fileNameBody, fileInfo);
            }
            return result;
        }

        private function getLanguageSpecificInfoFileName_DualLanguage():String
        {
            var result:String = model.getTargetLanguageIso639_3Code() + "_" + model.getNativeLanguageIso639_3Code();
            return result;
        }

        private function getLanguageSpecificInfoFileName_SingleLanguage():String
        {
            var result:String = model.getTargetLanguageIso639_3Code();
            return result;
        }

        private function onLanguageSpecificInfoFilesDownloadComplete(event:BwEvent):void
        {
            model.downloadBandwidthRecorder.reportFileSetDownloader(_languageSpecificInfoFilesDownloader);
            if (_isDisposed)
                return;
            Log.debug("Command_UpdateLibraryInfoBase.onLanguageSpecificInfoFilesDownloadComplete()");
            processLanguageInfoFilesAndStartLibraryInfoDownload(FileSetDownloader(event.target).filesInfo);
        }

        private function onLanguageSpecificInfoFilesDownloadFailure(event:BwEvent):void
        {
            model.downloadBandwidthRecorder.reportFileSetDownloader(_languageSpecificInfoFilesDownloader);
            if (_isDisposed)
                return;
            Log.info("Command_UpdateLibraryInfoBase.onLanguageSpecificInfoFilesDownloadFailure()");
            processLanguageInfoFilesAndStartLibraryInfoDownload(FileSetDownloader(event.target).filesInfo, FileSetDownloaderErrorReport(event.techReport));
        }

        private function onLibraryInfoDownloadComplete(report:Command_DownloadLibraryInfoTechReport):void
        {
            if (_isDisposed)
                return;
            Log.debug("Command_UpdateLibraryInfoBase.onLibraryInfoDownloadComplete()");
            // We can have a lesson info download count of 0 in cases where the library is listed and checked, but
            // no lessons are in the lesson list.
            _index_LibraryFolderUrls_To_LibraryInfoDownloadStati[report.libraryFolderUrl] = LIBRARY_STATUS__SUCCESS;
            techReport.list_TechReports_AllLibraryInfoDownloads.push(report);
            reportResultsIfDone();
        }

        private function onLibraryInfoDownloadFailure(report:Command_DownloadLibraryInfoTechReport):void
        {
            if (_isDisposed)
                return;
            Log.info(["Command_UpdateLibraryInfoBase.onLibraryInfoDownloadFailure()", report]);
            // Download process may have been partially successful
            // Command_DownloadLibraryInfo has stored all useful data in model
            _index_LibraryFolderUrls_To_LibraryInfoDownloadStati[report.libraryFolderUrl] = LIBRARY_STATUS__FAILURE;
            techReport.list_TechReports_AllLibraryInfoDownloads.push(report);
            techReport.list_TechReports_ProblematicLibraryInfoDownloads.push(report);
            reportResultsIfDone();
        }

        private function onLoadConfigInfoComplete(report:ConfigFileInfoTechReport):void
        {
            if (_isDisposed)
                return;
            Log.debug("Command_UpdateLibraryInfoBase.onLoadConfigInfoComplete()");
            startLanguageSpecificInfoFileDownloads();
        }

        private function onLoadConfigInfoFailure(report:ConfigFileInfoTechReport):void
        {
            if (_isDisposed)
                return;
            Log.info("Command_UpdateLibraryInfoBase.onLoadConfigInfoFailure()");
            techReport.isLoadConfigFileInfoFailure = true;
            techReport.configFileInfoTechReport = report;
            reportResultsAndDispose();
        }

        private function onTimeoutTimerComplete(event:TimerEvent):void
        {
            if (_isDisposed)
                return;
            Log.debug("Command_UpdateLibraryInfoBase.onTimeoutTimerComplete()");
            techReport.isProcessTimedOut = true;
            techReport.list_LibraryURLs_UnfinishedLibraryInfoDownloadsAtTimeout = new Vector.<String>();
            for (var libraryFolderUrl:String in _index_LibraryFolderUrls_To_LibraryInfoDownloadStati)
            {
                var downloadStatus:String = _index_LibraryFolderUrls_To_LibraryInfoDownloadStati[libraryFolderUrl];
                if (downloadStatus == LIBRARY_STATUS__STARTED)
                {
                    techReport.list_LibraryURLs_UnfinishedLibraryInfoDownloadsAtTimeout.push(libraryFolderUrl);
                }
            }
            reportResultsAndDispose();
        }

        private function processLanguageInfoFilesAndStartLibraryInfoDownload(filesInfo:FileSetDownloaderFilesInfo, fileSetDownloaderErrorReport:FileSetDownloaderErrorReport = null):void
        {
            Log.info("Command_UpdateLibraryInfoBase.processLanguageInfoFilesAndStartLibraryInfoDownload()");
            status = STATUS__PARSING_LANGUAGE_SPECIFIC_INFO_FILES;
            if (fileSetDownloaderErrorReport)
            {
                techReport.index_languageSpecificFileName_to_fileDownloaderErrorReport = fileSetDownloaderErrorReport.index_fileId_to_fileDownloaderErrorReport;
            }
            var libraryUrlList:Array = [];
            if (includeRecommendedLibraries)
            {
                var fileData:ByteArray;
                var libraryNodeList:XMLList;
                var singleLanguageFileInfo:FileSetDownloaderFileInfo = filesInfo.getFileInfo(getLanguageSpecificInfoFileName_SingleLanguage());
                if (singleLanguageFileInfo.fileData)
                {
                    fileData = singleLanguageFileInfo.fileData;
                    if ((fileData) && (validateAndPopulateLanguageSpecificInfoFileXML_Single(fileData)))
                    {
                        libraryNodeList = _languageSpecificInfoFileXML_SingleLanguage.singleLanguageLessonInfo[0].libraries[0].library;
                        addNonDuplicateLibraryURLsFromLanguageSpecificInfoFileLibraryNodesToArray(libraryNodeList, libraryUrlList);
                    }
                    else
                    {
                        techReport.isLanguageSpecificInfoFileXMLParsingFailure_SingleLanguage = true;
                    }
                }
                else
                {
                    techReport.isLanguageSpecificInfoFileDownloadFailure_SingleLanguage = true;
                }
                var dualLanguageFileInfo:FileSetDownloaderFileInfo = filesInfo.getFileInfo(getLanguageSpecificInfoFileName_DualLanguage());
                if (dualLanguageFileInfo.fileData)
                {
                    fileData = dualLanguageFileInfo.fileData;
                    if ((fileData) && (validateAndPopulateLanguageSpecificInfoFileXML_Dual(fileData)))
                    {
                        libraryNodeList = _languageSpecificInfoFileXML_DualLanguage.singleLanguageLessonInfo[0].libraries[0].library;
                        addNonDuplicateLibraryURLsFromLanguageSpecificInfoFileLibraryNodesToArray(libraryNodeList, libraryUrlList);
                        libraryNodeList = _languageSpecificInfoFileXML_DualLanguage.dualLanguageLessonInfo[0].libraries[0].library;
                        addNonDuplicateLibraryURLsFromLanguageSpecificInfoFileLibraryNodesToArray(libraryNodeList, libraryUrlList);
                    }
                    else
                    {
                        techReport.isLanguageSpecificInfoFileXMLParsingFailure_DualLanguage = true;
                    }
                }
                else
                {
                    techReport.isLanguageSpecificInfoFileDownloadFailure_DualLanguage = true;
                }
                filesInfo.dispose();
            }
            if (includeUserAddedLibraries)
                addNonDuplicateLibraryURLsFromDBToArray(libraryUrlList);
            if (libraryUrlList.length == 0)
            {
                reportResultsAndDispose();
                return;
            }
            _downloadFailureCount = 0;
            _index_LibraryFolderUrls_To_LibraryInfoDownloadStati = new Dictionary();
            for each (var libraryFolderUrl:String in libraryUrlList)
            {
                var cb:Callbacks = new Callbacks(onLibraryInfoDownloadComplete, onLibraryInfoDownloadFailure);
                var c:Command_DownloadLibraryInfo = new Command_DownloadLibraryInfo(libraryFolderUrl, includeLessonInfo, cb);
                c.execute();
                _index_LibraryFolderUrls_To_LibraryInfoDownloadStati[libraryFolderUrl] = LIBRARY_STATUS__STARTED;
            }
            status = STATUS__DOWNLOADING_LIBRARY_AND_LESSON_INFO_FILES;
            startOrRestartTimeoutTimer(_TIMER_TIMEOUT_MS, onTimeoutTimerComplete);
        }

        private function reportResultsIfDone():void
        {
            Log.debug("Command_UpdateLibraryInfoBase.reportResultsIfDone()");
            if (_isDisposed)
                return;
            var isDone:Boolean = true;
            for (var libraryFolderUrl:String in _index_LibraryFolderUrls_To_LibraryInfoDownloadStati)
            {
                var downloadStatus:String = _index_LibraryFolderUrls_To_LibraryInfoDownloadStati[libraryFolderUrl];
                if (downloadStatus == LIBRARY_STATUS__STARTED)
                {
                    isDone = false;
                    break;
                }
            }
            if (isDone)
            {
                reportResultsAndDispose();
            }
        }

        private function validateAndPopulateLanguageSpecificInfoFileXML_Dual(fileData:ByteArray):Boolean
        {
            try
            {
                _languageSpecificInfoFileXML_DualLanguage = new XML(String(fileData));
            }
            catch (error:TypeError)
            {
                techReport.problemDescriptionList.push(error.message);
                return false;
            }
            var bError:Boolean = false;
            if (XMLList(_languageSpecificInfoFileXML_DualLanguage.dualLanguageLessonInfo).length() < 1)
            {
                bError = true;
                techReport.problemDescriptionList.push(PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__NO_DUAL_LANGUAGE_LESSON_INFO_NODE);
            }
            else if (XMLList(_languageSpecificInfoFileXML_DualLanguage.dualLanguageLessonInfo).length() > 1)
            {
                bError = true;
                techReport.problemDescriptionList.push(PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__MULTIPLE_DUAL_LANGUAGE_LESSON_INFO_NODES);
            }
            else
            {
                if (XMLList(_languageSpecificInfoFileXML_DualLanguage.dualLanguageLessonInfo[0].libraries).length() < 1)
                {
                    bError = true;
                    techReport.problemDescriptionList.push(PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__NO_LIBRARY_NODE_IN_DUAL_LANGUAGE_LESSON_INFO_NODE);
                }
                else if (XMLList(_languageSpecificInfoFileXML_DualLanguage.dualLanguageLessonInfo[0].libraries).length() > 1)
                {
                    bError = true;
                    techReport.problemDescriptionList.push(PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__MULTIPLE_LIBRARY_NODES_IN_DUAL_LANGUAGE_LESSON_INFO_NODE);
                }
            }
            if (XMLList(_languageSpecificInfoFileXML_DualLanguage.singleLanguageLessonInfo).length() < 1)
            {
                bError = true;
                techReport.problemDescriptionList.push(PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__NO_SINGLE_LANGUAGE_LESSON_INFO_NODE);
            }
            else if (XMLList(_languageSpecificInfoFileXML_DualLanguage.singleLanguageLessonInfo).length() > 1)
            {
                bError = true;
                techReport.problemDescriptionList.push(PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__MULTIPLE_SINGLE_LANGUAGE_LESSON_INFO_NODES);
            }
            else
            {
                if (XMLList(_languageSpecificInfoFileXML_DualLanguage.singleLanguageLessonInfo[0].libraries).length() < 1)
                {
                    bError = true;
                    techReport.problemDescriptionList.push(PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__NO_LIBRARY_NODE_IN_SINGLE_LANGUAGE_LESSON_INFO_NODE);
                }
                else if (XMLList(_languageSpecificInfoFileXML_DualLanguage.singleLanguageLessonInfo[0].libraries).length() > 1)
                {
                    bError = true;
                    techReport.problemDescriptionList.push(PROB_DESC__LANG_SPECIFIC_INFO_FILE__DUAL_LANGUAGE__MULTIPLE_LIBRARY_NODES_IN_SINGLE_LANGUAGE_LESSON_INFO_NODE);
                }
            }
            return !bError;
        }

        private function validateAndPopulateLanguageSpecificInfoFileXML_Single(fileData:ByteArray):Boolean
        {
            try
            {
                _languageSpecificInfoFileXML_SingleLanguage = new XML(String(fileData));
            }
            catch (error:TypeError)
            {
                techReport.problemDescriptionList.push(error.message);
                return false;
            }
            var bError:Boolean = false;
            if (XMLList(_languageSpecificInfoFileXML_SingleLanguage.singleLanguageLessonInfo).length() < 1)
            {
                bError = true;
                techReport.problemDescriptionList.push(PROB_DESC__LANG_SPECIFIC_INFO_FILE__SINGLE_LANGUAGE__NO_SINGLE_LANGUAGE_LESSON_INFO_NODE);
            }
            else if (XMLList(_languageSpecificInfoFileXML_SingleLanguage.singleLanguageLessonInfo).length() > 1)
            {
                bError = true;
                techReport.problemDescriptionList.push(PROB_DESC__LANG_SPECIFIC_INFO_FILE__SINGLE_LANGUAGE__MULTIPLE_SINGLE_LANGUAGE_LESSON_INFO_NODES);
            }
            else
            {
                if (XMLList(_languageSpecificInfoFileXML_SingleLanguage.singleLanguageLessonInfo[0].libraries).length() < 1)
                {
                    bError = true;
                    techReport.problemDescriptionList.push(PROB_DESC__LANG_SPECIFIC_INFO_FILE__SINGLE_LANGUAGE__NO_LIBRARY_NODE_IN_SINGLE_LANGUAGE_LESSON_INFO_NODE);
                }
                else if (XMLList(_languageSpecificInfoFileXML_SingleLanguage.singleLanguageLessonInfo[0].libraries).length() > 1)
                {
                    bError = true;
                    techReport.problemDescriptionList.push(PROB_DESC__LANG_SPECIFIC_INFO_FILE__SINGLE_LANGUAGE__MULTIPLE_LIBRARY_NODES_IN_SINGLE_LANGUAGE_LESSON_INFO_NODE);
                }
            }
            return !bError;
        }

    }
}


