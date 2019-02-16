package com.langcollab.languagementor.model {
import com.brightworks.base.Callbacks;
import com.brightworks.component.mobilealert.MobileAlert;
import com.brightworks.constant.Constant_PlatformName;
import com.brightworks.event.BwEvent;
import com.brightworks.interfaces.ILoggingConfigProvider;
import com.brightworks.techreport.TechReport;
import com.brightworks.util.AppActiveElapsedTimeTimer;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_ANEs;
import com.brightworks.util.Utils_ArrayVectorEtc;
import com.brightworks.util.Utils_DataConversionComparison;
import com.brightworks.util.Utils_DateTime;
import com.brightworks.util.Utils_String;
import com.brightworks.util.Utils_System;
import com.brightworks.util.Utils_XML;
import com.brightworks.util.download.FileDownloader;
import com.brightworks.util.download.FileDownloaderErrorReport;
import com.langcollab.languagementor.constant.Constant_AppConfiguration;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.constant.Constant_MentorTypeSpecific;
import com.langcollab.languagementor.model.appstatepersistence.AppStatePersistenceManager;
import com.langcollab.languagementor.view.View_DeviceDoesntSupportLangMentor;
import com.langcollab.languagementor.vo.LanguageVO;

import flash.desktop.NativeApplication;

import flash.events.TimerEvent;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import spark.components.ViewNavigatorApplication;

public class ConfigFileInfo implements ILoggingConfigProvider {
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_ALWAYS_NODES:String = "problemDescription_MultipleAlwaysNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_DEFAULT_NODES:String = "problemDescription_MultipleDefaultNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_ERROR_NODES:String = "problemDescription_MultipleErrorNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_FATAL_NODES:String = "problemDescription_MultipleFatalNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_INFO_NODES:String = "problemDescription_MultipleInfoNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_PROBABILITY_NODES:String = "problemDescription_MultipleLogProbabilityNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_MAX_STRING_LENGTH_NODES:String = "problemDescription_MultipleLogToServerMaxStringLengthNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_PROBABILITY_NODES:String = "problemDescription_MultipleLogToServerProbabilityNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_URL_NODES:String = "problemDescription_MultipleLogURLNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOGGING_CONFIGURATION_NODES:String = "problemDescription_MultipleLoggingConfigurationNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_MOST_RECENT_VERSION_NODES:String = "problemDescription_MultipleMostRecentVersionNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_MOST_RECENT_VERSION_REQUIRED_DATA_SCHEMA_VERSION_NODES:String = "problemDescription_MultipleMostRecentVersionRequiredDataSchemaVersionNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_REQUIRED_VERSION_LIBRARY_ACCESS_NODES:String = "problemDescription_MultipleRequiredVersion_LibraryAccessNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_WARN_NODES:String = "problemDescription_MultipleWarnNodes";
   public static const PROB_DESC__MENTOR_TYPE_FILE__NO_DEFAULT_NODE:String = "problemDescription_NoDefaultNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__NO_LOG_PROBABILITY_NODE:String = "problemDescription_NoLogProbabilityNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__NO_LOG_TO_SERVER_MAX_STRING_LENGTH_NODE:String = "problemDescription_NoLogToServerMaxStringLengthNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__NO_LOG_TO_SERVER_PROBABILITY_NODE:String = "problemDescription_NoLogToServerProbabilityNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__NO_LOG_URL_NODE:String = "problemDescription_NoLogURLNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__NO_LOGGING_CONFIGURATION_NODE:String = "problemDescription_NoLoggingConfigurationNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__NO_MOST_RECENT_VERSION_NODE:String = "problemDescription_NoMostRecentVersionNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__NO_MOST_RECENT_VERSION_REQUIRED_DATA_SCHEMA_VERSION_NODE:String = "problemDescription_NoMostRecentVersionRequiredDataSchemaVersionNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__NO_REQUIRED_VERSION_LIBRARY_ACCESS_NODE:String = "problemDescription_NoRequiredVersion_LibraryAccessNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_PROBABILITY_NODE:String = "problemDescription_TypeError_LogProbabilityNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_MAX_STRING_LENGTH_NODE:String = "problemDescription_TypeError_LogToServerMaxStringLengthNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_PROBABILITY_NODE:String = "problemDescription_TypeError_LogToServerProbabilityNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_URL_NODE__URL_MALFORMED:String = "problemDescription_TypeError_LogURLNode_URLMalformed";
   public static const PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__MOST_RECENT_VERSION_NODE:String = "problemDescription_TypeError_MostRecentVersionNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__MOST_RECENT_VERSION_REQUIRED_DATA_SCHEMA_VERSION_NODE:String = "problemDescription_TypeError_MostRecentVersionRequiredDataSchemaVersionNode";
   public static const PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__REQUIRED_VERSION_LIBRARY_ACCESS_NODE:String = "problemDescription_TypeError_RequiredVersion_LibraryAccessNode";

   private static const _TIMER_TIMEOUT_MS:int = 30000;

   private var _appStatePersistenceManager:AppStatePersistenceManager = AppStatePersistenceManager.getInstance();
   private var _callbackList:Array = [];
   private var _downloadFailureCount:uint;
   private var _fileXML_LanguageMentorRootConfig:XML;
   private var _fileXML_MentorType:XML;
   private var _fileDownloader_MentorNewsUpdate:FileDownloader;
   private var _fileDownloader_MentorNewsUpdateInfo:FileDownloader;
   private var _fileDownloader_MentorTypeFile:FileDownloader;
   private var _fileDownloader_RootConfigFile:FileDownloader;
   private var _index_LogLevel_to_IsLoggingEnabled:Dictionary;
   private var _index_LogLevel_to_IsLogToServerEnabled:Dictionary;
   private var _index_LogLevel_to_LogToServerMaxStringLength:Dictionary;
   private var _index_LogLevel_to_LogURL:Dictionary;
   private var _isHighPriorityDataLoadingInProgress:Boolean; // For an explanation of 'priority', see notes at doLowPriorityDataFetching()
   private var _model:MainModel;
   private var _timeoutTimer:AppActiveElapsedTimeTimer;
   private var _timeoutTimerCompleteFunction:Function;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters / Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private var _isDataLoaded_MentorTypeFile:Boolean;

   public function get isDataLoaded_MentorTypeFile():Boolean {
      return _isDataLoaded_MentorTypeFile;
   }

   private var _mainConfigFolderURL:String;

   public function get mainConfigFolderURL():String {
      return _mainConfigFolderURL;
   }

   private var _mostRecentVersion:Number;

   public function get mostRecentVersion():Number {
      return _mostRecentVersion;
   }

   private var _mostRecentVersionRequiredDataSchemaVersion:Number;

   public function get mostRecentVersionRequiredDataSchemaVersion():Number {
      return _mostRecentVersionRequiredDataSchemaVersion;
   }

   private var _requiredVersion_LibraryAccess:Number;

   public function get requiredVersion_LibraryAccess():Number {
      return _requiredVersion_LibraryAccess;
   }

   private var _techReport:ConfigFileInfoTechReport;

   public function get techReport():ConfigFileInfoTechReport {
      return _techReport;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function ConfigFileInfo(model:MainModel) {
      _model = model;
   }

   public function getLogToServerMaxStringLength(level:uint):uint {
      if (!_index_LogLevel_to_LogToServerMaxStringLength.hasOwnProperty("level")) {
         // We don't log an error here because this method is used by our logging, and we'd create an infinite loop
         return 4000;
      }
      var result:uint = _index_LogLevel_to_LogToServerMaxStringLength[level];
      return result;
   }

   public function getLogToServerURL(level:uint):String {
      if (!_index_LogLevel_to_LogURL.hasOwnProperty("level")) {
         // We don't log an error here because this method is used by our logging, and we'd create an infinite loop
         return "";
      }
      var result:String = _index_LogLevel_to_LogURL[level];
      return result;
   }

   public function getMostRecentNewsUpdateHTML():String {
      if (!isMostRecentNewsUpdateAvailableForDisplay()) {
         Log.error("ConfigFileInfo.():getMostRecentNewsUpdateBody(): isMostRecentNewsUpdateAvailableForDisplay() returns false - should be checked before this method is called");
         return "";
      }
      var formatVersionNode:XML = getMostRecentNewsUpdateFormatVersionNode();
      return formatVersionNode.html[0].toString();
   }

   public function getMostRecentNewsUpdateLinkText():String {
      if (!isMostRecentNewsUpdateAvailableForDisplay()) {
         Log.error("ConfigFileInfo.():getMostRecentNewsUpdateLinkText(): isMostRecentNewsUpdateAvailableForDisplay() returns false - should be checked before this method is called");
         return "";
      }
      var formatVersionNode:XML = getMostRecentNewsUpdateFormatVersionNode();
      return formatVersionNode.linkText[0].toString();
   }

   public function isLoggingEnabled(level:uint):Boolean {
      if (!_index_LogLevel_to_IsLoggingEnabled.hasOwnProperty("level")) {
         // We don't log an error here because this method is used by our logging, and we'd create an infinite loop
         return false;
      }
      var result:Boolean = _index_LogLevel_to_IsLoggingEnabled[level];
      return result;
   }

   public function isLogToServerEnabled(level:uint):Boolean {
      if (!Utils_ArrayVectorEtc.doesDictionaryContainKey(_index_LogLevel_to_IsLogToServerEnabled, level)) {
         // We don't log an error here because this method is used by our logging, and we'd create an infinite loop
         return false;
      }
      var result:Boolean = _index_LogLevel_to_IsLogToServerEnabled[level];
      return result;
   }

   public function isMostRecentNewsUpdateAvailableForDisplay():Boolean {
      if (!(_appStatePersistenceManager.retrieveIs_MostRecent_NewsUpdate_DateRetrieved_Saved()))
         return false; // We don't have a retrieved news update
      if (_appStatePersistenceManager.retrieveIs_MostRecent_NewsUpdate_DateViewed_Saved()) {
         // We've viewed an update
         if (Utils_DateTime.compare(
               _appStatePersistenceManager.retrieveMostRecent_NewsUpdate_DateRetrieved(),
               _appStatePersistenceManager.retrieveMostRecent_NewsUpdate_DateViewed()) != 1) {
            // And the viewing was later than the update date
            return false;
         }
      }
      if (Utils_DateTime.computeDaysBeforePresent(_appStatePersistenceManager.retrieveMostRecent_NewsUpdate_DateRetrieved()) > 20)
         return false; // More than 20 days have passed since the update - it's no longer "news"
      if (!_appStatePersistenceManager.retrieveIs_MostRecent_NewsUpdateDate_Saved())
         return false; // Something is wrong. This is sad.
      if (!getMostRecentNewsUpdateFormatVersionNode())
         return false;
      return true;
   }

   public function loadData(callbacks:Callbacks):void {
      _callbackList.push(callbacks);
      if (_isHighPriorityDataLoadingInProgress)
         return;
      if (_techReport)
         _techReport.dispose();
      _techReport = new ConfigFileInfoTechReport();
      _isDataLoaded_MentorTypeFile = false;
      _fileDownloader_RootConfigFile = new FileDownloader();
      _fileDownloader_RootConfigFile.downloadFolderURL = _model.getURL_RootInfoFolder();
      _fileDownloader_RootConfigFile.downloadFileName = Constant_LangMentor_Misc.FILEPATHINFO__LANGUAGE_MENTOR_ROOT_CONFIG_FILE_NAME;
      _fileDownloader_RootConfigFile.downloadFileExtension = "xml";
      _fileDownloader_RootConfigFile.addEventListener(BwEvent.COMPLETE, onRootConfigFileDownloadComplete);
      _fileDownloader_RootConfigFile.addEventListener(BwEvent.FAILURE, onRootConfigFileDownloadFailure);
      _fileDownloader_RootConfigFile.start();
      _isHighPriorityDataLoadingInProgress = true;
      _downloadFailureCount = 0;
      startOrRestartTimeoutTimer(_TIMER_TIMEOUT_MS, onTimeoutTimerComplete);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function createMentorTypeFileFileName():String {
      // Names incorporate:
      //  - A 'root', e.g. mentor_type__
      //  - A platform name, e.g. android or ios
      //  - A staging or mentor type code
      //    - If app is alpha or beta version, this is alpha or beta
      //    - If app is production version, this is the current mentor type code
      //      See Constant_AppConfiguration.CURRENT_MENTOR_TYPE__CODE and Constant_MentorTypes
      // Exception:
      //  - Desktop emulation - "mentor_type__desktop"
      //
      var result:String;
      if (Utils_System.isRunningOnDesktop()) {
         result = Constant_LangMentor_Misc.FILEPATHINFO__MENTOR_TYPE_FILE_NAME_ROOT + "desktop";
      }
      else {
         var stagingOrMentorTypeCode:String =
               Utils_System.isAlphaOrBetaVersion() ?
                     Constant_AppConfiguration.RELEASE_TYPE :
                     Constant_MentorTypeSpecific.MENTOR_TYPE__CODE;
         var platformName:String;
         switch (Utils_System.platformName) {
            case Constant_PlatformName.ANDROID:
               platformName = "android";
               break;
            case Constant_PlatformName.IOS:
               platformName = "ios";
               break;
            case Constant_PlatformName.MAC:
            case Constant_PlatformName.WINDOWS_DESKTOP:
               switch (Constant_LangMentor_Misc.PLATFORM__DESKTOP_MODE_EMULATES_CONFIGURATION_OF) {
                  case Constant_PlatformName.ANDROID:
                     platformName = "android";
                     break;
                  case Constant_PlatformName.IOS:
                     platformName = "ios";
                     break;
                  default:
                     Log.fatal("ConfigFileInfo.createMentorTypeFileFileName(): No case for Constant_Misc.PLATFORM__DESKTOP_MODE_EMULATES_CONFIGURATION_OF of: " + Constant_LangMentor_Misc.PLATFORM__DESKTOP_MODE_EMULATES_CONFIGURATION_OF);
               }
               break;
            default:
               var name:String = Utils_System.platformName;
               Log.fatal("ConfigFileInfo.createMentorTypeFileFileName(): No case for Utils_System.platformName of: " + Utils_System.platformName);
         }
         result = Constant_LangMentor_Misc.FILEPATHINFO__MENTOR_TYPE_FILE_NAME_ROOT + platformName + "_" + stagingOrMentorTypeCode;
      }
      if (Utils_System.platformName == Constant_PlatformName.WINDOWS_DESKTOP)
         Utils_ANEs.showAlert_Toast(platformName + "_" + stagingOrMentorTypeCode);
      return result;
   }

   // dmccarroll 2012
   // "High priority data" includes the mentor type file data
   // "Low priority data" includes news updates etc.
   // High priority data is fetched each time loadData() is called (currently every time the app is started) and is stored in this class's properties.
   // Low priority data is typically fetched on a less frequent schedule, and is stored using _appStatePersistenceManager.
   // This class does callbacks to report results when the high-priority stuff is done, then proceeds to do low priority stuff, with no callbacks/reporting.
   private function doLowPriorityDataFetching():void {
      fetchLowPriorityDataIfAppropriate_MostRecentNewsUpdateDate();
   }

   private function fetchLowPriorityDataIfAppropriate_MostRecentNewsUpdate():void {
      if (!_appStatePersistenceManager.retrieveIs_MostRecent_NewsUpdateDate_Saved())
         return; // We haven't fetched a 'most recent update date' so we can't even think about whether we need to fetch an update.
      if (Utils_DateTime.compare(_appStatePersistenceManager.retrieveMostRecent_NewsUpdateDate(), new Date()) == 1)
         return; // The update date is in the future. We'll wait until it is in the past then, perhaps, fetch the update.
      if (Utils_DateTime.computeDaysBeforePresent(_appStatePersistenceManager.retrieveMostRecent_NewsUpdateDate()) > 21)
         return; // The update date was over three weeks ago. This is no longer "news".
      if (_appStatePersistenceManager.retrieveIs_MostRecent_NewsUpdate_DateRetrieved_Saved()) {
         if (Utils_DateTime.compare(_appStatePersistenceManager.retrieveMostRecent_NewsUpdate_DateRetrieved(), _appStatePersistenceManager.retrieveMostRecent_NewsUpdateDate_DateRetrieved()) == 1)
            return; // We've previously retrieved a news update, and we did it on a date that was later than the date on which we retrieved the update date that we're looking at, so we've already got the update.
      }
      _fileDownloader_MentorNewsUpdate = new FileDownloader();
      _fileDownloader_MentorNewsUpdate.downloadFolderURL = _model.getURL_MainConfigFolder();
      _fileDownloader_MentorNewsUpdate.downloadFileName = Constant_LangMentor_Misc.FILEPATHINFO__MENTOR_NEWS_UPDATE_FILE_NAME_ROOT + _model.getNativeLanguageIso639_3Code();
      _fileDownloader_MentorNewsUpdate.downloadFileExtension = "xml";
      _fileDownloader_MentorNewsUpdate.addEventListener(BwEvent.COMPLETE, onMentorNewsUpdateFileDownloadComplete);
      _fileDownloader_MentorNewsUpdate.addEventListener(BwEvent.FAILURE, onMentorNewsUpdateFileDownloadFailure);
      _fileDownloader_MentorNewsUpdate.start();
   }

   private function fetchLowPriorityDataIfAppropriate_MostRecentNewsUpdateDate():void {
      var isNewsUpdateDateEverRetrievedAndPersisted:Boolean = _appStatePersistenceManager.retrieveIs_MostRecent_NewsUpdateDate_DateRetrieved_Saved()
      if (isNewsUpdateDateEverRetrievedAndPersisted) {
         var retrievalDate:Date = _appStatePersistenceManager.retrieveMostRecent_NewsUpdateDate_DateRetrieved();
         var daysElapsedSinceRetrieval:Number = Utils_DateTime.computeDaysBeforePresent(retrievalDate);
      }
      if ((!isNewsUpdateDateEverRetrievedAndPersisted) || (daysElapsedSinceRetrieval > 5)) {
         _fileDownloader_MentorNewsUpdateInfo = new FileDownloader();
         _fileDownloader_MentorNewsUpdateInfo.downloadFolderURL = _model.getURL_MainConfigFolder();
         _fileDownloader_MentorNewsUpdateInfo.downloadFileName = Constant_LangMentor_Misc.FILEPATHINFO__MENTOR_NEWS_UPDATE_DATE_FILE_NAME_ROOT + _model.getNativeLanguageIso639_3Code();
         _fileDownloader_MentorNewsUpdateInfo.downloadFileExtension = "txt";
         _fileDownloader_MentorNewsUpdateInfo.addEventListener(BwEvent.COMPLETE, onMentorNewsUpdateInfoFileDownloadComplete);
         _fileDownloader_MentorNewsUpdateInfo.addEventListener(BwEvent.FAILURE, onMentorNewsUpdateInfoFileDownloadFailure);
         _fileDownloader_MentorNewsUpdateInfo.start();
      }
   }

   private function getMostRecentNewsUpdateFormatVersionNode():XML {
      var updateXML:XML = _appStatePersistenceManager.retrieveMostRecent_NewsUpdate();
      if (!updateXML)
         return null;
      // Quick & dirty code here - we'll improve this if/when we have additional news update formats
      if (XMLList(updateXML.formatVersions).length() != 1)
         return null;
      if (XMLList(updateXML.formatVersions[0].formatVersion).length() != 1)
         return null;
      if (XMLList(updateXML.formatVersions[0].formatVersion[0].linkText).length() != 1)
         return null;
      if (XMLList(updateXML.formatVersions[0].formatVersion[0].html).length() != 1)
         return null;
      return updateXML.formatVersions[0].formatVersion[0];
   }

   private function onMentorNewsUpdateFileDownloadComplete(event:BwEvent):void {
      _model.downloadBandwidthRecorder.reportFileDownloader(_fileDownloader_MentorNewsUpdate);
      var fileData:ByteArray = FileDownloader(event.target).fileData;
      /// Use a validate...() method
      try {
         var xml:XML = new XML(String(fileData));
      }
      catch (error:TypeError) {
         return;
      }
      _appStatePersistenceManager.persistMostRecent_NewsUpdate(xml);
      _appStatePersistenceManager.persistMostRecent_NewsUpdate_DateRetrieved(new Date());
   }

   private function onMentorNewsUpdateFileDownloadFailure(event:BwEvent):void {
      _model.downloadBandwidthRecorder.reportFileDownloader(_fileDownloader_MentorNewsUpdate);
      // Do nothing else - this is low priority info
   }

   private function onMentorNewsUpdateInfoFileDownloadComplete(event:BwEvent):void {
      _model.downloadBandwidthRecorder.reportFileDownloader(_fileDownloader_MentorNewsUpdateInfo);
      var fileData:ByteArray = FileDownloader(event.target).fileData;
      var dateString:String = Utils_String.removeWhiteSpaceIncludingLineReturnsFromBeginningAndEndOfString(String(fileData));
      if (Utils_DataConversionComparison.isAYYYYMMDDDateFormatString(dateString)) {
         var d:Date = Utils_DataConversionComparison.convertYYYYMMDDStringToUTCDate(dateString);
         _appStatePersistenceManager.persistMostRecent_NewsUpdateDate(d);
         _appStatePersistenceManager.persistMostRecent_NewsUpdateDate_DateRetrieved(new Date());
         fetchLowPriorityDataIfAppropriate_MostRecentNewsUpdate();
      }
   }

   private function onMentorNewsUpdateInfoFileDownloadFailure(event:BwEvent):void {
      _model.downloadBandwidthRecorder.reportFileDownloader(_fileDownloader_MentorNewsUpdateInfo);
      // Do nothing else - this is low priority info
   }

   private function onMentorTypeFileDownloadComplete(event:BwEvent):void {
      Log.debug("ConfigFileInfo.onMentorTypeFileDownloadComplete()");
      _model.downloadBandwidthRecorder.reportFileDownloader(_fileDownloader_MentorTypeFile);
      var fileData:ByteArray = FileDownloader(event.target).fileData;
      if (!validateAndPopulateMentorTypeFileXML(fileData)) {
         techReport.isMentorTypeFileParsingFailure = true;
         reportFault();
         return;
      }
      refreshMentorTypeDataFromXML();
      _isDataLoaded_MentorTypeFile = true;
      Log.setConfigProvider(this);
      reportResult();
      doLowPriorityDataFetching();
   }

   private function onMentorTypeFileDownloadFailure(event:BwEvent):void {
      Log.info("ConfigFileInfo.onMentorTypeFileDownloadFailure()");

      _model.downloadBandwidthRecorder.reportFileDownloader(_fileDownloader_MentorTypeFile);
      _downloadFailureCount++;
      if ((_downloadFailureCount <= 10) && (_fileDownloader_MentorTypeFile)) {
         _fileDownloader_MentorTypeFile.start();
      }
      else {
         if (!_fileDownloader_MentorTypeFile) // This has happened at least once; no idea how/why
            techReport.miscInfoList.push("_fileDownloader_MentorTypeFile is null in onMentorTypeFileDownloadFailure()");
         ConfigFileInfoTechReport(techReport).isMentorTypeFileDownloadFailure = true;
         reportFault();
      }
   }

   private function onRootConfigFileDownloadComplete(event:BwEvent):void {
      Log.debug("ConfigFileInfo.onRootConfigFileDownloadComplete()");
      _model.downloadBandwidthRecorder.reportFileDownloader(_fileDownloader_RootConfigFile);
      var fileData:ByteArray = FileDownloader(event.target).fileData;
      try {
         _fileXML_LanguageMentorRootConfig = new XML(String(fileData));
      } catch (e:Error) {
         if (e is TypeError) {
            // I don't know why but we're getting this error when we have no internet connection
            // So we treat this in the same way we treat other download failures
            Log.error("ConfigFileInfo.onRootConfigFileDownloadComplete() - error when we attempt to convert file data to XML: " + e.message);
            var report:FileDownloaderErrorReport = new FileDownloaderErrorReport();
            report.ioErrorEventText = "Download failure caught in onRootConfigFileDownloadComplete()";
            var event:BwEvent = new BwEvent(BwEvent.FAILURE, report);
            onRootConfigFileDownloadFailure(event);
         }
         else {
            Log.fatal("ConfigFileInfo.onRootConfigFileDownloadComplete() - Error converting root config file data to XML: " + e.message);
         }
         return;
      }
      /// Use a validateAndPopulateRootConfigFileXML() method
      _mainConfigFolderURL = _fileXML_LanguageMentorRootConfig.mainConfigFolderURL[0].toString();
      updateLanguageVOsWithHasRecommendedLibrariesInfo(_fileXML_LanguageMentorRootConfig);
      _fileDownloader_MentorTypeFile = new FileDownloader();
      _fileDownloader_MentorTypeFile.downloadFolderURL = _model.getURL_MainConfigFolder();
      _fileDownloader_MentorTypeFile.downloadFileName = createMentorTypeFileFileName();
      _fileDownloader_MentorTypeFile.downloadFileExtension = "xml";
      _fileDownloader_MentorTypeFile.addEventListener(BwEvent.COMPLETE, onMentorTypeFileDownloadComplete);
      _fileDownloader_MentorTypeFile.addEventListener(BwEvent.FAILURE, onMentorTypeFileDownloadFailure);
      _fileDownloader_MentorTypeFile.start();
      startOrRestartTimeoutTimer(_TIMER_TIMEOUT_MS, onTimeoutTimerComplete);
   }

   private function onRootConfigFileDownloadFailure(event:BwEvent):void {
      // Is Tomcat started?
      Log.info("ConfigFileInfo.onRootConfigFileDownloadFailure() - " + FileDownloaderErrorReport(event.techReport).ioErrorEventText);

      _model.downloadBandwidthRecorder.reportFileDownloader(_fileDownloader_RootConfigFile);
      _downloadFailureCount++;
      if ((_downloadFailureCount <= 10) && (_fileDownloader_RootConfigFile)) {
         _fileDownloader_RootConfigFile.start();
      }
      else {
         if (!_fileDownloader_RootConfigFile) // This has happened at least once; no idea how/why
            techReport.miscInfoList.push("_rootConfigFileDownloader is null in onRootConfigFileDownloadFailure()");
         ConfigFileInfoTechReport(techReport).isRootConfigFileDownloadFailure = true;
         reportFault();
         NativeApplication.nativeApplication.dispatchEvent(new BwEvent(BwEvent.NO_INTERNET_CONNECTION));
      }
   }

   private function onTimeoutTimerComplete(event:TimerEvent):void {
      Log.debug("ConfigFileInfo.onTimeoutTimerComplete()");
      techReport.isProcessTimedOut = true;
      reportFault();
   }

   private function updateLanguageVOsWithHasRecommendedLibrariesInfo(xml:XML):void {
      /// Language VOs start with their hasRecommendedLibraries props set to false, so, for now we'll only update those where this prop should be true
      /// Eventually, we should update all VOs, as we'll have situations like a) a library has become non-recommended, b) a user switches native language (?)
      var nativeLanguagesNode:XML = xml.languagePairsWithRecommendedLibrariesInfo[0].nativeLanguages[0];
      var nativeLanguageNode:XML = nativeLanguagesNode[_model.getCurrentNativeLanguageISO639_3Code()][0];
      var targetLanguagesNode:XML = nativeLanguageNode.targetLanguages[0];
      for (var i:int = 0; i < targetLanguagesNode.children().length(); i++) {
         var targetLanguageNode:XML = targetLanguagesNode.children()[i];
         var iso639_3Code:String = targetLanguageNode.name();
         var vo:LanguageVO = _model.getLanguageVOFromIso639_3Code(iso639_3Code);
         vo.hasRecommendedLibraries = true;
         _model.updateVO_NoKeyPropChangesAllowed("ConfigFileInfo.updateLanguageVOsWithHasRecommendedLibrariesInfo", vo, ["hasRecommendedLibraries"]);
         if (_model.getCurrentTargetLanguageISO639_3Code() == iso639_3Code) {   // This also evaluates to false if the currentTargetLanguage hasn't been set yet - which occurs in some scenarios - but this isn't a problem because the value has also been set in the DB (above)
            _model.updateCurrentTargetLanguageVO_hasRecommendedLibraries(true);
         }
      }
   }

   private function refreshMentorTypeDataFromXML():void {
      _mostRecentVersion = Utils_XML.readNumberNode(_fileXML_MentorType.mostRecentVersion[0]);
      _mostRecentVersionRequiredDataSchemaVersion = Utils_XML.readNumberNode(_fileXML_MentorType.mostRecentVersionRequiredDataSchemaVersion[0]);
      _requiredVersion_LibraryAccess = Utils_XML.readNumberNode(_fileXML_MentorType.requiredVersion_LibraryAccess[0]);
      _index_LogLevel_to_IsLoggingEnabled = new Dictionary();
      _index_LogLevel_to_IsLogToServerEnabled = new Dictionary();
      _index_LogLevel_to_LogToServerMaxStringLength = new Dictionary();
      _index_LogLevel_to_LogURL = new Dictionary();
      var loggingConfigurationNode:XML = _fileXML_MentorType.loggingConfiguration[0];
      var defaultConfigNode:XML = loggingConfigurationNode.default[0];
      var defaultValue_IsLoggingEnabled:Boolean =
            Utils_DataConversionComparison.createRandomBooleanBasedOnProbabilityFraction(Utils_XML.readNumberNode(defaultConfigNode.logProbability[0]));
      var defaultValue_LogToServerMaxStringLength:int =
            Utils_XML.readIntegerNode(defaultConfigNode.logToServerMaxStringLength[0]);
      var defaultValue_IsLogToServerEnabled:Boolean =
            Utils_DataConversionComparison.createRandomBooleanBasedOnProbabilityFraction(Utils_XML.readNumberNode(defaultConfigNode.logToServerProbability[0]));
      var defaultValue_LogURL:String =
            defaultConfigNode.logURL[0].toString();
      var _index_LogLevel_to_NodeForLevel:Dictionary = new Dictionary();
      _index_LogLevel_to_NodeForLevel[Log.LOG_LEVEL__DEBUG] =
            (XMLList(loggingConfigurationNode.debug).length() == 1) ?
                  loggingConfigurationNode.debug[0] :
                  null;
      _index_LogLevel_to_NodeForLevel[Log.LOG_LEVEL__INFO] =
            (XMLList(loggingConfigurationNode.info).length() == 1) ?
                  loggingConfigurationNode.info[0] :
                  null;
      _index_LogLevel_to_NodeForLevel[Log.LOG_LEVEL__WARN] =
            (XMLList(loggingConfigurationNode.warn).length() == 1) ?
                  loggingConfigurationNode.warn[0] :
                  null;
      _index_LogLevel_to_NodeForLevel[Log.LOG_LEVEL__ERROR] =
            (XMLList(loggingConfigurationNode.error).length() == 1) ?
                  loggingConfigurationNode.error[0] :
                  null;
      _index_LogLevel_to_NodeForLevel[Log.LOG_LEVEL__FATAL] =
            (XMLList(loggingConfigurationNode.fatal).length() == 1) ?
                  loggingConfigurationNode.fatal[0] :
                  null;
      for (var o:Object in _index_LogLevel_to_NodeForLevel) {
         var logLevel:int = int(o);
         var levelConfigNode:XML = _index_LogLevel_to_NodeForLevel[o];
         if (Utils_XML.isNodeNonNullAndSingleSubnodeExistsInNode(levelConfigNode, "logProbability")) {
            _index_LogLevel_to_IsLoggingEnabled[logLevel] =
                  Utils_DataConversionComparison.createRandomBooleanBasedOnProbabilityFraction(Utils_XML.readNumberNode(levelConfigNode.logProbability[0]));
         }
         else {
            _index_LogLevel_to_IsLoggingEnabled[logLevel] = defaultValue_IsLoggingEnabled;
         }
         if (Utils_XML.isNodeNonNullAndSingleSubnodeExistsInNode(levelConfigNode, "logToServerMaxStringLength")) {
            _index_LogLevel_to_LogToServerMaxStringLength[logLevel] =
                  Utils_XML.readIntegerNode(levelConfigNode.logToServerMaxStringLength[0]);
         }
         else {
            _index_LogLevel_to_LogToServerMaxStringLength[logLevel] = defaultValue_LogToServerMaxStringLength;
         }
         if (Utils_XML.isNodeNonNullAndSingleSubnodeExistsInNode(levelConfigNode, "logToServerProbability")) {
            _index_LogLevel_to_IsLogToServerEnabled[logLevel] =
                  Utils_DataConversionComparison.createRandomBooleanBasedOnProbabilityFraction(Utils_XML.readNumberNode(levelConfigNode.logToServerProbability[0]));
         }
         else {
            _index_LogLevel_to_IsLogToServerEnabled[logLevel] = defaultValue_IsLogToServerEnabled;
         }
         if (Utils_XML.isNodeNonNullAndSingleSubnodeExistsInNode(levelConfigNode, "logURL")) {
            _index_LogLevel_to_LogURL[logLevel] = levelConfigNode.logURL[0].toString();
         }
         else {
            _index_LogLevel_to_LogURL[logLevel] = defaultValue_LogURL;
         }
      }
      _index_LogLevel_to_IsLoggingEnabled[Log.LOG_LEVEL__ALWAYS] = true;
      _index_LogLevel_to_IsLogToServerEnabled[Log.LOG_LEVEL__ALWAYS] = true;
      _index_LogLevel_to_LogURL[Log.LOG_LEVEL__ALWAYS] = defaultValue_LogURL;
   }

   private function reportFault():void {
      Log.info("ConfigFileInfo.reportFault()");
      _isHighPriorityDataLoadingInProgress = false;
      stopTimeoutTimer();
      if (_callbackList.length > 0) {
         for each (var cb:Callbacks in _callbackList) {
            cb.fault(techReport);
         }
         _callbackList = [];
      }
   }

   private function reportResult():void {
      Log.debug("ConfigFileInfo.reportResult()");
      _isHighPriorityDataLoadingInProgress = false;
      stopTimeoutTimer();
      if (_callbackList.length > 0) {
         for each (var cb:Callbacks in _callbackList) {
            cb.result(techReport);
         }
         _callbackList = [];
      }
   }

   private function startOrRestartTimeoutTimer(timeoutMS:uint, timerCompleteFunction:Function):void {
      Log.debug("Command_Base.startOrRestartTimeoutTimer()");
      if (Utils_System.isRunningOnDesktop())
         timeoutMS = timeoutMS * 10;
      _timeoutTimerCompleteFunction = timerCompleteFunction;
      stopTimeoutTimer();
      _timeoutTimer = new AppActiveElapsedTimeTimer(timeoutMS);
      _timeoutTimer.addEventListener(TimerEvent.TIMER, timerCompleteFunction);
      _timeoutTimer.start();
   }

   private function stopTimeoutTimer():void {
      Log.debug("Command_Base.stopTimer()");
      if (_timeoutTimer) {
         _timeoutTimer.stop();
         _timeoutTimer.removeEventListener(TimerEvent.TIMER, _timeoutTimerCompleteFunction);
         _timeoutTimer = null;
      }
   }

   protected function validateAndPopulateMentorTypeFileXML(fileData:ByteArray):Boolean {
      try {
         _fileXML_MentorType = new XML(String(fileData));
      }
      catch (error:TypeError) {
         techReport.problemDescriptionList.push(error.message);
         return false;
      }
      var bError:Boolean = false;
      if (XMLList(_fileXML_MentorType.mostRecentVersion).length() < 1) {
         bError = true;
         techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__NO_MOST_RECENT_VERSION_NODE);
      }
      else if (XMLList(_fileXML_MentorType.mostRecentVersion).length() > 1) {
         bError = true;
         techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_MOST_RECENT_VERSION_NODES);
      }
      else if (!Utils_XML.doesNodeEvaluateToNumber(_fileXML_MentorType.mostRecentVersion[0])) {
         bError = true;
         techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__MOST_RECENT_VERSION_NODE);
      }
      if (XMLList(_fileXML_MentorType.mostRecentVersionRequiredDataSchemaVersion).length() < 1) {
         bError = true;
         techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__NO_MOST_RECENT_VERSION_REQUIRED_DATA_SCHEMA_VERSION_NODE);
      }
      else if (XMLList(_fileXML_MentorType.mostRecentVersionRequiredDataSchemaVersion).length() > 1) {
         bError = true;
         techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_MOST_RECENT_VERSION_REQUIRED_DATA_SCHEMA_VERSION_NODES);
      }
      else if (!Utils_XML.doesNodeEvaluateToNumber(_fileXML_MentorType.mostRecentVersionRequiredDataSchemaVersion[0])) {
         bError = true;
         techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__MOST_RECENT_VERSION_REQUIRED_DATA_SCHEMA_VERSION_NODE);
      }
      if (XMLList(_fileXML_MentorType.requiredVersion_LibraryAccess).length() < 1) {
         bError = true;
         techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__NO_REQUIRED_VERSION_LIBRARY_ACCESS_NODE);
      }
      else if (XMLList(_fileXML_MentorType.requiredVersion_LibraryAccess).length() > 1) {
         bError = true;
         techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_REQUIRED_VERSION_LIBRARY_ACCESS_NODES);
      }
      else if (!Utils_XML.doesNodeEvaluateToNumber(_fileXML_MentorType.requiredVersion_LibraryAccess[0])) {
         bError = true;
         techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__REQUIRED_VERSION_LIBRARY_ACCESS_NODE);
      }
      if (XMLList(_fileXML_MentorType.loggingConfiguration).length() < 1) {
         bError = true;
         techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__NO_LOGGING_CONFIGURATION_NODE);
      }
      else if (XMLList(_fileXML_MentorType.loggingConfiguration).length() > 1) {
         bError = true;
         techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOGGING_CONFIGURATION_NODES);
      }
      else {
         var loggingConfigurationNode:XML = _fileXML_MentorType.loggingConfiguration[0];
         if (XMLList(loggingConfigurationNode.default).length() < 1) {
            bError = true;
            techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__NO_DEFAULT_NODE);
         }
         else if (XMLList(loggingConfigurationNode.default).length() > 1) {
            bError = true;
            techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_DEFAULT_NODES);
         }
         else {
            if (XMLList(loggingConfigurationNode.default[0].logProbability).length() < 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__NO_LOG_PROBABILITY_NODE);
            }
            else if (XMLList(loggingConfigurationNode.default[0].logProbability).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_PROBABILITY_NODES);
            }
            else if (!Utils_XML.doesNodeEvaluateToFractionalNumber(loggingConfigurationNode.default[0].logProbability[0])) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_PROBABILITY_NODE);
            }
            if (XMLList(loggingConfigurationNode.default[0].logToServerMaxStringLength).length() < 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__NO_LOG_TO_SERVER_MAX_STRING_LENGTH_NODE);
            }
            else if (XMLList(loggingConfigurationNode.default[0].logToServerMaxStringLength).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_MAX_STRING_LENGTH_NODES);
            }
            else if (!Utils_XML.doesNodeEvaluateToInt(loggingConfigurationNode.default[0].logToServerMaxStringLength[0])) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_MAX_STRING_LENGTH_NODE);
            }
            if (XMLList(loggingConfigurationNode.default[0].logToServerProbability).length() < 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__NO_LOG_TO_SERVER_PROBABILITY_NODE);
            }
            else if (XMLList(loggingConfigurationNode.default[0].logToServerProbability).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_PROBABILITY_NODES);
            }
            else if (!Utils_XML.doesNodeEvaluateToFractionalNumber(loggingConfigurationNode.default[0].logToServerProbability[0])) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_PROBABILITY_NODE);
            }
            /*if (XMLList(loggingConfigurationNode.default[0].logURL).length() < 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__NO_LOG_URL_NODE);
            }
            else if (XMLList(loggingConfigurationNode.default[0].logURL).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_URL_NODES);
            }
            else if (!Utils_XML.doesNodeEvaluateToURL(loggingConfigurationNode.default[0].logURL[0])) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_URL_NODE__URL_MALFORMED);
            }*/
         }
         if (XMLList(loggingConfigurationNode.info).length() > 1) {
            bError = true;
            techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_INFO_NODES);
         }
         else if (XMLList(loggingConfigurationNode.info).length() == 1) {
            if (XMLList(loggingConfigurationNode.info[0].logProbability).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_PROBABILITY_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.info[0].logProbability).length() == 1) && (!Utils_XML.doesNodeEvaluateToFractionalNumber(loggingConfigurationNode.info[0].logProbability[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_PROBABILITY_NODE);
            }
            if (XMLList(loggingConfigurationNode.info[0].logToServerMaxStringLength).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_MAX_STRING_LENGTH_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.info[0].logToServerMaxStringLength).length() == 1) && (!Utils_XML.doesNodeEvaluateToInt(loggingConfigurationNode.info[0].logToServerMaxStringLength[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_MAX_STRING_LENGTH_NODE);
            }
            if (XMLList(loggingConfigurationNode.info[0].logToServerProbability).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_PROBABILITY_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.info[0].logToServerProbability).length() == 1) && (!Utils_XML.doesNodeEvaluateToFractionalNumber(loggingConfigurationNode.info[0].logToServerProbability[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_PROBABILITY_NODE);
            }
            if (XMLList(loggingConfigurationNode.info[0].logURL).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_URL_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.info[0].logURL).length() == 1) && (!Utils_XML.doesNodeEvaluateToURL(loggingConfigurationNode.info[0].logURL[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_URL_NODE__URL_MALFORMED);
            }
         }
         if (XMLList(loggingConfigurationNode.warn).length() > 1) {
            bError = true;
            techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_WARN_NODES);
         }
         else if (XMLList(loggingConfigurationNode.warn).length() == 1) {
            if (XMLList(loggingConfigurationNode.warn[0].logProbability).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_PROBABILITY_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.warn[0].logProbability).length() == 1) && (!Utils_XML.doesNodeEvaluateToFractionalNumber(loggingConfigurationNode.warn[0].logProbability[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_PROBABILITY_NODE);
            }
            if (XMLList(loggingConfigurationNode.warn[0].logToServerMaxStringLength).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_MAX_STRING_LENGTH_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.warn[0].logToServerMaxStringLength).length() == 1) && (!Utils_XML.doesNodeEvaluateToInt(loggingConfigurationNode.warn[0].logToServerMaxStringLength[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_MAX_STRING_LENGTH_NODE);
            }
            if (XMLList(loggingConfigurationNode.warn[0].logToServerProbability).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_PROBABILITY_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.warn[0].logToServerProbability).length() == 1) && (!Utils_XML.doesNodeEvaluateToFractionalNumber(loggingConfigurationNode.warn[0].logToServerProbability[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_PROBABILITY_NODE);
            }
            if (XMLList(loggingConfigurationNode.warn[0].logURL).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_URL_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.warn[0].logURL).length() == 1) && (!Utils_XML.doesNodeEvaluateToURL(loggingConfigurationNode.warn[0].logURL[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_URL_NODE__URL_MALFORMED);
            }
         }
         if (XMLList(loggingConfigurationNode.error).length() > 1) {
            bError = true;
            techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_ERROR_NODES);
         }
         else if (XMLList(loggingConfigurationNode.error).length() == 1) {
            if (XMLList(loggingConfigurationNode.error[0].logProbability).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_PROBABILITY_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.error[0].logProbability).length() == 1) && (!Utils_XML.doesNodeEvaluateToFractionalNumber(loggingConfigurationNode.error[0].logProbability[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_PROBABILITY_NODE);
            }
            if (XMLList(loggingConfigurationNode.error[0].logToServerMaxStringLength).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_MAX_STRING_LENGTH_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.error[0].logToServerMaxStringLength).length() == 1) && (!Utils_XML.doesNodeEvaluateToInt(loggingConfigurationNode.error[0].logToServerMaxStringLength[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_MAX_STRING_LENGTH_NODE);
            }
            if (XMLList(loggingConfigurationNode.error[0].logToServerProbability).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_PROBABILITY_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.error[0].logToServerProbability).length() == 1) && (!Utils_XML.doesNodeEvaluateToFractionalNumber(loggingConfigurationNode.error[0].logToServerProbability[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_PROBABILITY_NODE);
            }
            if (XMLList(loggingConfigurationNode.error[0].logURL).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_URL_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.error[0].logURL).length() == 1) && (!Utils_XML.doesNodeEvaluateToURL(loggingConfigurationNode.error[0].logURL[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_URL_NODE__URL_MALFORMED);
            }
         }
         if (XMLList(loggingConfigurationNode.fatal).length() > 1) {
            bError = true;
            techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_FATAL_NODES);
         }
         else if (XMLList(loggingConfigurationNode.fatal).length() == 1) {
            if (XMLList(loggingConfigurationNode.fatal[0].logProbability).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_PROBABILITY_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.fatal[0].logProbability).length() == 1) && (!Utils_XML.doesNodeEvaluateToFractionalNumber(loggingConfigurationNode.fatal[0].logProbability[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_PROBABILITY_NODE);
            }
            if (XMLList(loggingConfigurationNode.fatal[0].logToServerMaxStringLength).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_MAX_STRING_LENGTH_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.fatal[0].logToServerMaxStringLength).length() == 1) && (!Utils_XML.doesNodeEvaluateToInt(loggingConfigurationNode.fatal[0].logToServerMaxStringLength[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_MAX_STRING_LENGTH_NODE);
            }
            if (XMLList(loggingConfigurationNode.fatal[0].logToServerProbability).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_PROBABILITY_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.fatal[0].logToServerProbability).length() == 1) && (!Utils_XML.doesNodeEvaluateToFractionalNumber(loggingConfigurationNode.fatal[0].logToServerProbability[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_PROBABILITY_NODE);
            }
            if (XMLList(loggingConfigurationNode.fatal[0].logURL).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_URL_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.fatal[0].logURL).length() == 1) && (!Utils_XML.doesNodeEvaluateToURL(loggingConfigurationNode.fatal[0].logURL[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_URL_NODE__URL_MALFORMED);
            }
         }
         if (XMLList(loggingConfigurationNode.always).length() > 1) {
            bError = true;
            techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_ALWAYS_NODES);
         }
         else if (XMLList(loggingConfigurationNode.always).length() == 1) {
            if (XMLList(loggingConfigurationNode.always[0].logProbability).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_PROBABILITY_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.always[0].logProbability).length() == 1) && (!Utils_XML.doesNodeEvaluateToFractionalNumber(loggingConfigurationNode.always[0].logProbability[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_PROBABILITY_NODE);
            }
            if (XMLList(loggingConfigurationNode.always[0].logToServerMaxStringLength).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_MAX_STRING_LENGTH_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.always[0].logToServerMaxStringLength).length() == 1) && (!Utils_XML.doesNodeEvaluateToInt(loggingConfigurationNode.always[0].logToServerMaxStringLength[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_MAX_STRING_LENGTH_NODE);
            }
            if (XMLList(loggingConfigurationNode.always[0].logToServerProbability).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_TO_SERVER_PROBABILITY_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.always[0].logToServerProbability).length() == 1) && (!Utils_XML.doesNodeEvaluateToFractionalNumber(loggingConfigurationNode.always[0].logToServerProbability[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_TO_SERVER_PROBABILITY_NODE);
            }
            if (XMLList(loggingConfigurationNode.always[0].logURL).length() > 1) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__MULTIPLE_LOG_URL_NODES);
            }
            else if ((XMLList(loggingConfigurationNode.always[0].logURL).length() == 1) && (!Utils_XML.doesNodeEvaluateToURL(loggingConfigurationNode.always[0].logURL[0]))) {
               bError = true;
               techReport.problemDescriptionList.push(PROB_DESC__MENTOR_TYPE_FILE__TYPE_ERROR__LOG_URL_NODE__URL_MALFORMED);
            }
         }
      }
      return !bError;
   }

}
}



























