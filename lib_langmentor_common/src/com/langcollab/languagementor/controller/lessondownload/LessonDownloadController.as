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
package com.langcollab.languagementor.controller.lessondownload
{
import com.brightworks.base.Callbacks;
import com.brightworks.component.mobilealert.MobileAlert;
import com.brightworks.constant.Constant_PlatformName;
import com.brightworks.event.BwEvent;
import com.brightworks.interfaces.IDisposable;
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_DataConversionComparison;
import com.brightworks.util.Utils_DateTime;
import com.brightworks.util.Utils_Dispose;
import com.brightworks.util.Utils_File;
import com.brightworks.util.Utils_System;
import com.brightworks.util.singleton.SingletonManager;
import com.langcollab.languagementor.constant.Constant_AppConfiguration;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.controller.Command_DownloadLessons;
import com.langcollab.languagementor.controller.Command_DownloadLessonsTechReport;
import com.langcollab.languagementor.controller.Command_DownloadLibraryInfoTechReport;
import com.langcollab.languagementor.controller.Command_GetRecommendedLibariesInfo;
import com.langcollab.languagementor.controller.Command_GetRecommendedLibariesInfoTechReport;
import com.langcollab.languagementor.controller.Command_UpdateAvailableLessonDownloadsInfo;
import com.langcollab.languagementor.controller.Command_UpdateAvailableLessonDownloadsInfoTechReport;
import com.langcollab.languagementor.model.LessonDownloadInfo_Lesson;
import com.langcollab.languagementor.model.LessonDownloadInfo_Libraries;
import com.langcollab.languagementor.model.LessonDownloadInfo_Library;
import com.langcollab.languagementor.model.MainModel;
import com.langcollab.languagementor.model.appstatepersistence.AppStatePersistenceManager;
import com.langcollab.languagementor.model.currentlessons.CurrentLessons;
import com.langcollab.languagementor.util.Utils_LangCollab;
import com.langcollab.languagementor.vo.LessonVersionVO;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.utils.Dictionary;
import flash.utils.Timer;

import mx.binding.utils.ChangeWatcher;
import mx.events.PropertyChangeEvent;

public class LessonDownloadController extends EventDispatcher implements IDisposable, IManagedSingleton
    {
        private static const _AUTO_DOWNLOAD_TIME_INTERVAL_MS:Number = 3600000; // One hour
        private static const _AUTO_DOWNLOAD_TIME_INTERVAL_MS__INITIAL:Number = 5000;
        private static const _AUTO_DOWNLOAD_TIME_INTERVAL_MS__ONGOING:Number = 180000;

        private static var _instance:LessonDownloadController;

        public var isAutoInitiatedDownloadProcessActive:Boolean;
        public var isUserInitiatedDownloadProcessActive:Boolean;
        public var lessonDownloadInfo_Libraries:LessonDownloadInfo_Libraries;
        public var successfulDownloadInfoList_NewDownloads:Array = [];
        public var successfulDownloadInfoList_Updates:Array = [];

        private var _appStatePersistenceManager:AppStatePersistenceManager;
        private var _autoDownloadTimer:Timer;
        private var _callback_CurrentView:Function;
        private var _currentCommand_DownloadLessons:Command_DownloadLessons;
        private var _currentCommand_GetRecommendedLibariesInfo:Command_GetRecommendedLibariesInfo;
        private var _currentCommand_UpdateAvailableLessonDownloadsInfo:Command_UpdateAvailableLessonDownloadsInfo;
        private var _currentLessons:CurrentLessons;
        private var _downloadLessonProcessesInfo:DownloadLessonProcessesInfo;
        private var _model:MainModel;
        private var _mostRecentDownloadLessonsTime:Date;
        private var _time_MostRecentLessonDownloadProcessCompletion:Number;
        private var _watcher_AutoDownloadLessons:ChangeWatcher;

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        //
        //          Getters & Setters
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        public static function get bandwidthThrottling_BytesAllowedPerTimePeriod():uint
        {
            var result:uint;
            switch (Utils_System.platformName)
            {
                case Constant_PlatformName.ANDROID:
                    result = Constant_AppConfiguration.BANDWIDTH_LIMITING__MEGABYTES_ALLOWED_PER_TIME_PERIOD__ANDROID * 1024 * 1024;
                    break;
                case Constant_PlatformName.IOS:
                    result = Constant_AppConfiguration.BANDWIDTH_LIMITING__MEGABYTES_ALLOWED_PER_TIME_PERIOD__IOS * 1024 * 1024;
                    break;
               case Constant_PlatformName.MAC:
               case Constant_PlatformName.WINDOWS_DESKTOP:
                    result = Constant_AppConfiguration.BANDWIDTH_LIMITING__MEGABYTES_ALLOWED_PER_TIME_PERIOD__DESKTOP * 1024 * 1024;
                    break;
                default:
                    Log.error("LessonDownloadController.get bandwidthThrottling_BytesAllowedPerTimePeriod(): No case for: " + Utils_System.platformName);
            }
            return result;
        }

        private var _currentLessonDownloadProcessResultsInfo:LessonDownloadController_LessonDownloadProcessResultsInfo;

        public function get currentLessonDownloadProcessResultsInfo():LessonDownloadController_LessonDownloadProcessResultsInfo
        {
            return _currentLessonDownloadProcessResultsInfo;
        }

        private var _isGetRecommendedLibrariesInfoProcessActive:Boolean;

        public function get isGetRecommendedLibrariesInfoProcessActive():Boolean
        {
            return _isGetRecommendedLibrariesInfoProcessActive;
        }

        private var _isLessonDownloadProcessActive:Boolean;

        public function get isLessonDownloadProcessActive():Boolean
        {
            return _isLessonDownloadProcessActive;
        }

        private var _isUpdateAvailableLessonDownloadsProcessActive:Boolean;

        public function get isUpdateAvailableLessonDownloadsProcessActive():Boolean
        {
            return _isUpdateAvailableLessonDownloadsProcessActive;
        }

        private var _mostRecentUpdateAvailableLessonDownloadsStartTime:Number;

        public function get mostRecentUpdateAvailableLessonDownloadsStartTime():Number
        {
            return _mostRecentUpdateAvailableLessonDownloadsStartTime;
        }

        private var _previousGetRecommendedLibrariesProcessResultsInfo:LessonDownloadController_GetRecommendedLibrariesInfoProcessResultsInfo;

        public function get previousGetRecommendedLibrariesProcessResultsInfo():LessonDownloadController_GetRecommendedLibrariesInfoProcessResultsInfo
        {
            return _previousGetRecommendedLibrariesProcessResultsInfo;
        }

        private var _previousLessonDownloadProcessResultsInfo:LessonDownloadController_LessonDownloadProcessResultsInfo;

        public function get previousLessonDownloadProcessResultsInfo():LessonDownloadController_LessonDownloadProcessResultsInfo
        {
            return _previousLessonDownloadProcessResultsInfo;
        }

        private var _previousUpdateAvailableLessonDownloadsProcessResultsInfo:LessonDownloadController_UpdateAvailableLessonDownloadsProcessResultsInfo;

        public function get previousUpdateAvailableLessonDownloadsProcessResultsInfo():LessonDownloadController_UpdateAvailableLessonDownloadsProcessResultsInfo
        {
            return _previousUpdateAvailableLessonDownloadsProcessResultsInfo;
        }

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        //
        //          Public Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        public function LessonDownloadController(manager:SingletonManager)
        {
            _instance = this;
        }

        public function abortAnyCurrentLessonDownloadProcessesAndRestartIfAppropriate():void
        {
            var userInitiatedProcessWasActive:Boolean = isUserInitiatedDownloadProcessActive;
            stopActiveLessonDownloadProcesses();
            if (userInitiatedProcessWasActive)
            {
                startUserInitiatedDownloadProcess();
            }
            else
            {
                if (_model.autoDownloadLessons)
                {
                    isAutoInitiatedDownloadProcessActive = true;
                    startUpdateAvailableLessonsProcess();
                }
            }
        }

        public function dispose():void
        {
            if (_autoDownloadTimer)
            {
                stopAutoDownloadTimer();
            }
            if (_watcher_AutoDownloadLessons)
            {
                _watcher_AutoDownloadLessons.unwatch();
                _watcher_AutoDownloadLessons = null;
            }
            if (lessonDownloadInfo_Libraries)
            {
                lessonDownloadInfo_Libraries.dispose();
                lessonDownloadInfo_Libraries = null;
            }
        }

        public function getHoursSinceLessonDownloadsCompleted():Number
        {
            if (_time_MostRecentLessonDownloadProcessCompletion == 0)
                return -1;
            var elapsedMS:Number = Utils_DateTime.getCurrentMS_BasedOnDate() - _time_MostRecentLessonDownloadProcessCompletion;
            var hours:Number = Utils_DateTime.convertMillisecondsToHours(elapsedMS);
            return hours;
        }

        public static function getInstance():LessonDownloadController
        {
            if (!(_instance))
                throw new Error("Singleton not initialized");
            return _instance;
        }

        public function init():void
        {
            if ((_model.autoDownloadLessons) && (isSufficientLessonStorageSpaceAvailable()))
                startAutoDownloadTimer();
        }

        public function initSingleton():void
        {
            _appStatePersistenceManager = AppStatePersistenceManager.getInstance();
            _currentLessons = CurrentLessons.getInstance();
            _model = MainModel.getInstance();
            _watcher_AutoDownloadLessons = ChangeWatcher.watch(_model, "autoDownloadLessons", onAutoDownloadLessonsChange);
        }

        public function isLessonDownloaded(lessonId:String, contentProviderId:String):Boolean
        {
            var allVOs:Array = _model.getLessonVersionVOs();
            var matchingVOs:Array = [];
            for each (var vo:LessonVersionVO in allVOs)
            {
                if (vo.contentProviderId != contentProviderId)
                    continue;
                if (vo.publishedLessonVersionId != lessonId)
                    continue;
                matchingVOs.push(vo);
            }
            if (matchingVOs.length == 0)
                return false;
            if (matchingVOs.length > 1)
            {
                // We have a problem. This should never happen. Command_DownloadLessons should be ensuring that previous versions are 
                // completely deleted before saving new versions.
                Log.error("LessonDownloadController.isLessonDownloaded(): Multiple lessons downloaded with matching contentProviderId (" + contentProviderId + ") and publishedLessonId (" + lessonId + ")");
            }
            return true;
        }

        public function isLessonEligibleForDownloading(lessonId:String, lessonVersion:String, contentProviderId:String, lessonLevel:uint):Boolean
        {
            //// also check that lesson xml file's level matches that in lesson_list
            if (!_model.isLessonLevelSelectedForDownloading(lessonLevel))
                return false;
            if (!isLessonDownloaded(lessonId, contentProviderId))
            {
                Log.info("LessonDownloadController.isLessonEligibleForDownloading(): (!isLessonDownloaded(lessonId, contentProviderId)) evaluates to true, so return true");
                return true;
            }
            var existingLVVO:LessonVersionVO = _model.getSingleOrNoLessonVersionVOFromContentProviderIdAndPublishedLessonVersionId(contentProviderId, lessonId);
            if (!existingLVVO)
            {
                // This indicates that getSingleLessonVersionVOFromContentProviderIdAndPublishedLessonVersionId() failed somehow
                // (it has already thrown a warning). We probably have two or more LessonVersions that match the passed values.
                return false;
            }
            if (_currentLessons.contains(existingLVVO))
            {
                return false;
            }
            else if (isLessonVersionPublishedVersionLessThan(existingLVVO, lessonVersion))
            {
                Log.info("LessonDownloadController.isLessonEligibleForDownloading(): (isLessonVersionPublishedVersionLessThan(existingLVVO, lessonVersion)) evaluates to true, so return true");
                return true;
            }
            else
            {
                return false;
            }
        }

        public function isLessonEligibleForDownloadingButCurrentlySelected(lessonId:String, lessonVersion:String, contentProviderId:String, lessonLevel:uint):Boolean
        {
            //// also check that lesson xml file's level matches that in lesson_list
            if (!_model.isLessonLevelSelectedForDownloading(lessonLevel))
                return false;
            if (!isLessonDownloaded(lessonId, contentProviderId))
            {
                Log.debug("LessonDownloadController.isLessonEligibleForDownloadingButCurrentlySelected(): (!isLessonDownloaded(lessonId, contentProviderId)) evaluates to true, so return false");
                return false;
            }
            var existingLVVO:LessonVersionVO = _model.getSingleOrNoLessonVersionVOFromContentProviderIdAndPublishedLessonVersionId(contentProviderId, lessonId);
            if (!existingLVVO)
            {
                // This indicates that getSingleLessonVersionVOFromContentProviderIdAndPublishedLessonVersionId() failed somehow
                // (it has already thrown a warning). We probably have two or more LessonVersions that match the passed values.
                return false;
            }
            if (!isLessonVersionPublishedVersionLessThan(existingLVVO, lessonVersion))
            {
                Log.debug("LessonDownloadController.isLessonEligibleForDownloadingButCurrentlySelected(): (!isLessonVersionPublishedVersionLessThan(existingLVVO, lessonVersion)) evaluates to true, so return false");
                return false;
            }
            else if (_currentLessons.contains(existingLVVO))
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public function isSufficientLessonStorageSpaceAvailable():Boolean
        {
            if (Utils_System.isRunningOnDesktop())
                return true;
            var exists:Boolean = Utils_File.ensureDirectoryExists(Utils_LangCollab.downloadedLessonsDirectoryURL);
            if (exists)
            {
                var result:Boolean = (Utils_File.getAvailableFileSystemSpace(Utils_LangCollab.downloadedLessonsDirectoryURL) > Utils_File.BYTES_IN_GIGABYTE);
                return result;
            }
            else
            {
                Log.error("LessonDownloadController.isSufficientLessonStorageSpaceAvailable(): Unable to ensure storage directory exists, so we can't measure available file system space");
                return false;
            }
        }

        public function startUserInitiatedGetRecommendedLibrariesInfoProcess():void
        {
            Log.info("LessonDownloadController.startUserInitiatedGetRecommendedLibrariesInfoProcess()");
            if (_isGetRecommendedLibrariesInfoProcessActive)
            {
                // This can, at least theoretically, happen if the process is slow, and the user is quick
                return;
            }
            if (_isUpdateAvailableLessonDownloadsProcessActive || _isLessonDownloadProcessActive)
            {
                // In both of these cases, the info that we're looking for is already being fetched, along with a lot of other info.
                return;
            }
            _isGetRecommendedLibrariesInfoProcessActive = true;
            lessonDownloadInfo_Libraries = new LessonDownloadInfo_Libraries();
            var cb:Callbacks = new Callbacks(onGetRecommendedLibrariesInfoResult);
            _currentCommand_GetRecommendedLibariesInfo = new Command_GetRecommendedLibariesInfo(cb);
            _currentCommand_GetRecommendedLibariesInfo.execute();
        }

        public function startUserInitiatedDownloadProcess():void
        {
            isUserInitiatedDownloadProcessActive = true;
            startUpdateAvailableLessonsProcess();
        }

        public function stopActiveLessonDownloadProcesses():void
        {
            if ((_currentCommand_DownloadLessons) && (_currentLessonDownloadProcessResultsInfo))
            {
                if (_previousLessonDownloadProcessResultsInfo)
                    _previousLessonDownloadProcessResultsInfo.dispose();
                _previousLessonDownloadProcessResultsInfo = _currentLessonDownloadProcessResultsInfo;
                _currentLessonDownloadProcessResultsInfo = null;
                _previousLessonDownloadProcessResultsInfo.command_DownloadLessonsResultsReport = _currentCommand_DownloadLessons.techReport;
                _previousLessonDownloadProcessResultsInfo.lessonCount_DownloadsAttempted = _currentCommand_DownloadLessons.techReport.downloadProcessCount_Started;
                _previousLessonDownloadProcessResultsInfo.lessonCount_DownloadsSucceeded = _currentCommand_DownloadLessons.techReport.downloadProcessCount_Succeeded;
                _previousLessonDownloadProcessResultsInfo.lessonCount_DownloadsFailed = _currentCommand_DownloadLessons.techReport.downloadProcessCount_Failed;
            }
            if (_currentCommand_DownloadLessons)
            {
                _currentCommand_DownloadLessons.abort();
                _currentCommand_DownloadLessons = null;
            }
            if (_currentCommand_UpdateAvailableLessonDownloadsInfo)
            {
                _currentCommand_UpdateAvailableLessonDownloadsInfo.abort();
                _currentCommand_UpdateAvailableLessonDownloadsInfo = null;
            }
            _isLessonDownloadProcessActive = false;
            _isUpdateAvailableLessonDownloadsProcessActive = false;
            isAutoInitiatedDownloadProcessActive = false;
            isUserInitiatedDownloadProcessActive = false;
        }

        public function wipeData():void
        {
            stopAutoDownloadTimer();
            stopActiveLessonDownloadProcesses();
            _mostRecentDownloadLessonsTime = null;
            if (_previousLessonDownloadProcessResultsInfo)
            {
                _previousLessonDownloadProcessResultsInfo.dispose();
                _previousLessonDownloadProcessResultsInfo = null;
            }
            Utils_Dispose.disposeArray(successfulDownloadInfoList_NewDownloads, true);
            Utils_Dispose.disposeArray(successfulDownloadInfoList_Updates, true);
        }

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        //
        //          Private Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        private function computeAvailableUndownloadedLessonCount():uint
        {
            var result:uint = 0;
            var index_libraryFolderURL_to_lessonDownloadInfo_library:Dictionary = lessonDownloadInfo_Libraries.index_libraryFolderURL_to_lessonDownloadInfo_library;
            for (var reposFolderURL:String in index_libraryFolderURL_to_lessonDownloadInfo_library)
            {
                var lessonDownloadInfo_Library:LessonDownloadInfo_Library = index_libraryFolderURL_to_lessonDownloadInfo_library[reposFolderURL];
                var contentProviderId:String = lessonDownloadInfo_Library.contentProviderId;
                for (var lessonId:String in lessonDownloadInfo_Library.index_LessonIds_To_LessonDownloadInfo_Lessons)
                {
                    var lessonDownloadInfo_Lesson:LessonDownloadInfo_Lesson = lessonDownloadInfo_Library.index_LessonIds_To_LessonDownloadInfo_Lessons[lessonId];
                    if (isLessonEligibleForDownloading(
                        lessonId, 
                        lessonDownloadInfo_Lesson.lessonPublishedLessonVersionVersion, 
                        lessonDownloadInfo_Library.contentProviderId, 
                        _model.getLevelIdFromLevelLabelToken(lessonDownloadInfo_Lesson.lessonLevelToken)))
                    {
                        result++;
                    }
                }
            }
            return result;
        }

        private function computeCheckedLibraryCount():uint
        {
            var result:uint = 0;
            var index_libraryFolderURL_to_lessonDownloadInfo_library:Dictionary = lessonDownloadInfo_Libraries.index_libraryFolderURL_to_lessonDownloadInfo_library;
            for (var reposFolderURL:String in index_libraryFolderURL_to_lessonDownloadInfo_library)
            {
                result ++;
            }
            return result;
        }

        /*private function getLessonFolderURL(libraryFolderUrl:String, lessonDownloadInfo_Lesson:LessonDownloadInfo_Lesson):String
        {
            /// 20120613 not being used - delete
            var result:String = libraryFolderUrl + _model.getTargetLanguageIso639_3Code();
            if (lessonDownloadInfo_Lesson.lessonIsDualLanguage)
                result += "_" + _model.getNativeLanguageIso639_3Code() + "/";
            return result;
        }*/

        private function isLessonVersionPublishedVersionLessThan(lvvo:LessonVersionVO, lessonVersion:String):Boolean
        {
            var result:Boolean = false;
            if (!Utils_DataConversionComparison.isANumberString(lessonVersion))
                Log.fatal("LessonVersionController.isLessonVersionPublishedVersionEqualToOrHigherThan(): lessonVersion arg doesn't convert to a number");
            if (Number(lvvo.publishedLessonVersionVersion) < Number(lessonVersion))
                result = true;
            return result;
        }

        private function isMatchingDownloadLessonProcessInfoInSuccessfulDownloadList(info:DownloadLessonProcessInfo, successList:Array):Boolean
        {
            // Note that this method has a fairly loose definition of 'matching'. We don't check the content provider. It's possible that two content providers will have
            // lessons with identical names in libraries with identical names. But this method is used as we're assembling data that will be used by View_NewDownloads, 
            // which also doesn't pay attention to content providers. Unless or until we refine that screen it's not useful to make this more complex.
            for each (var infoInList:DownloadLessonProcessInfo in successList)
            {
                if ((infoInList.nativeLanguageLessonName == info.nativeLanguageLessonName) &&
                    (infoInList.nativeLanguageLibraryName == info.nativeLanguageLibraryName))
                {
                    return true;
                }
            }
            return false;
        }

        private function onAutoDownloadLessonsChange(event:PropertyChangeEvent):void
        {
            if (!_model)
            {
                // This can occur when we first set up the binding
                return;
            }
            if (_model.autoDownloadLessons)
            {
                if (isSufficientLessonStorageSpaceAvailable())
                    startAutoDownloadTimer();
            }
            else
            {
                stopAutoDownloadTimer();
                if (isAutoInitiatedDownloadProcessActive)
                {
                    isAutoInitiatedDownloadProcessActive = false;
                    stopActiveLessonDownloadProcesses();
                }
                if (!isUserInitiatedDownloadProcessActive)
                {
                    _isUpdateAvailableLessonDownloadsProcessActive = false;
                    _isLessonDownloadProcessActive = false;
                }
            }
        }

        private function onAutoDownloadTimer(event:TimerEvent):void
        {
            Log.debug("LessonDownloadController.onAutoDownloadTimer()");
            if (!_model.isDataInitialized)
                return;
            _autoDownloadTimer.delay = _AUTO_DOWNLOAD_TIME_INTERVAL_MS__ONGOING;
            var isTimeToDoNewDownload:Boolean = true;
            if (_mostRecentDownloadLessonsTime)
            {
                if (Utils_DateTime.computeMillisecondsBeforePresent(_mostRecentDownloadLessonsTime) < _AUTO_DOWNLOAD_TIME_INTERVAL_MS)
                    isTimeToDoNewDownload = false;
            }
            if (isTimeToDoNewDownload && !isUserInitiatedDownloadProcessActive)
            {
                _mostRecentDownloadLessonsTime = new Date();
                isAutoInitiatedDownloadProcessActive = true;
                startUpdateAvailableLessonsProcess();
            }
        }

        private function onGetRecommendedLibrariesInfoResult(returnedTechReport:Command_GetRecommendedLibariesInfoTechReport):void
        {
            Log.info("LessonDownloadController.onGetRecommendedLibrariesInfoComplete()");
            _isGetRecommendedLibrariesInfoProcessActive = false;
            _currentCommand_GetRecommendedLibariesInfo.dispose();
            _currentCommand_GetRecommendedLibariesInfo = null;
            reportGetRecommendedLibrariesResults(returnedTechReport);
            dispatchEvent(new BwEvent(BwEvent.NEW_INFO));
        }

        private function onDownloadLessonsUpdate(results:Command_DownloadLessonsTechReport):void
        {
            Log.debug("LessonDownloadController.onDownloadLessonsUpdate()");
            _currentLessonDownloadProcessResultsInfo.command_DownloadLessonsResultsReport = results;
            _currentLessonDownloadProcessResultsInfo.lessonCount_DownloadsAttempted = results.downloadProcessCount_Started;
            _currentLessonDownloadProcessResultsInfo.lessonCount_DownloadsSucceeded = results.downloadProcessCount_Succeeded;
            _currentLessonDownloadProcessResultsInfo.lessonCount_DownloadsFailed = results.downloadProcessCount_Failed;
            if ((results.downloadProcessCount_Succeeded + results.downloadProcessCount_Failed) == results.downloadProcessCount_Started)
            {
                // All downloads have succeeded or failed
                if (_previousLessonDownloadProcessResultsInfo)
                    _previousLessonDownloadProcessResultsInfo.dispose();
                _previousLessonDownloadProcessResultsInfo = _currentLessonDownloadProcessResultsInfo;
                _currentLessonDownloadProcessResultsInfo = null;
                if (Log.isLoggingEnabled(Log.LOG_LEVEL__DEBUG))
                {
                    Log.debug(["LessonDownloadController.onDownloadLessonsUpdate(): download command's techReport:", results]);
                }
                isAutoInitiatedDownloadProcessActive = false;
                isUserInitiatedDownloadProcessActive = false;
                _isLessonDownloadProcessActive = false;
                _currentCommand_DownloadLessons.dispose();
                _currentCommand_DownloadLessons = null;
                _mostRecentDownloadLessonsTime = new Date();
                _time_MostRecentLessonDownloadProcessCompletion = Utils_DateTime.getCurrentMS_BasedOnDate();
                for each (var tr:DownloadLessonProcessTechReport in results.techReportList_DownloadProcessSuccesses)
                {
                    if (tr.isUpdateOfPreviouslyDownloadedLesson)
                    {
                        if (isMatchingDownloadLessonProcessInfoInSuccessfulDownloadList(tr.downloadLessonProcessInfo, successfulDownloadInfoList_NewDownloads))
                            continue;
                        if (isMatchingDownloadLessonProcessInfoInSuccessfulDownloadList(tr.downloadLessonProcessInfo, successfulDownloadInfoList_Updates))
                            continue;
                        successfulDownloadInfoList_Updates.push(tr.downloadLessonProcessInfo);
                    }
                    else
                    {
                        if (isMatchingDownloadLessonProcessInfoInSuccessfulDownloadList(tr.downloadLessonProcessInfo, successfulDownloadInfoList_NewDownloads))
                            continue;
                        successfulDownloadInfoList_NewDownloads.push(tr.downloadLessonProcessInfo);
                    }
                }
            }
            dispatchEvent(new BwEvent(BwEvent.NEW_INFO));
        }

        private function onUpdateAvailableLessonDownloadsInfoResult(returnedTechReport:Command_UpdateAvailableLessonDownloadsInfoTechReport):void
        {
            Log.info(["LessonDownloadController.onUpdateAvailableLessonDownloadsInfoResult()", returnedTechReport]);
            _isUpdateAvailableLessonDownloadsProcessActive = false;
            _currentCommand_UpdateAvailableLessonDownloadsInfo.dispose();
            _currentCommand_UpdateAvailableLessonDownloadsInfo = null;
            reportUpdateAvailableLessonDownloadsResults(returnedTechReport);
            MobileAlert.close(500);
            if ((_model.autoDownloadLessons || isUserInitiatedDownloadProcessActive) && (_previousUpdateAvailableLessonDownloadsProcessResultsInfo.availableUndownloadedLessonsCount > 0))
            {
                startLessonDownloadProcess();
            }
            dispatchEvent(new BwEvent(BwEvent.NEW_INFO));
        }

        private function reportGetRecommendedLibrariesResults(returnedTechReport:Command_GetRecommendedLibariesInfoTechReport):void
        {
            Log.info("LessonDownloadController.reportGetRecommendedLibrariesResults()");
            if (_previousGetRecommendedLibrariesProcessResultsInfo)
                _previousGetRecommendedLibrariesProcessResultsInfo.dispose();
            _previousGetRecommendedLibrariesProcessResultsInfo = new LessonDownloadController_GetRecommendedLibrariesInfoProcessResultsInfo();
            _previousGetRecommendedLibrariesProcessResultsInfo.command_GetRecommendedLibrariesInfoTechReport =
                returnedTechReport;
            if ((returnedTechReport.list_TechReports_ProblematicLibraryInfoDownloads) && (returnedTechReport.list_TechReports_ProblematicLibraryInfoDownloads.length > 0))
            {
                _previousGetRecommendedLibrariesProcessResultsInfo.problematicLibraryCount = 
                    Vector.<Command_DownloadLibraryInfoTechReport>(returnedTechReport.list_TechReports_ProblematicLibraryInfoDownloads).length;
                var problematicLibraryNameList:Array = [];
                for each (var downloadLibraryInfoErrorReport:Command_DownloadLibraryInfoTechReport in returnedTechReport.list_TechReports_ProblematicLibraryInfoDownloads)
                {
                    if (downloadLibraryInfoErrorReport.libraryName is String)
                    {
                        problematicLibraryNameList.push(downloadLibraryInfoErrorReport.libraryName);
                    }
                }
                _previousGetRecommendedLibrariesProcessResultsInfo.problematicLibraryNameList = 
                    problematicLibraryNameList;
            }
            _previousGetRecommendedLibrariesProcessResultsInfo.checkedLibraryCount = computeCheckedLibraryCount();
        }

        private function reportUpdateAvailableLessonDownloadsResults(returnedTechReport:Command_UpdateAvailableLessonDownloadsInfoTechReport):void
        {
            Log.info("LessonDownloadController.reportUpdateAvailableLessonDownloadsResults()");
            if (_previousUpdateAvailableLessonDownloadsProcessResultsInfo)
                _previousUpdateAvailableLessonDownloadsProcessResultsInfo.dispose();
            _previousUpdateAvailableLessonDownloadsProcessResultsInfo = new LessonDownloadController_UpdateAvailableLessonDownloadsProcessResultsInfo();
            _previousUpdateAvailableLessonDownloadsProcessResultsInfo.command_UpdateAvailableLessonDownloadsInfoTechReport = 
                returnedTechReport;
            _previousUpdateAvailableLessonDownloadsProcessResultsInfo.availableUndownloadedLessonsCount = 
                computeAvailableUndownloadedLessonCount();
            var downloadLibraryInfoTechReport:Command_DownloadLibraryInfoTechReport;
            for each (downloadLibraryInfoTechReport in returnedTechReport.list_TechReports_AllLibraryInfoDownloads)
            {
                _previousUpdateAvailableLessonDownloadsProcessResultsInfo.count_LessonUpdatesNotDownloadedBecauseInSelectedLessons +=
                    downloadLibraryInfoTechReport.count_LessonUpdatesNotDownloadedBecauseInSelectedLessons;
            }
            if ((returnedTechReport.list_TechReports_ProblematicLibraryInfoDownloads) && (returnedTechReport.list_TechReports_ProblematicLibraryInfoDownloads.length > 0))
            {
                _previousUpdateAvailableLessonDownloadsProcessResultsInfo.problematicLibraryCount = 
                    Vector.<Command_DownloadLibraryInfoTechReport>(returnedTechReport.list_TechReports_ProblematicLibraryInfoDownloads).length;
                var problematicLibraryNameList:Array = [];
                for each (downloadLibraryInfoTechReport in returnedTechReport.list_TechReports_ProblematicLibraryInfoDownloads)
                {
                    if (downloadLibraryInfoTechReport.libraryName is String)
                    {
                        problematicLibraryNameList.push(downloadLibraryInfoTechReport.libraryName);
                    }
                }
                _previousUpdateAvailableLessonDownloadsProcessResultsInfo.problematicLibraryNameList = 
                    problematicLibraryNameList;
            }
            _previousUpdateAvailableLessonDownloadsProcessResultsInfo.checkedLibraryCount = computeCheckedLibraryCount();
        }

        private function startAutoDownloadTimer():void
        {
            Log.debug("LessonDownloadController.startAutoDownloadTimer()");
            _autoDownloadTimer = new Timer(_AUTO_DOWNLOAD_TIME_INTERVAL_MS__INITIAL);
            _autoDownloadTimer.addEventListener(TimerEvent.TIMER, onAutoDownloadTimer);
            _autoDownloadTimer.start();
        }

        private function startLessonDownloadProcess():void
        {
            Log.info("LessonDownloadController.startLessonDownloadProcess()");
            if (_isLessonDownloadProcessActive)
            {
                Log.error("LessonDownloadController.startLessonDownload(): _isLessonDownloadProcessActive=true - client failed to check for this condition");
                return;
            }
            _isLessonDownloadProcessActive = true;
            _currentLessonDownloadProcessResultsInfo = new LessonDownloadController_LessonDownloadProcessResultsInfo();
            _currentLessonDownloadProcessResultsInfo.lessonCount_DownloadsAttempted = 0;
            _downloadLessonProcessesInfo = new DownloadLessonProcessesInfo();
            for (var reposFolderURL:String in lessonDownloadInfo_Libraries.index_libraryFolderURL_to_lessonDownloadInfo_library)
            {
                var lessonDownloadInfo_Library:LessonDownloadInfo_Library = lessonDownloadInfo_Libraries.index_libraryFolderURL_to_lessonDownloadInfo_library[reposFolderURL];
                var contentProviderId:String = lessonDownloadInfo_Library.contentProviderId;
                var nativeLanguageContentProviderName:String = lessonDownloadInfo_Library.contentProviderName;
                var nativeLanguageLibraryName:String = lessonDownloadInfo_Library.libraryName;
                var libraryId:String = lessonDownloadInfo_Library.libraryId;
                for (var lessonId:String in lessonDownloadInfo_Library.index_LessonIds_To_LessonDownloadInfo_Lessons)
                {
                    _currentLessonDownloadProcessResultsInfo.lessonCount_DownloadsAttempted++;
                    var downloadLessonProcessInfo:DownloadLessonProcessInfo = new DownloadLessonProcessInfo();
                    var lessonDownloadInfo_Lesson:LessonDownloadInfo_Lesson = lessonDownloadInfo_Library.index_LessonIds_To_LessonDownloadInfo_Lessons[lessonId];
                    downloadLessonProcessInfo.chunks = lessonDownloadInfo_Lesson.lessonChunks;
                    downloadLessonProcessInfo.contentProviderId = contentProviderId;
                    downloadLessonProcessInfo.credits = lessonDownloadInfo_Lesson.lessonCredits;
                    downloadLessonProcessInfo.defaultTextDisplayTypeId = lessonDownloadInfo_Lesson.lessonDefaultTextDisplayTypeId;
                    downloadLessonProcessInfo.description = lessonDownloadInfo_Lesson.lessonDescription;
                    downloadLessonProcessInfo.downloadFileNameBody = lessonId;
                    downloadLessonProcessInfo.downloadFileNameExtension = Constant_LangMentor_Misc.FILEPATHINFO__LESSON_COMPRESSED_FILE_EXTENSION;
                    downloadLessonProcessInfo.downloadFolderURL = lessonDownloadInfo_Lesson.lessonDownloadFolderURL;
                    downloadLessonProcessInfo.isAlphaReviewVersion = lessonDownloadInfo_Lesson.lessonIsAlphaReviewVersion;
                    downloadLessonProcessInfo.isDualLanguage = lessonDownloadInfo_Lesson.lessonIsDualLanguage;
                    downloadLessonProcessInfo.isHasText_DefaultTextDisplayType = lessonDownloadInfo_Lesson.lessonIsHasText_DefaultTextDisplayType;
                    downloadLessonProcessInfo.isHasText_Native = lessonDownloadInfo_Lesson.lessonIsHasText_Native;
                    downloadLessonProcessInfo.isHasText_Target = lessonDownloadInfo_Lesson.lessonIsHasText_Target;
                    downloadLessonProcessInfo.isHasText_TargetPhonetic = lessonDownloadInfo_Lesson.lessonIsHasText_TargetPhonetic;
                    downloadLessonProcessInfo.iso639_3Code_NativeLanguage = _model.getNativeLanguageIso639_3Code();
                    downloadLessonProcessInfo.iso639_3Code_TargetLanguage = _model.getTargetLanguageIso639_3Code();
                    downloadLessonProcessInfo.levelId = _model.getLevelIdFromLevelLabelToken(lessonDownloadInfo_Lesson.lessonLevelToken);
                    downloadLessonProcessInfo.levelLocationInLevelsOrder = _model.getLevelLocationInOrderFromLevelId(downloadLessonProcessInfo.levelId);
                    downloadLessonProcessInfo.nativeLanguageAudioVolumeAdjustmentFactor = lessonDownloadInfo_Lesson.lessonNativeLanguageAudioVolumeAdjustmentFactor;
                    downloadLessonProcessInfo.nativeLanguageContentProviderName = nativeLanguageContentProviderName;
                    downloadLessonProcessInfo.nativeLanguageLessonName = lessonDownloadInfo_Lesson.lessonName;
                    downloadLessonProcessInfo.nativeLanguageLessonSortName = lessonDownloadInfo_Lesson.lessonSortName;
                    downloadLessonProcessInfo.nativeLanguageLibraryName = nativeLanguageLibraryName;
                    downloadLessonProcessInfo.publishedLessonVersionId = lessonId;
                    downloadLessonProcessInfo.publishedLessonVersionVersion = lessonDownloadInfo_Lesson.lessonPublishedLessonVersionVersion;
                    downloadLessonProcessInfo.libraryId = libraryId;
                    downloadLessonProcessInfo.tags = lessonDownloadInfo_Lesson.lessonTags;
                    downloadLessonProcessInfo.targetLanguageAudioVolumeAdjustmentFactor = lessonDownloadInfo_Lesson.lessonTargetLanguageAudioVolumeAdjustmentFactor;
                    downloadLessonProcessInfo.saveFolderFilePath = Utils_LangCollab.downloadedLessonsDirectoryURL + File.separator + contentProviderId + File.separator + lessonId;
                    _downloadLessonProcessesInfo.addDownloadProcessInfo(downloadLessonProcessInfo);
                }
            }
            if (_downloadLessonProcessesInfo.length > 0)
            {
                var alertText:String = "Starting " + _downloadLessonProcessesInfo.length + " Lesson Download";
                if (_downloadLessonProcessesInfo.length > 1)
                    alertText += "s";
                MobileAlert.open(alertText, true);
                var cb:Callbacks = new Callbacks(onDownloadLessonsUpdate);
                _currentCommand_DownloadLessons = new Command_DownloadLessons(_downloadLessonProcessesInfo, cb);
                _currentCommand_DownloadLessons.execute();
                dispatchEvent(new BwEvent(BwEvent.NEW_INFO));
            }
        }

        private function startUpdateAvailableLessonsProcess():void
        {
            Log.info("LessonDownloadController.startUpdateAvailableLessonsProcess()");
            if (_isUpdateAvailableLessonDownloadsProcessActive || _isLessonDownloadProcessActive)
            {
                // This can, at least theoretically, happen if a download takes a *really* long time, and the auto-download process 
                // concludes that it's time to try again.
                return;
            }
            MobileAlert.open("\nSearching For New Lessons\n\nPlease Wait\n\n", false);
            _isUpdateAvailableLessonDownloadsProcessActive = true;
            _mostRecentUpdateAvailableLessonDownloadsStartTime = Utils_DateTime.getCurrentMS_BasedOnDate();
            lessonDownloadInfo_Libraries = new LessonDownloadInfo_Libraries();
            var cb:Callbacks = new Callbacks(onUpdateAvailableLessonDownloadsInfoResult);
            _currentCommand_UpdateAvailableLessonDownloadsInfo = new Command_UpdateAvailableLessonDownloadsInfo(cb);
            _currentCommand_UpdateAvailableLessonDownloadsInfo.execute();
        }

        private function stopAutoDownloadTimer():void
        {
            if (_autoDownloadTimer)
            {
                _autoDownloadTimer.stop();
                _autoDownloadTimer.removeEventListener(TimerEvent.TIMER, onAutoDownloadTimer);
                _autoDownloadTimer = null;
            }
        }

    }
}

