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
package com.langcollab.languagementor.model.appstatepersistence {
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.util.Log;
import com.brightworks.util.persistence.ByteArrayPersistenceManager;
import com.brightworks.util.singleton.SingletonManager;
import com.langcollab.languagementor.constant.Constant_TextDisplayModes;
import com.langcollab.languagementor.vo.LessonVersionVO;
import com.langcollab.languagementor.vo.LevelVO;

import flash.net.registerClassAlias;

import spark.managers.PersistenceManager;

public class AppStatePersistenceManager implements IManagedSingleton {
   private static const _DATA_TYPE_NAME__APP_INSTALL_DATE:String = "appInstallDate";
   private static const _DATA_TYPE_NAME__AUTO_DOWNLOAD_LESSONS:String = "autoDownloadLessons";
   private static const _DATA_TYPE_NAME__CURR_APP_VERSION:String = "currAppVersion";
   private static const _DATA_TYPE_NAME__CURR_CHUNK_INDEX:String = "currChunkIndex";
   private static const _DATA_TYPE_NAME__CURR_LESSON_VERSION:String = "currLessonVersion";
   private static const _DATA_TYPE_NAME__DATA_SCHEMA_APP_VERSION:String = "dataSchemaAppVersion";
   private static const _DATA_TYPE_NAME__HAS_USER_SELECTED_DOWNLOAD_BETA_LESSONS_OPTION:String = "hasUserSelectedDownloadBetaLessonsOption";
   private static const _DATA_TYPE_NAME__HELP__LAST_VIEW_DATE__PLAY_LESSONS:String = "help_LastViewDate_PlayLessons";
   private static const _DATA_TYPE_NAME__HELP__LAST_VIEW_DATE__SELECT_LESSONS:String = "help_LastViewDate_SelectLessons";
   private static const _DATA_TYPE_NAME__HELP__LAST_VIEW_DATE__SELECT_MODE:String = "help_LastViewDate_SelectMode";
   private static const _DATA_TYPE_NAME__HOME_SCREEN_DISPLAY_COUNT:String = "homeScreenDisplayCount";
   private static const _DATA_TYPE_NAME__IS_APP_INSTALL_DATE_SAVED:String = "isAppInstallDateSaved";
   private static const _DATA_TYPE_NAME__IS_AUTO_DOWNLOAD_LESSONS_SAVED:String = "isAutoDownloadLessonsSaved";
   private static const _DATA_TYPE_NAME__IS_CURR_APP_VERSION_SAVED:String = "isCurrAppVersionSaved";
   private static const _DATA_TYPE_NAME__IS_CURR_CHUNK_INDEX_SAVED:String = "isCurrChunkIndexSaved";
   private static const _DATA_TYPE_NAME__IS_CURR_LESSON_VERSION_SAVED:String = "isCurrLessonVersionSaved";
   private static const _DATA_TYPE_NAME__IS_DATA_SCHEMA_APP_VERSION_SAVED:String = "isDataSchemaAppVersionSaved";
   private static const _DATA_TYPE_NAME__IS_HAS_USER_SELECTED_DOWNLOAD_BETA_LESSONS_OPTION_SAVED:String = "isHasUserSelectedDownloadBetaLessonsOptionSaved";
   private static const _DATA_TYPE_NAME__IS__HELP__LAST_VIEW_DATE__PLAY_LESSONS__SAVED:String = "is_Help_LastViewDate_PlayLessons_Saved";
   private static const _DATA_TYPE_NAME__IS__HELP__LAST_VIEW_DATE__SELECT_LESSONS__SAVED:String = "is_Help_LastViewDate_SelectLessons_Saved";
   private static const _DATA_TYPE_NAME__IS__HELP__LAST_VIEW_DATE__SELECT_MODE__SAVED:String = "is_Help_LastViewDate_SelectMode_Saved";
   private static const _DATA_TYPE_NAME__IS_HOME_SCREEN_DISPLAY_COUNT_SAVED:String = "is_HomeScreenDisplayCount_Saved";
   private static const _DATA_TYPE_NAME__IS_LESSON_VERSION_ENTRY_COUNT_SAVED:String = "is_LessonVersionEntryCount_Saved";
   private static const _DATA_TYPE_NAME__IS_MOST_RECENT_APP_VERSION_WHERE_USER_AGREED_TO_LEGAL_NOTICE_SAVED:String = "isMostRecentAppVersionWhereUserAgreedToLegalNoticeSaved";
   private static const _DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE__SAVED:String = "is_MostRecent_NewsUpdate_Saved";
   private static const _DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE__DATE_RETRIEVED__SAVED:String = "is_MostRecent_NewsUpdate_DateRetrieved_Saved";
   private static const _DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE__DATE_VIEWED__SAVED:String = "is_MostRecent_NewsUpdate_DateViewed_Saved";
   private static const _DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE_DATE__SAVED:String = "is_MostRecent_NewsUpdateDate_Saved";
   private static const _DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE_DATE__DATE_RETRIEVED__SAVED:String = "is_MostRecent_NewsUpdateDate_DateRetrieved_Saved";
   private static const _DATA_TYPE_NAME__IS_NAGGING_DISABLED_SAVED:String = "isNaggingDisabledSaved";
   private static const _DATA_TYPE_NAME__IS_SELECTED_LEARNING_MODE_ID_SAVED:String = "isSelectedLearningModeIdSaved";
   private static const _DATA_TYPE_NAME__IS_TARGET_LANGUAGE_ID_SAVED:String = "isTargetLanguageIdSaved";
   private static const _DATA_TYPE_NAME__IS_TEXT_DISPLAY_MODE_SAVED:String = "isTextDisplayModeSaved";
   private static const _DATA_TYPE_NAME__IS_USE_RECOMMENDED_LIBRARIES_SAVED:String = "isUseRecommendedLibrariesSaved";
   private static const _DATA_TYPE_NAME__IS_SELECTED_LESSON_DOWNLOAD_LEVELS_SAVED:String = "isSelectedLessonDownloadLevelsSaved";
   private static const _DATA_TYPE_NAME__IS_SELECTED_LESSON_VERSIONS_SAVED:String = "isSelectedLessonVersionsSaved";
   private static const _DATA_TYPE_NAME__LESSON_VERSION_ENTRY_COUNT:String = "lessonVersionEntryCount";
   private static const _DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE:String = "mostRecent_NewsUpdate";
   private static const _DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE__DATE_RETRIEVED:String = "mostRecent_NewsUpdate_DateRetrieved";
   private static const _DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE__DATE_VIEWED:String = "mostRecent_NewsUpdate_DateViewed";
   private static const _DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE_DATE:String = "mostRecent_NewsUpdateDate";
   private static const _DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE_DATE__DATE_RETRIEVED:String = "mostRecent_NewsUpdateDate_DateRetrieved";
   private static const _DATA_TYPE_NAME__NAGGING_DISABLED:String = "naggingDisabled";
   private static const _DATA_TYPE_NAME__SELECTED_LEARNING_MODE_ID:String = "selectedLearningModeId";
   private static const _DATA_TYPE_NAME__SELECTED_LESSON_DOWNLOAD_LEVELS:String = "selectedLessonDownloadLevels";
   private static const _DATA_TYPE_NAME__SELECTED_LESSON_VERSIONS:String = "selectedLessonVersions";
   private static const _DATA_TYPE_NAME__TARGET_LANGUAGE_ID:String = "targetLanguageId";
   private static const _DATA_TYPE_NAME__TEXT_DISPLAY_MODE:String = "textDisplayMode";
   private static const _DATA_TYPE_NAME__USE_RECOMMENDED_LIBRARIES:String = "useRecommendedLibraries";

   private static var _instance:AppStatePersistenceManager;

   public var isDataWipeActivityBlockActive:Boolean;

   private var _persistenceManager:ByteArrayPersistenceManager;

   public function AppStatePersistenceManager(manager:SingletonManager) {
      Log.info("AppStatePersistenceManager constructor called");
      _instance = this;
      registerClassAlias("com.langcollab.languagementor.model.appstatepersistence.LessonVersionInfo", LessonVersionInfo);
      _persistenceManager = new ByteArrayPersistenceManager();
   }

   public static function getInstance():AppStatePersistenceManager {
      if (!(_instance))
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function initSingleton():void {
   }

   public function isEnabled():Boolean {
      return (_persistenceManager != null);
   }

   public function iterateLessonVersionEntryCount():void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      var count:int;
      if (retrieveIsLessonVersionEntryCountSaved()) {
         count = retrieveLessonVersionEntryCount();
      } else {
         count = 0;
      }
      _persistenceManager.setProperty(_DATA_TYPE_NAME__LESSON_VERSION_ENTRY_COUNT, count + 1);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_LESSON_VERSION_ENTRY_COUNT_SAVED, true);
      _persistenceManager.save();

   }

   public function persistAppInstallDate(value:Date):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__APP_INSTALL_DATE, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_APP_INSTALL_DATE_SAVED, true);
      _persistenceManager.save();
   }

   public function persistAutoDownloadLessons(value:Boolean):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__AUTO_DOWNLOAD_LESSONS, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_AUTO_DOWNLOAD_LESSONS_SAVED, true);
      _persistenceManager.save();
   }

   public function persistCurrAppVersion(value:Number):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__CURR_APP_VERSION, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_CURR_APP_VERSION_SAVED, true);
      _persistenceManager.save();
   }

   public function persistCurrChunkIndex(value:int):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__CURR_CHUNK_INDEX, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_CURR_CHUNK_INDEX_SAVED, true);
      _persistenceManager.save();
   }

   public function persistCurrLessonVersion(value:LessonVersionVO):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      if (value) {
         var lvInfo:LessonVersionInfo = new LessonVersionInfo();
         lvInfo.contentProviderId = value.contentProviderId;
         lvInfo.lessonVersionSignature = value.lessonVersionSignature;
         _persistenceManager.setProperty(_DATA_TYPE_NAME__CURR_LESSON_VERSION, lvInfo);
         _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_CURR_LESSON_VERSION_SAVED, true);
      }
      else {
         _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_CURR_LESSON_VERSION_SAVED, false);
      }
      _persistenceManager.save();
   }

   public function persistDataSchemaAppVersion(value:Number):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__DATA_SCHEMA_APP_VERSION, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_DATA_SCHEMA_APP_VERSION_SAVED, true);
      _persistenceManager.save();
   }

   public function persistHasUserSelectedDownloadBetaLessonsOption(value:Boolean):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__HAS_USER_SELECTED_DOWNLOAD_BETA_LESSONS_OPTION, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_HAS_USER_SELECTED_DOWNLOAD_BETA_LESSONS_OPTION_SAVED, true);
      _persistenceManager.save();
   }

   public function persistHelp_LastViewDate_PlayLessons(value:Date):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__HELP__LAST_VIEW_DATE__PLAY_LESSONS, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__HELP__LAST_VIEW_DATE__PLAY_LESSONS__SAVED, true);
      _persistenceManager.save();
   }

   public function persistHelp_LastViewDate_SelectLessons(value:Date):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__HELP__LAST_VIEW_DATE__SELECT_LESSONS, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__HELP__LAST_VIEW_DATE__SELECT_LESSONS__SAVED, true);
      _persistenceManager.save();
   }

   public function persistHelp_LastViewDate_SelectMode(value:Date):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__HELP__LAST_VIEW_DATE__SELECT_MODE, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__HELP__LAST_VIEW_DATE__SELECT_MODE__SAVED, true);
      _persistenceManager.save();
   }

   public function persistHomeScreenDisplayCount(value:int):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__HOME_SCREEN_DISPLAY_COUNT, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_HOME_SCREEN_DISPLAY_COUNT_SAVED, true);
      _persistenceManager.save();
   }

   /*public function persistMostRecentAppVersionWhereUserAgreedToLegalNotice(value:Number):void
   {
       if (!_persistenceManager)
           return;
       if (isDataWipeActivityBlockActive)
           return;
       _persistenceManager.setProperty(_DATA_TYPE_NAME__MOST_RECENT_APP_VERSION_WHERE_USER_AGREED_TO_LEGAL_NOTICE, value);
       _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_MOST_RECENT_APP_VERSION_WHERE_USER_AGREED_TO_LEGAL_NOTICE_SAVED, true);
       _persistenceManager.save();
   }*/

   /*public function persistMostRecentDownloadLessonsTime(value:Date):void
   {
       if (!_persistenceManager)
           return;
       if (isDataWipeActivityBlockActive)
           return;
       _persistenceManager.setProperty(_DATA_TYPE_NAME__MOST_RECENT_DOWNLOAD_LESSONS_TIME, value);
       _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_MOST_RECENT_DOWNLOAD_LESSONS_TIME_SAVED, true);
       _persistenceManager.save();
   }*/

   public function persistMostRecent_NewsUpdate(value:XML):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE__SAVED, true);
      _persistenceManager.save();
   }

   public function persistMostRecent_NewsUpdate_DateRetrieved(value:Date):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE__DATE_RETRIEVED, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE__DATE_RETRIEVED__SAVED, true);
      _persistenceManager.save();
   }

   public function persistMostRecent_NewsUpdate_DateViewed(value:Date):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE__DATE_VIEWED, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE__DATE_VIEWED__SAVED, true);
      _persistenceManager.save();
   }

   public function persistMostRecent_NewsUpdateDate(value:Date):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE_DATE, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE_DATE__SAVED, true);
      _persistenceManager.save();
   }

   public function persistMostRecent_NewsUpdateDate_DateRetrieved(value:Date):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE_DATE__DATE_RETRIEVED, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE_DATE__DATE_RETRIEVED__SAVED, true);
      _persistenceManager.save();
   }

   public function persistNaggingDisabled(value:Boolean):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__NAGGING_DISABLED, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_NAGGING_DISABLED_SAVED, true);
      _persistenceManager.save();
   }

   public function persistSelectedLearningModeId(value:int):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__SELECTED_LEARNING_MODE_ID, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_SELECTED_LEARNING_MODE_ID_SAVED, true);
      _persistenceManager.save();
   }

   public function persistSelectedLessonDownloadLevels(value:Array):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      var lessonDownloadLevelList:Array = [];
      for each (var levelVO:LevelVO in value) {
         lessonDownloadLevelList.push(levelVO.id);
      }
      _persistenceManager.setProperty(_DATA_TYPE_NAME__SELECTED_LESSON_DOWNLOAD_LEVELS, lessonDownloadLevelList);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_SELECTED_LESSON_DOWNLOAD_LEVELS_SAVED, true);
      _persistenceManager.save();
   }

   public function persistSelectedLessonVersions(value:Vector.<LessonVersionVO>):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      var lessonVersionInfoVector:Vector.<LessonVersionInfo> = new Vector.<LessonVersionInfo>();
      for each (var lessonVersionVO:LessonVersionVO in value) {
         var lessonVersionInfo:LessonVersionInfo = new LessonVersionInfo();
         lessonVersionInfo.contentProviderId = lessonVersionVO.contentProviderId;
         lessonVersionInfo.lessonVersionSignature = lessonVersionVO.lessonVersionSignature;
         lessonVersionInfoVector.push(lessonVersionInfo);
      }
      _persistenceManager.setProperty(_DATA_TYPE_NAME__SELECTED_LESSON_VERSIONS, lessonVersionInfoVector);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_SELECTED_LESSON_VERSIONS_SAVED, true);
      _persistenceManager.save();
   }

   public function persistTargetLanguageId(value:int):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__TARGET_LANGUAGE_ID, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_TARGET_LANGUAGE_ID_SAVED, true);
      _persistenceManager.save();
   }

   public function persistTextDisplayMode(value:String):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__TEXT_DISPLAY_MODE, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_TEXT_DISPLAY_MODE_SAVED, true);
      _persistenceManager.save();
   }

   public function persistUseRecommendedLibraries(value:Boolean):void {
      if (!_persistenceManager)
         return;
      if (isDataWipeActivityBlockActive)
         return;
      _persistenceManager.setProperty(_DATA_TYPE_NAME__USE_RECOMMENDED_LIBRARIES, value);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_USE_RECOMMENDED_LIBRARIES_SAVED, true);
      _persistenceManager.save();
   }

   public function retrieveAppInstallDate():Date {
      if (!_persistenceManager)
            return null;
      if (!retrieveIsAppInstallDateSaved())
            return null;
      var result:Date = (_persistenceManager.getProperty(_DATA_TYPE_NAME__APP_INSTALL_DATE) as Date);
      Log.info("AppStatePersistenceManager.retrieveAppInstallDate() - returning: " + result);
      return result;
   }

   public function retrieveAutoDownloadLessons():Boolean {
      if (!_persistenceManager)
            return false;
      if (!retrieveIsAutoDownloadLessonsSaved())
            return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__AUTO_DOWNLOAD_LESSONS));
      Log.info("AppStatePersistenceManager.retrieveAutoDownloadLessons() - returning: " + result);
      return result;
   }

   public function retrieveCurrAppVersion():Number {
      if (!_persistenceManager)
            return -1;
      if (!retrieveIsCurrAppVersionSaved())
            return -1;
      var result:Number = Number(_persistenceManager.getProperty(_DATA_TYPE_NAME__CURR_APP_VERSION));
      Log.info("AppStatePersistenceManager.retrieveCurrAppVersion() - returning: " + result);
      return result;
   }

   public function retrieveCurrChunkIndex():int {
      if (!_persistenceManager)
            return -1;
      if (!retrieveIsCurrChunkIndexSaved())
            return -1;
      var result:int = int(_persistenceManager.getProperty(_DATA_TYPE_NAME__CURR_CHUNK_INDEX));
      Log.info("AppStatePersistenceManager.retrieveCurrChunkIndex() - returning: " + result);
      return result;
   }

   public function retrieveCurrLessonVersion():LessonVersionInfo {
      if (!_persistenceManager)
            return null;
      if (!retrieveIsCurrLessonVersionSaved())
            return null;
      var result:LessonVersionInfo = LessonVersionInfo(_persistenceManager.getProperty(_DATA_TYPE_NAME__CURR_LESSON_VERSION));
      Log.info("AppStatePersistenceManager.retrieveCurrLessonVersion() - returning: " + result);
      return result;
   }

   public function retrieveDataSchemaAppVersion():Number {
      if (!_persistenceManager)
            return -1;
      if (!retrieveIsDataSchemaAppVersionSaved())
            return -1;
      var result:Number = Number(_persistenceManager.getProperty(_DATA_TYPE_NAME__DATA_SCHEMA_APP_VERSION));
      Log.info("AppStatePersistenceManager.retrieveDataSchemaAppVersion() - returning: " + result);
      return result;
   }

   public function retrieveHasUserSelectedDownloadBetaLessonsOption():Boolean {
      if (!_persistenceManager)
            return false;
      if (!retrieveIsHasUserSelectedDownloadBetaLessonsOptionSaved())
            return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__HAS_USER_SELECTED_DOWNLOAD_BETA_LESSONS_OPTION));
      Log.info("AppStatePersistenceManager.retrieveHasUserSelectedDownloadBetaLessonsOption() - returning: " + result);
      return result;
   }
   public function retrieveHelp_LastViewDate_PlayLessons():Date {
      if (!_persistenceManager)
            return null;
      if (!retrieveIsHelp_LastViewDate_PlayLessons_Saved())
            return null;
      var result:Date = (_persistenceManager.getProperty(_DATA_TYPE_NAME__HELP__LAST_VIEW_DATE__PLAY_LESSONS) as Date);
      Log.info("AppStatePersistenceManager.retrieveHelp_LastViewDate_PlayLessons() - returning: " + result);
      return result;
   }

   public function retrieveHelp_LastViewDate_SelectLessons():Date {
      if (!_persistenceManager)
            return null;
      if (!retrieveIsHelp_LastViewDate_SelectLessons_Saved())
            return null;
      var result:Date = (_persistenceManager.getProperty(_DATA_TYPE_NAME__HELP__LAST_VIEW_DATE__SELECT_LESSONS) as Date);
      Log.info("AppStatePersistenceManager.retrieveHelp_LastViewDate_SelectLessons() - returning: " + result);
      return result;
   }

   public function retrieveHelp_LastViewDate_SelectMode():Date {
      if (!_persistenceManager)
            return null;
      if (!retrieveIsHelp_LastViewDate_SelectMode_Saved())
            return null;
      var result:Date = (_persistenceManager.getProperty(_DATA_TYPE_NAME__HELP__LAST_VIEW_DATE__SELECT_MODE) as Date);
      Log.info("AppStatePersistenceManager.retrieveHelp_LastViewDate_SelectMode() - returning: " + result);
      return result;
   }

   public function retrieveHomeScreenDisplayCount():int {
      if (!_persistenceManager)
            return -1;
      if (!retrieveIsHomeScreenDisplayCountSaved())
            return -1;
      var result:int = int(_persistenceManager.getProperty(_DATA_TYPE_NAME__HOME_SCREEN_DISPLAY_COUNT));
      Log.info("AppStatePersistenceManager.retrieveHomeScreenDisplayCount() - returning: " + result);
      return result;
   }

   public function retrieveIsAppInstallDateSaved():Boolean {
      if (!_persistenceManager)
            return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_APP_INSTALL_DATE_SAVED));
      return result;
   }

   public function retrieveIsAutoDownloadLessonsSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_AUTO_DOWNLOAD_LESSONS_SAVED));
      return result;
   }

   public function retrieveIsCurrAppVersionSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_CURR_APP_VERSION_SAVED));
      return result;
   }

   public function retrieveIsCurrChunkIndexSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_CURR_CHUNK_INDEX_SAVED));
      return result;
   }

   public function retrieveIsCurrLessonVersionSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_CURR_LESSON_VERSION_SAVED));
      return result;
   }

   public function retrieveIsDataSchemaAppVersionSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_DATA_SCHEMA_APP_VERSION_SAVED));
      return result;
   }

   public function retrieveIsHasUserSelectedDownloadBetaLessonsOptionSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_HAS_USER_SELECTED_DOWNLOAD_BETA_LESSONS_OPTION_SAVED));
      return result;
   }

   public function retrieveIsHelp_LastViewDate_PlayLessons_Saved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS__HELP__LAST_VIEW_DATE__PLAY_LESSONS__SAVED));
      return result;
   }

   public function retrieveIsHelp_LastViewDate_SelectLessons_Saved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS__HELP__LAST_VIEW_DATE__SELECT_LESSONS__SAVED));
      return result;
   }

   public function retrieveIsHelp_LastViewDate_SelectMode_Saved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS__HELP__LAST_VIEW_DATE__SELECT_MODE__SAVED));
      return result;
   }

   public function retrieveIsHomeScreenDisplayCountSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_HOME_SCREEN_DISPLAY_COUNT_SAVED));
      return result;
   }

   /*public function retrieveIsMostRecentAppVersionWhereUserAgreedToLegalNoticeSaved():Boolean
   {
       if (!_persistenceManager)
           return false;
       var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_MOST_RECENT_APP_VERSION_WHERE_USER_AGREED_TO_LEGAL_NOTICE_SAVED));
       return result;
   }*/

   /*public function retrieveIsMostRecentDownloadLessonsTimeSaved():Boolean
   {
       if (!_persistenceManager)
           return false;
       var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_MOST_RECENT_DOWNLOAD_LESSONS_TIME_SAVED));
       return result;
   }*/

   public function retrieveIsLessonVersionEntryCountSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_LESSON_VERSION_ENTRY_COUNT_SAVED));
      return result;
   }

   public function retrieveIs_MostRecent_NewsUpdate_Saved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE__SAVED));
      return result;
   }

   public function retrieveIs_MostRecent_NewsUpdate_DateRetrieved_Saved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE__DATE_RETRIEVED__SAVED));
      return result;
   }

   public function retrieveIs_MostRecent_NewsUpdate_DateViewed_Saved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE__DATE_VIEWED__SAVED));
      return result;
   }

   public function retrieveIs_MostRecent_NewsUpdateDate_Saved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE_DATE__SAVED));
      return result;
   }

   public function retrieveIs_MostRecent_NewsUpdateDate_DateRetrieved_Saved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE_DATE__DATE_RETRIEVED__SAVED));
      return result;
   }

   public function retrieveIsNaggingDisabledSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_NAGGING_DISABLED_SAVED));
      return result;
   }

   public function retrieveIsSelectedLearningModeIdSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_SELECTED_LEARNING_MODE_ID_SAVED));
      return result;
   }

   public function retrieveIsSelectedLessonDownloadLevelsSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_SELECTED_LESSON_DOWNLOAD_LEVELS_SAVED));
      return result;
   }

   public function retrieveIsSelectedLessonVersionsSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_SELECTED_LESSON_VERSIONS_SAVED));
      return result;
   }

   public function retrieveIsTargetLanguageIdSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_TARGET_LANGUAGE_ID_SAVED));
      return result;
   }

   public function retrieveIsTextDisplayModeSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_TEXT_DISPLAY_MODE_SAVED));
      return result;
   }

   public function retrieveIsUseRecommendedLibrariesSaved():Boolean {
      if (!_persistenceManager)
         return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__IS_USE_RECOMMENDED_LIBRARIES_SAVED));
      return result;
   }

   /*public function retrieveMostRecentAppVersionWhereUserAgreedToLegalNotice():Number
   {
       if (!_persistenceManager)
           return -1;
       var result:Number = Number(_persistenceManager.getProperty(_DATA_TYPE_NAME__MOST_RECENT_APP_VERSION_WHERE_USER_AGREED_TO_LEGAL_NOTICE));
       return result;
   }*/

   /*public function retrieveMostRecentDownloadLessonsTime():Date
   {
       if (!_persistenceManager)
           return null;
       var result:Date = (_persistenceManager.getProperty(_DATA_TYPE_NAME__MOST_RECENT_DOWNLOAD_LESSONS_TIME) as Date);
       return result;
   }*/

   public function retrieveLessonVersionEntryCount():int {
      if (!_persistenceManager)
            return -1;
      if (!retrieveIsLessonVersionEntryCountSaved())
            return -1;
      var result:int = int(_persistenceManager.getProperty(_DATA_TYPE_NAME__LESSON_VERSION_ENTRY_COUNT));
      Log.info("AppStatePersistenceManager.retrieveLessonVersionEntryCount() - returning: " + result);
      return result;
   }

   public function retrieveMostRecent_NewsUpdate():XML {
      if (!_persistenceManager)
            return null;
      if (!retrieveIs_MostRecent_NewsUpdate_Saved())
            return null;
      var result:XML = XML(_persistenceManager.getProperty(_DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE));
      Log.info("AppStatePersistenceManager.retrieveMostRecent_NewsUpdate() - returning: " + result);
      return result;
   }

   public function retrieveMostRecent_NewsUpdate_DateRetrieved():Date {
      if (!_persistenceManager)
            return null;
      if (!retrieveIs_MostRecent_NewsUpdate_DateRetrieved_Saved())
            return null;
      var result:Date = (_persistenceManager.getProperty(_DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE__DATE_RETRIEVED) as Date);
      Log.info("AppStatePersistenceManager.retrieveMostRecent_NewsUpdate_DateRetrieved() - returning: " + result);
      return result;
   }

   public function retrieveMostRecent_NewsUpdate_DateViewed():Date {
      if (!_persistenceManager)
            return null;
      if (!retrieveIs_MostRecent_NewsUpdate_DateViewed_Saved())
            return null;
      var result:Date = (_persistenceManager.getProperty(_DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE__DATE_VIEWED) as Date);
      Log.info("AppStatePersistenceManager.retrieveMostRecent_NewsUpdate_DateViewed() - returning: " + result);
      return result;
   }

   public function retrieveMostRecent_NewsUpdateDate():Date {
      if (!_persistenceManager)
            return null;
      if (!retrieveIs_MostRecent_NewsUpdateDate_Saved())
            return null;
      var result:Date = (_persistenceManager.getProperty(_DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE_DATE) as Date);
      Log.info("AppStatePersistenceManager.retrieveMostRecent_NewsUpdateDate() - returning: " + result);
      return result;
   }

   public function retrieveMostRecent_NewsUpdateDate_DateRetrieved():Date {
      if (!_persistenceManager)
            return null;
      if (!retrieveIs_MostRecent_NewsUpdateDate_DateRetrieved_Saved())
            return null;
      var result:Date = (_persistenceManager.getProperty(_DATA_TYPE_NAME__MOST_RECENT__NEWS_UPDATE_DATE__DATE_RETRIEVED) as Date);
      Log.info("AppStatePersistenceManager.retrieveMostRecent_NewsUpdateDate_DateRetrieved() - returning: " + result);
      return result;
   }

   public function retrieveNaggingDisabled():Boolean {
      if (!_persistenceManager)
            return false;
      if (!retrieveIsNaggingDisabledSaved())
            return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__NAGGING_DISABLED));
      Log.info("AppStatePersistenceManager.retrieveNaggingDisabled() - returning: " + result);
      return result;
   }

   public function retrieveSelectedLearningModeId():int {
      if (!_persistenceManager)
            return -1;
      if (!retrieveIsSelectedLearningModeIdSaved())
            return -1;
      var result:int = int(_persistenceManager.getProperty(_DATA_TYPE_NAME__SELECTED_LEARNING_MODE_ID));
      Log.info("AppStatePersistenceManager.retrieveSelectedLearningModeId() - returning: " + result);
      return result;
   }

   public function retrieveSelectedLessonDownloadLevels():Array {
      if (!_persistenceManager)
            return null;
      if (!retrieveIsSelectedLessonDownloadLevelsSaved())
            return null;
      var result:Array = _persistenceManager.getProperty(_DATA_TYPE_NAME__SELECTED_LESSON_DOWNLOAD_LEVELS) as Array;
      Log.info("AppStatePersistenceManager.retrieveSelectedLessonDownloadLevels() - returning: " + result);
      return result;
   }

   public function retrieveSelectedLessonVersions():Vector.<LessonVersionInfo> {
      if (!_persistenceManager)
            return null;
      if (!retrieveIsSelectedLessonVersionsSaved())
            return null;
      var result:Vector.<LessonVersionInfo> = Vector.<LessonVersionInfo>(_persistenceManager.getProperty(_DATA_TYPE_NAME__SELECTED_LESSON_VERSIONS));
      Log.info("AppStatePersistenceManager.retrieveSelectedLessonVersions() - returning: " + result);
      return result;
   }

   public function retrieveTargetLanguageId():int {
      if (!_persistenceManager)
            return -1;
      if (!retrieveIsTargetLanguageIdSaved())
            return -1;
      var result:int = int(_persistenceManager.getProperty(_DATA_TYPE_NAME__TARGET_LANGUAGE_ID));
      Log.info("AppStatePersistenceManager.retrieveTargetLanguageId() - returning: " + result);
      return result;
   }

   public function retrieveTextDisplayMode():String {
      if (!_persistenceManager)
            return Constant_TextDisplayModes.TEXT_DISPLAY_MODE__NONE;
      if (!retrieveIsTextDisplayModeSaved())
            return Constant_TextDisplayModes.TEXT_DISPLAY_MODE__NONE;
      var result:String = String(_persistenceManager.getProperty(_DATA_TYPE_NAME__TEXT_DISPLAY_MODE));
      Log.info("AppStatePersistenceManager.retrieveTargetLanguageId() - returning: " + result);
      return result;
   }

   public function retrieveUseRecommendedLibraries():Boolean {
      if (!_persistenceManager)
            return false;
      if (!retrieveIsUseRecommendedLibrariesSaved())
            return false;
      var result:Boolean = Boolean(_persistenceManager.getProperty(_DATA_TYPE_NAME__USE_RECOMMENDED_LIBRARIES));
      Log.info("AppStatePersistenceManager.retrieveUseRecommendedLibraries() - returning: " + result);
      return result;
   }

   public function wipeData():void {
      isDataWipeActivityBlockActive = true;
      if (!_persistenceManager) {
         Log.error("AppStatePersistenceManager.wipeData(): _persistenceManager is null");
         return;
      }
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_APP_INSTALL_DATE_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_AUTO_DOWNLOAD_LESSONS_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_CURR_APP_VERSION_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_CURR_CHUNK_INDEX_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_CURR_LESSON_VERSION_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_DATA_SCHEMA_APP_VERSION_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_HAS_USER_SELECTED_DOWNLOAD_BETA_LESSONS_OPTION_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__HELP__LAST_VIEW_DATE__PLAY_LESSONS__SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__HELP__LAST_VIEW_DATE__SELECT_LESSONS__SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__HELP__LAST_VIEW_DATE__SELECT_MODE__SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_HOME_SCREEN_DISPLAY_COUNT_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_MOST_RECENT_APP_VERSION_WHERE_USER_AGREED_TO_LEGAL_NOTICE_SAVED, false);
      //_persistenceManager.setProperty(_DATA_TYPE_NAME__IS_MOST_RECENT_DOWNLOAD_LESSONS_TIME_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE__DATE_RETRIEVED__SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE__DATE_VIEWED__SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE__SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE_DATE__DATE_RETRIEVED__SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS__MOST_RECENT__NEWS_UPDATE_DATE__SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_NAGGING_DISABLED_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_SELECTED_LEARNING_MODE_ID_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_SELECTED_LESSON_DOWNLOAD_LEVELS_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_SELECTED_LESSON_VERSIONS_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_TARGET_LANGUAGE_ID_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_TEXT_DISPLAY_MODE_SAVED, false);
      _persistenceManager.setProperty(_DATA_TYPE_NAME__IS_USE_RECOMMENDED_LIBRARIES_SAVED, false);
      _persistenceManager.save();
   }

}
}

