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




Assumptions:
 - This class will only contain data for LessonVersions matching one native language and one target language.
   Currently there's no mechanism for changing these once selected. If we implement such a mechanism we
   need to ensure that wipeData() is called.





*/
package com.langcollab.languagementor.model {
import com.brightworks.base.Callbacks;
import com.brightworks.component.treelist.TreeListLevelInfo;
import com.brightworks.db.SQLiteQueryData;
import com.brightworks.db.SQLiteQueryData_Delete;
import com.brightworks.db.SQLiteQueryData_Insert;
import com.brightworks.db.SQLiteQueryData_Select;
import com.brightworks.db.SQLiteQueryData_Update;
import com.brightworks.event.BwEvent;
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_AIR;
import com.brightworks.util.Utils_ArrayVectorEtc;
import com.brightworks.util.Utils_ArrayVectorEtc;
import com.brightworks.util.Utils_DateTime;
import com.brightworks.util.Utils_Dispose;
import com.brightworks.util.Utils_File;
import com.brightworks.util.Utils_GoogleAnalytics;
import com.brightworks.util.Utils_String;
import com.brightworks.util.Utils_System;
import com.brightworks.util.Utils_URL;
import com.brightworks.util.Utils_XML;
import com.brightworks.util.download.DownloadBandwidthRecorder;
import com.brightworks.util.singleton.SingletonManager;
import com.brightworks.util.tree.Utils_Tree;
import com.brightworks.vo.IVO;
import com.langcollab.languagementor.component.lessonversionlist.LessonVersionList;
import com.langcollab.languagementor.constant.Constant_DownloadedLessons_SingleOrDualLanguageOrBoth;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.constant.Constant_MentorTypeSpecific;
import com.langcollab.languagementor.constant.Constant_MentorTypes;
import com.langcollab.languagementor.controller.Command_LoadLearningModeDescriptions;
import com.langcollab.languagementor.controller.lessondownload.LessonDownloadController;
import com.langcollab.languagementor.model.appstatepersistence.AppStatePersistenceManager;
import com.langcollab.languagementor.model.appstatepersistence.LessonVersionInfo;
import com.langcollab.languagementor.model.currentlessons.CurrentLessons;
import com.langcollab.languagementor.util.Utils_LangCollab;
import com.langcollab.languagementor.vo.ChunkFileVO;
import com.langcollab.languagementor.vo.ChunkVO;
import com.langcollab.languagementor.vo.LanguageDisplayNameVO;
import com.langcollab.languagementor.vo.LanguageVO;
import com.langcollab.languagementor.vo.LearningModeVO;
import com.langcollab.languagementor.vo.LessonVersionNativeLanguageVO;
import com.langcollab.languagementor.vo.LessonVersionTargetLanguageVO;
import com.langcollab.languagementor.vo.LessonVersionVO;
import com.langcollab.languagementor.vo.LevelVO;
import com.langcollab.languagementor.vo.LibraryVO;
import com.langcollab.languagementor.vo.ReleaseTypeVO;
import com.langcollab.languagementor.vo.TextDisplayTypeVO;

import flash.desktop.NativeApplication;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.rpc.events.FaultEvent;

public class MainModel extends EventDispatcher implements IManagedSingleton {

   private static var _instance:MainModel;

   public var chunksCount_PlayedInSession:uint;
   public var configFileInfo:ConfigFileInfo;
   [Bindable]
   public var currentApplicationState:int = 0;
   [Bindable]
   public var currentLearningModeId:int;
   [Bindable]
   public var currentUserId:int = 1; ///
   public var downloadBandwidthRecorder:DownloadBandwidthRecorder;
   public var internetConnectionActive:Boolean;
   public var isDataWipeActivityBlockActive:Boolean;
   public var isRecommendedLibraryInfoUpdatedForCurrentTargetLanguage:Boolean = false;
   public var isSingleLanguageLessonsSelectedInDualLanguageModeAlertDisplayed:Boolean
   public var lessonsSelectionTreeSortOptions:Array;
   [Bindable]
   public var mostRecentDownloadProcessStartAllowedEventTime:Date;
   [Bindable]
   public var mostRecentDownloadLessonProcessStatus:String = "";
   [Bindable]
   public var recentDBAccessCount:Number;

   private var _appStatePersistenceManager:AppStatePersistenceManager;
   private var _currentLessons:CurrentLessons;
   private var _currentNativeLanguageId:int = -1;
   private var _currentNativeLanguageResourceXML:XML;
   private var _currentNativeLanguageVO:LanguageVO;
   private var _currentTargetLanguageId:int = -1;
   private var _currentTargetLanguageResourceXML:XML;
   private var _currentTargetLanguageVO:LanguageVO;
   private var _data:Data;
   private var _dbAccessTimes:Array;
   private var _isDBDataInitialized:Boolean;
   private var _isTargetLanguageInitialized:Boolean;

   // Cached Data - We cache these in order to decrease the number of calls to the DB
   private var _index_LanguageDisplayNames_Alphabetizable_ForCurrentNativeLanguage_by_LanguageId:Dictionary = new Dictionary();
   private var _index_LanguageDisplayNames_ForCurrentNativeLanguage_by_LanguageId:Dictionary = new Dictionary();
   private var _index_LanguageIDs_by_Iso639_3Code:Dictionary = new Dictionary();
   private var _index_LanguageVOs_by_LanguageId:Dictionary = new Dictionary();
   private var _index_LearningModeVOs_by_ID:Dictionary = new Dictionary();
   private var _index_LessonVersionNativeLanguageVOs_by_LessonVersionVO:Dictionary = new Dictionary();
   private var _index_LessonVersionTargetLanguageVOs_by_LessonVersionVO:Dictionary = new Dictionary();
   private var _index_LevelIDs_by_LabelToken:Dictionary = new Dictionary();
   private var _index_LevelVOs_by_ID:Dictionary = new Dictionary();
   private var _index_LevelVOs_by_LabelToken:Dictionary = new Dictionary();
   private var _index_ReleaseTypeVOs_by_ReleaseTypeToken:Dictionary = new Dictionary();
   private var _index_ReleaseTypeVOs_by_ID:Dictionary = new Dictionary();
   private var _index_ReleaseTypeVOs_by_LabelToken:Dictionary = new Dictionary();
   private var _index_TextDisplayTypeID_by_TextDisplayTypeName:Dictionary = new Dictionary();
   private var _index_TextDisplayTypeName_by_TextDisplayTypeID:Dictionary = new Dictionary();
   private var _index_TextDisplayTypeVOs_by_TypeName:Dictionary = new Dictionary();
   private var _list_LessonVersionVOs:Array;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private var _autoDownloadLessons:Boolean;

   [Bindable]
   public function get autoDownloadLessons():Boolean {
      return _autoDownloadLessons;
   }

   public function set autoDownloadLessons(value:Boolean):void {
      _autoDownloadLessons = value;
      _appStatePersistenceManager.persistAutoDownloadLessons(value);
   }

   // Returns a Constant_DownloadedLessons_SingleOrDualLanguageOrBoth constant
   public function get downloadedLessonsAreSingleOrDualLanguageOrAMixOfBoth():String {
      if (getLessonVersionCount() < 1) {
         return Constant_DownloadedLessons_SingleOrDualLanguageOrBoth.NO_DOWNLOADED_LESSONS;
      }
      var oneOrMoreSingleLanguageLessonsDownloaded:Boolean;
      var oneOrMoreDualLanguageLessonsDownloaded:Boolean;
      for each (var lv:LessonVersionVO in getLessonVersionVOs()) {
         if (lv.isDualLanguage) {
            oneOrMoreDualLanguageLessonsDownloaded = true;
         }
         else {
            oneOrMoreSingleLanguageLessonsDownloaded = true;
         }
         if (oneOrMoreSingleLanguageLessonsDownloaded && oneOrMoreDualLanguageLessonsDownloaded) {
            break;
         }
      }
      if (oneOrMoreSingleLanguageLessonsDownloaded && oneOrMoreDualLanguageLessonsDownloaded) {
         return Constant_DownloadedLessons_SingleOrDualLanguageOrBoth.BOTH;
      }
      else if (oneOrMoreSingleLanguageLessonsDownloaded) {
         return Constant_DownloadedLessons_SingleOrDualLanguageOrBoth.SINGLE;
      }
      else if (oneOrMoreDualLanguageLessonsDownloaded) {
         return Constant_DownloadedLessons_SingleOrDualLanguageOrBoth.DUAL;
      }
      else {
         // This shouldn't happen
         Log.warn("MainModel.get downloadedLessonsAreSingleOrDualLanguageOrAMixOfBoth() - we have LessonVersionVOs, yet none are either single or dual-language lessons, which is impossible");
         return Constant_DownloadedLessons_SingleOrDualLanguageOrBoth.UNKNOWN;
      }
   }

   private var _hasUserSelectedDownloadBetaLessonsOption:Boolean = false;

   [Bindable]
   public function get hasUserSelectedDownloadBetaLessonsOption():Boolean {
      return _hasUserSelectedDownloadBetaLessonsOption;
   }

   public function set hasUserSelectedDownloadBetaLessonsOption(value:Boolean):void {
      _hasUserSelectedDownloadBetaLessonsOption = value;
      _appStatePersistenceManager.persistHasUserSelectedDownloadBetaLessonsOption(value);
   }

   [Bindable(event="isDBDataAndTargetLanguageInitializedChange")]
   public function get isDBDataAndTargetLanguageInitialized():Boolean {
      return (_isDBDataInitialized && _isTargetLanguageInitialized);
   }

   [Bindable(event="isDBDataInitializedChange")]
   public function get isDBDataInitialized():Boolean {
      return _isDBDataInitialized;
   }

   private var _learningModeDescriptionsHTML:Dictionary;

   [Bindable]
   public function get learningModeDescriptionsHTML():Dictionary {
      return _learningModeDescriptionsHTML;
   }

   public function set learningModeDescriptionsHTML(value:Dictionary):void {
      if (_learningModeDescriptionsHTML)
         Utils_Dispose.disposeDictionary(_learningModeDescriptionsHTML, true);
      _learningModeDescriptionsHTML = value;
   }

   private var _selectedLessonDownloadLevels_PrimaryLevels:Array

   public function get selectedLessonDownloadLevels_PrimaryLevels():Array {
      if (_selectedLessonDownloadLevels_PrimaryLevels) {
         return _selectedLessonDownloadLevels_PrimaryLevels.slice();
      } else {
         return null;
      }
   }

   public function set selectedLessonDownloadLevels_PrimaryLevels(value:Array):void {
      _selectedLessonDownloadLevels_PrimaryLevels = value.slice();
      _appStatePersistenceManager.persistSelectedLessonDownloadLevels(value);
   }

   private var _useRecommendedLibraries:Boolean = true;

   [Bindable]
   public function get useRecommendedLibraries():Boolean {
      return _useRecommendedLibraries;
   }

   public function set useRecommendedLibraries(value:Boolean):void {
      _useRecommendedLibraries = value;
      _appStatePersistenceManager.persistUseRecommendedLibraries(value);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function MainModel(manager:SingletonManager) {
      _instance = this;
      downloadBandwidthRecorder = new DownloadBandwidthRecorder();
   }

   public function addLessonVersionVOToCache(vo:LessonVersionVO):void {
      _list_LessonVersionVOs.push(vo);
      var lvnlvo:LessonVersionNativeLanguageVO =
            getLessonVersionNativeLanguageVOFromLessonVersionVOFromDB(vo);
      if (!lvnlvo)
         Log.fatal(["MainModel.addLessonVersionVOToCache(): Cannot retreive LessonVersionNativeLanguageVO for LessonVersionVO from DB", vo]);
      _index_LessonVersionNativeLanguageVOs_by_LessonVersionVO[vo] = lvnlvo;
      var lvtlvo:LessonVersionTargetLanguageVO =
            getLessonVersionTargetLanguageVOFromLessonVersionVOFromDB(vo);
      if (!lvtlvo)
         Log.fatal(["MainModel.addLessonVersionVOToCache(): Cannot retrieve LessonVersionTargetLanguageVO for LessonVersionVO from DB", vo]);
      _index_LessonVersionTargetLanguageVOs_by_LessonVersionVO[vo] = lvtlvo;
   }

   public function areAnyLessonDownloadLevelsCurrentlySelected():Boolean {
      if (selectedLessonDownloadLevels_PrimaryLevels) {
         return (selectedLessonDownloadLevels_PrimaryLevels.length > 0);
      } else {
         return false;
      }
   }

   public function deleteData(callingMethodName:String, queryDataList:Array):MainModelDBOperationReport {
      var startTime:Number = Utils_DateTime.getCurrentMS_BasedOnDate();
      var result:MainModelDBOperationReport = new MainModelDBOperationReport();
      result.sqliteTransactionReport = _data.deleteData(queryDataList);
      if (!result.sqliteTransactionReport.isSuccessful)
         result.isAnyProblems = true;
      var index_dataProblemTypes_by_problematicQueryDataInstances:Dictionary = new Dictionary;
      for each (var queryData:SQLiteQueryData_Delete in queryDataList) {
         var o:Object = result.sqliteTransactionReport.index_rowsAffected_by_queryData[queryData];
         if (o is Number) {
            if (!queryData.isRowsAffectedCountValid(Number(o))) {
               index_dataProblemTypes_by_problematicQueryDataInstances[queryData] = SQLiteQueryData.PROBLEM_TYPE__ROWS_AFFECTED_COUNT_INVALID;
               result.isAnyProblems = true;
            }
         } else {
            index_dataProblemTypes_by_problematicQueryDataInstances[queryData] = SQLiteQueryData.PROBLEM_TYPE__NO_ROWS_AFFECTED_COUNT;
            result.isAnyProblems = true;
         }
      }
      if (Utils_ArrayVectorEtc.getDictionaryLength(index_dataProblemTypes_by_problematicQueryDataInstances) > 0)
         result.index_dataProblemTypes_by_problematicQueryDataInstances = index_dataProblemTypes_by_problematicQueryDataInstances;
      var duration:Number = Utils_DateTime.getCurrentMS_BasedOnDate() - startTime;
      Log.info("MainModel.deleteData(): " + duration + "ms - " + callingMethodName + "()");
      return result;
   }

   public function deleteLessonVersion(lvvo:LessonVersionVO):MainModelDBOperationReport {
      var voList:Array = [];
      voList.push(lvvo);
      var chunkVOList:Array = getChunkVOListFromLessonVersionVO(lvvo);
      var lessonVersionNativeLanguageVOList:Array = getLessonVersionNativeLanguageVOListFromLessonVersionVO(lvvo);
      var lessonVersionTargetLanguageVOList:Array = getLessonVersionTargetLanguageVOListFromLessonVersionVO(lvvo);
      Utils_ArrayVectorEtc.copyArrayItemsToArray(chunkVOList, voList);
      Utils_ArrayVectorEtc.copyArrayItemsToArray(lessonVersionNativeLanguageVOList, voList);
      Utils_ArrayVectorEtc.copyArrayItemsToArray(lessonVersionTargetLanguageVOList, voList);
      for each (var cvo:ChunkVO in chunkVOList) {
         var chunkFileVOList:Array = getChunkFileVOListFromChunkVO(cvo);
         Utils_ArrayVectorEtc.copyArrayItemsToArray(chunkFileVOList, voList);
      }
      var queryDataList:Array = [];
      for each (var vo:IVO in voList) {
         var queryData:SQLiteQueryData_Delete = new SQLiteQueryData_Delete(vo, 1, 1);
         queryDataList.push(queryData);
      }
      var report:MainModelDBOperationReport = deleteData("deleteLessonVersion", queryDataList);
      if (!report.isAnyProblems) {
         Utils_ArrayVectorEtc.useVoEqualsFunctionToDeleteFirstMatchingItemInArray(lvvo, _list_LessonVersionVOs, true);
         Utils_ArrayVectorEtc.useVoEqualsFunctionToDeleteMatchingPropInDictionary(lvvo, _index_LessonVersionNativeLanguageVOs_by_LessonVersionVO, true);
         Utils_ArrayVectorEtc.useVoEqualsFunctionToDeleteMatchingPropInDictionary(lvvo, _index_LessonVersionTargetLanguageVOs_by_LessonVersionVO, true);
      }
      return report;
   }

   public function doesCurrentTargetLanguageHaveRecommendedLibraries():Boolean {
      return _currentTargetLanguageVO.hasRecommendedLibraries;
   }

   private function doesLanguageHaveRecommendedLibrariesBasedOnRootConfigFile(passedISO639_3Code:String):Boolean {
      if (!isRecommendedLibraryInfoFromRootConfigFileAvailable()) {
         Log.error("MainModel.doesLanguageHaveRecommendedLibrariesBasedOnRootConfigFile() - isRecommendedLibraryInfoFromRootConfigFileAvailable() returns false - should have been checked before calling this merthod");
      }
      var result:Boolean = false;
      for (var i:int = 0; i < configFileInfo.targetLanguagesForWhichRecommendedLibrariesAreAvailable.children().length(); i++) {
         var targetLanguageNode:XML = configFileInfo.targetLanguagesForWhichRecommendedLibrariesAreAvailable.children()[i];
         var iso639_3Code:String = targetLanguageNode.name();
         if (iso639_3Code == passedISO639_3Code) {
            result = true;
            break;
         }
      }
      return result;
   }

   public function doesLearningModeHaveRecordPlayback(id:int):Boolean {
      return getLearningModeVOFromID(id).hasRecordPlayback;
   }

   public function doesLessonVersionNativeLanguageExist_ForLessonVersion(vo:LessonVersionVO):Boolean {
      var lvnlvo:LessonVersionNativeLanguageVO = _index_LessonVersionNativeLanguageVOs_by_LessonVersionVO[vo];
      return (lvnlvo != null);
   }

   public function doesLessonVersionTargetLanguageExist_ForLessonVersion(vo:LessonVersionVO):Boolean {
      var lvtlvo:LessonVersionTargetLanguageVO = _index_LessonVersionTargetLanguageVOs_by_LessonVersionVO[vo];
      return (lvtlvo != null);
   }

   public function getChunkCountForLessonVersionVO(vo:LessonVersionVO):int {
      var queryVO:ChunkVO = new ChunkVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      var report:MainModelDBOperationReport = selectData("getChunkCountForLessonVersionVO", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getChunkCountForLessonVersionVO(): selectData() reports problem", report]);
      var result:int = report.resultData.length;
      report.dispose();
      return result;
   }

   public function getChunkCountForLessonVersionVO_UnsuppressedChunks(vo:LessonVersionVO):uint {
      var queryVO:ChunkVO = new ChunkVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      queryVO.suppressed = false;
      var report:MainModelDBOperationReport = selectData("getChunkCountForLessonVersionVO_UnsuppressedChunks", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getChunkCountForLessonVersionVO_UnsuppressedChunks(): selectData() reports problem", report]);
      var result:uint = report.resultData.length;
      report.dispose();
      return result;
   }

   public function getChunkFileVOFromChunkVOAndLanguageCode(vo:ChunkVO, iso639_3Code:String):ChunkFileVO {
      var queryVO:ChunkFileVO = new ChunkFileVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      queryVO.chunkLocationInOrder = vo.locationInOrder;
      queryVO.fileNameBody = iso639_3Code;
      var report:MainModelDBOperationReport = selectData("getChunkFileVOFromChunkVOAndLanguageCode", queryVO, null, 1, 1);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getChunkFileVOFromChunkVOAndLanguageCode(): selectData() reports problem", report]);
      var result:ChunkFileVO = ChunkFileVO(report.resultData[0]);
      result.dispose();
      return result;
   }

   public function getChunkFileVOListFromChunkVO(vo:ChunkVO):Array {
      var queryVO:ChunkFileVO = new ChunkFileVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      queryVO.chunkLocationInOrder = vo.locationInOrder;
      var report:MainModelDBOperationReport = selectData("getChunkFileVOListFromChunkVO", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getChunkFileVOListFromChunkVO(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getChunkFileVOListFromLessonVersionVO(vo:LessonVersionVO):Array {
      var queryVO:ChunkFileVO = new ChunkFileVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      var report:MainModelDBOperationReport = selectData("getChunkFileVOListFromLessonVersionVO", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getChunkFileVOListFromLessonVersionVO(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getChunkVOListFromLessonVersionVO(vo:LessonVersionVO):Array {
      var queryVO:ChunkVO = new ChunkVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      var report:MainModelDBOperationReport = selectData("getChunkVOListFromLessonVersionVO", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getChunkVOListFromLessonVersionVO(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getChunkVOsSortedByLocationInOrderFromLessonVersionVO(vo:LessonVersionVO):Array {
      var queryVO:ChunkVO = new ChunkVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      var orderByPropNames:Vector.<String> = new Vector.<String>();
      orderByPropNames.push("locationInOrder");
      var report:MainModelDBOperationReport = selectData("getChunkVOsSortedByLocationInOrderFromLessonVersionVO", queryVO, orderByPropNames);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getChunkVOsSortedByLocationInOrderFromLessonVersionVO(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getCurrentLearningModeDisplayName():String {
      var vo:LearningModeVO = getLearningModeVOFromID(currentLearningModeId);
      if (!vo) {
         return null;
      }
      var result:String = getLearningModeDisplayNameFromId(vo.id);
      return result;
   }

   public function getCurrentLearningModeVO():LearningModeVO {
      var result:LearningModeVO = getLearningModeVOFromID(currentLearningModeId);
      return result;
   }

   public function getCurrentNativeLanguageDisplayName_InCurrentNativeLanguage():String {
      return getLanguageDisplayName_InCurrentNativeLanguage(_currentNativeLanguageId);
   }

   public function getCurrentNativeLanguageISO639_3Code():String {
      if (!_currentNativeLanguageVO)
            return null;
      return _currentNativeLanguageVO.iso639_3Code;
   }

   public function getCurrentTargetLanguageDisplayName_InCurrentNativeLanguage():String {
      return getLanguageDisplayName_InCurrentNativeLanguage(_currentTargetLanguageId);
   }

   public function getCurrentTargetLanguageISO639_3Code():String {
      if (!_currentTargetLanguageVO)
         return null;
      return _currentTargetLanguageVO.iso639_3Code;
   }

   public function getDownloadedLessonSelectionTreeData():ArrayCollection {
      var report:MainModelDBOperationReport = selectData("getDownloadedLessonSelectionTreeData", new LessonVersionVO());
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getDownloadedLessonSelectionTreeData(): selectData() reports problem", report]);
      var tempDownloadedLessonData:ArrayCollection = new ArrayCollection();
      for each (var vo:LessonVersionVO in report.resultData) {
         if (isLessonLevelSelectedForDownloading(vo.levelId)) {
            var lessonVersionDescriptorObject:Object = new Object();
            lessonVersionDescriptorObject.libraryDisplayString = getLibraryNativeLanguageNameFromLessonVersionVO(vo);
            lessonVersionDescriptorObject.levelDisplayString = getNativeLanguageLevelLabelFromLevelId(vo.levelId);
            lessonVersionDescriptorObject.levelSortInfo = getLevelLocationInOrderFromLevelId(vo.levelId);
            // VO instance is used when leaf is selected/deselected in Tree UI
            lessonVersionDescriptorObject.lessonVersionVO = vo;
            lessonVersionDescriptorObject.nameDisplayString = getLessonVersionNativeLanguageNameFromLessonVersionVO(vo);
            lessonVersionDescriptorObject.sortableNameString = getLessonVersionNativeLanguageSortableNameFromLessonVersionVO(vo);
            tempDownloadedLessonData.addItem(lessonVersionDescriptorObject);
         }
      }
      var result:ArrayCollection = Utils_Tree.createDataSourceObject(tempDownloadedLessonData, lessonsSelectionTreeSortOptions);
      report.dispose();
      return result;
   }

   public static function getInstance():MainModel {
      if (!(_instance))
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function getLanguageDisplayName_Alphabetizable_InCurrentNativeLanguage(languageId:int):String {
      if (_index_LanguageDisplayNames_Alphabetizable_ForCurrentNativeLanguage_by_LanguageId) {
         if (Utils_ArrayVectorEtc.doesDictionaryContainKey(_index_LanguageDisplayNames_Alphabetizable_ForCurrentNativeLanguage_by_LanguageId, languageId)) {
            return _index_LanguageDisplayNames_Alphabetizable_ForCurrentNativeLanguage_by_LanguageId[languageId];
         }
         else {
            Log.warn("MainModel.getLanguageDisplayName_Alphabetizable_InCurrentNativeLanguage - _index_LanguageDisplayNames_Alphabetizable_ForCurrentNativeLanguage_by_LanguageId has no property for languageId of: " + languageId);
            return null;
         }
      }
      else {
         Log.warn("MainModel.getLanguageDisplayName_Alphabetizable_InCurrentNativeLanguage - _index_LanguageDisplayNames_Alphabetizable_ForCurrentNativeLanguage_by_LanguageId is null");
         return null;
      }
   }

   public function getLanguageDisplayName_InCurrentNativeLanguage(languageId:int):String {
      if (_index_LanguageDisplayNames_ForCurrentNativeLanguage_by_LanguageId) {
         if (Utils_ArrayVectorEtc.doesDictionaryContainKey(_index_LanguageDisplayNames_ForCurrentNativeLanguage_by_LanguageId, languageId)) {
            return _index_LanguageDisplayNames_ForCurrentNativeLanguage_by_LanguageId[languageId];
         }
         else {
            Log.warn("MainModel.getLanguageDisplayName_InCurrentNativeLanguage - _index_LanguageDisplayNames_ForCurrentNativeLanguage_by_LanguageId has no property for languageId of: " + languageId);
            return null;
         }
      }
      else {
         Log.warn("MainModel.getLanguageDisplayName_InCurrentNativeLanguage - _index_LanguageDisplayNames_ForCurrentNativeLanguage_by_LanguageId is null");
         return null;
      }
   }

   public function getLanguageDisplayNameVOs():Array {
      var queryVO:LanguageDisplayNameVO = new LanguageDisplayNameVO();
      var report:MainModelDBOperationReport = selectData("getLanguageDisplayNameVOList", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLanguageDisplayNameVOList(): selectData() reports problem", report]);
      var result:Array = [];
      Utils_ArrayVectorEtc.copyArrayItemsToArray(report.resultData, result);
      report.dispose();
      return result;
   }

   public function getLanguageIdFromIso639_3Code(code:String):int {
      return _index_LanguageIDs_by_Iso639_3Code[code];
   }

   public function getLanguageIdList():Array {
      var queryVO:LanguageVO = new LanguageVO();
      var report:MainModelDBOperationReport = selectData("getLanguageIdList", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLanguageIdList(): selectData() reports problem", report]);
      var result:Array = Utils_ArrayVectorEtc.createArrayContainingValuesFromSpecifiedPropForPassedArrayItems(report.resultData, "id", true);
      report.dispose();
      return result;
   }

   public function getLanguageVOFromID(languageId:int):LanguageVO {
      if (_index_LanguageVOs_by_LanguageId) {
         if (Utils_ArrayVectorEtc.doesDictionaryContainKey(_index_LanguageVOs_by_LanguageId, languageId)) {
            return _index_LanguageVOs_by_LanguageId[languageId];
         }
         else {
            Log.warn("MainModel.getLanguageVOFromID - _index_LanguageVOs_by_LanguageId has no property for languageId of: " + languageId);
            return null;
         }
      }
      else {
         Log.warn("MainModel.getLanguageVOFromID - _index_LanguageVOs_by_LanguageId is null");
         return null;
      }
   }

   public function getLanguageVOFromIso639_3Code(code:String):LanguageVO {
      var queryVO:LanguageVO = new LanguageVO();
      queryVO.iso639_3Code = code;
      var report:MainModelDBOperationReport = selectData("getLanguageVOFromIso639_3Code", queryVO, null, 1, 1);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLanguageVOFromIso639_3Code(): selectData() reports problem", report]);
      var result:LanguageVO = LanguageVO(report.resultData[0]);
      report.dispose();
      return result;
   }

   public function getLanguageVOs():Array {
      var queryVO:LanguageVO = new LanguageVO();
      var report:MainModelDBOperationReport = selectData("getLanguageVOs", queryVO);
      if (report.isAnyProblems) {
         Log.fatal(["MainModel.getLanguageVOs(): selectData() reports problem", "MainModelDBOperationReport:", report]);
         return [];
      }
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getLearningModeCount():uint {
      var queryVO:LearningModeVO = new LearningModeVO();
      var report:MainModelDBOperationReport = selectData("getLearningModeCount", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLearningModeCount(): selectData() reports problem", report]);
      var result:uint = report.resultData.length;
      report.dispose();
      return result;
   }

   public function getLearningModeDisplayNameFromId(id:int):String {
      var token:String = getLearningModeTokenFromID(id);
      return getLearningModeDisplayNameFromLabelToken(token);
   }

   public function getLearningModeDisplayNameFromLabelToken(token:String):String {
      var result:String = getNativeLanguageResource("label_LearningMode_" + token);
      var nativeLangName:String = getCurrentNativeLanguageDisplayName_InCurrentNativeLanguage();
      var targetLangName:String = getCurrentTargetLanguageDisplayName_InCurrentNativeLanguage();
      // We shorten some language names ...
      // Kludge alert - perhaps these shorter names should be in the DB ... but they are needed for only a few languages ... so I'm cheating  :)
      switch (nativeLangName) {
         case "Mandarin Chinese":
            nativeLangName = "Chinese";
            break;
         case "Taiwanese Hokkien":
            nativeLangName = "Hokkien";
            break;
         case "Tagalog (Filipino)":
            nativeLangName = "Tagalog";
            break;
         case "Central Khmer":
            nativeLangName = "Khmer";
            break;
         case "Southern Sotho":
            nativeLangName = "Sotho";
            break;
         case "Indian Punjabi":
            nativeLangName = "Punjabi";
            break;
         case "Haitian Creole":
            nativeLangName = "Creole";
            break;
      }
      switch (targetLangName) {
         case "Mandarin Chinese":
            targetLangName = "Chinese";
            break;
         case "Taiwanese Hokkien":
            targetLangName = "Hokkien";
            break;
         case "Tagalog (Filipino)":
            targetLangName = "Tagalog";
            break;
         case "Central Khmer":
            targetLangName = "Khmer";
            break;
         case "Southern Sotho":
            targetLangName = "Sotho";
            break;
         case "Indian Punjabi":
            targetLangName = "Punjabi";
            break;
         case "Haitian Creole":
            targetLangName = "Creole";
            break;
      }
      result = Utils_String.replaceAll(result, Constant_LangMentor_Misc.TOKEN_NATIVE_LANGUAGE_NAME, nativeLangName);
      result = Utils_String.replaceAll(result, Constant_LangMentor_Misc.TOKEN_TARGET_LANGUAGE_NAME, targetLangName);
      return result;
   }

   public function getLearningModeIDFromLabelToken(token:String):int {
      var queryVO:LearningModeVO = new LearningModeVO();
      queryVO.labelToken = token;
      var report:MainModelDBOperationReport = selectData("getLearningModeIDFromLabelToken", queryVO, null, 1, 1);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLearningModeIDFromLabelToken(): selectData() reports problem", report]);
      var result:int = LearningModeVO(report.resultData[0]).id;
      report.dispose();
      return result;
   }

   public function getLearningModeIDListSortedByLocationInOrder():Array {
      var queryVO:LearningModeVO = new LearningModeVO();
      var orderByPropNames:Vector.<String> = new Vector.<String>();
      orderByPropNames.push("locationInOrder");
      var report:MainModelDBOperationReport = selectData("getLearningModeIDListSortedByLocationInOrder", queryVO, orderByPropNames);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLearningModeIDListSortedByLocationInOrder(): selectData() reports problem", report]);
      var result:Array = Utils_ArrayVectorEtc.createArrayContainingValuesFromSpecifiedPropForPassedArrayItems(report.resultData, "id", true);
      report.dispose();
      return result;
   }

   public function getLearningModeTokenFromID(id:int):String {
      return getLearningModeVOFromID(id).labelToken;
   }

   public function getLearningModeVOFromID(id:int):LearningModeVO {
      if (!_index_LearningModeVOs_by_ID) {
         return null;
      }
      return _index_LearningModeVOs_by_ID[id];
   }

   public function getLearningModeVOList():Array {
      var queryVO:LearningModeVO = new LearningModeVO();
      var report:MainModelDBOperationReport = selectData("getLearningModeVOList", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLearningModeVOList(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getLearningModeVOListSortedByLocationInOrder():Array {
      var queryVO:LearningModeVO = new LearningModeVO();
      var orderByPropNames:Vector.<String> = new Vector.<String>();
      orderByPropNames.push("locationInOrder");
      var report:MainModelDBOperationReport = selectData("getLearningModeVOListSortedByLocationInOrder", queryVO, orderByPropNames);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLearningModeVOListSortedByLocationInOrder(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getLessonContentLanguageDisplayName_Native():String {
      // This method is just a wrapper method for getCurrentNativeLanguageDisplayName_InCurrentNativeLanguage()
      // I'm including it here as "documentation", i.e. to make it clear that while the two other methods that start with "getLessonContentLanguageDisplayName_" actually
      // have to do some thinking, in this case we can simply use getCurrentNativeLanguageDisplayName_InCurrentNativeLanguage().
      if (!isAppDualLanguage()) {
         return null;
      }
      return getCurrentNativeLanguageDisplayName_InCurrentNativeLanguage();

   }

   public function getLessonContentLanguageDisplayName_Target():String {
      var result:String = getTargetLanguageResource(["languageSpecificDisplayStrings", getNativeLanguageIso639_3Code(), "displayModeName_targetLanguage"]);
      if (!result) {
         // If we haven't specified a display name in the language resource XML file for the target language, we simply use the target language's name.
         // When would want to specify a display name and not use the default? Well, for example, in Mandarin Chinese we call target language text "Hanzi".
         result = getCurrentTargetLanguageDisplayName_InCurrentNativeLanguage();
      }
      return result;
   }

   public function getLessonContentLanguageDisplayName_TargetPhonetic():String {
      if (!isTargetPhoneticTextAvailable()) {
         return null;
      }
      var result:String = getTargetLanguageResource(["languageSpecificDisplayStrings", getNativeLanguageIso639_3Code(), "displayModeName_targetLanguagePhonetic"]);
      if (!result) {
         // If we haven't specified a display name for phonetic text in the target language's language resource XML file, we simply use "Phonetic" plus the target language's name, e.g. "Phonetic Klingon"
         // When would we want to specify a display name and not use the default? Well, for example, in Mandarin Chinese we call phonetic target language text "Pinyin".
         result = "Phonetic " + getCurrentTargetLanguageDisplayName_InCurrentNativeLanguage();
      }
      return result;
   }

   public function getLessonContentTextDisplayModeCount():int {
      var availableTextModeCount:uint = 1; // We start with 1 because target language text is always available
      if (isAppDualLanguage()) {
         // Lesson includes native language text
         availableTextModeCount++;
      }
      if (isTargetPhoneticTextAvailable())
         availableTextModeCount++;
      return availableTextModeCount;
   }

   public function getLessonVersionCount():int {
      if (!_list_LessonVersionVOs) {
         return 0;
      }
      return _list_LessonVersionVOs.length;
   }

   public function getLessonVersionCount_DualLanguage():int {
      var result:int = 0;
      for each (var vo:LessonVersionVO in _list_LessonVersionVOs) {
         if (vo.isDualLanguage)
            result++;
      }
      return result;
   }

   public function getLessonVersionCount_SingleLanguage():int {
      var result:int = 0;
      for each (var vo:LessonVersionVO in _list_LessonVersionVOs) {
         if (!vo.isDualLanguage)
            result++;
      }
      return result;
   }

   public function getLessonVersionNativeLanguageCreditsXMLFromLessonVersionVO(vo:LessonVersionVO):String {
      var lvnlVO:LessonVersionNativeLanguageVO = getLessonVersionNativeLanguageVOFromLessonVersionVO(vo);
      var result:String = lvnlVO.creditsXML;
      if (result == null)
         result = "";
      return result;
   }

   public function getLessonVersionNativeLanguageDescriptionFromLessonVersionVO(vo:LessonVersionVO):String {
      var lvnlVO:LessonVersionNativeLanguageVO = getLessonVersionNativeLanguageVOFromLessonVersionVO(vo);
      var result:String = lvnlVO.description;
      if (result == null)
         result = "";
      return result;
   }

   public function getLessonVersionNativeLanguageNameFromLessonVersionVO(vo:LessonVersionVO):String {
      var lvnlVO:LessonVersionNativeLanguageVO = getLessonVersionNativeLanguageVOFromLessonVersionVO(vo);
      return lvnlVO.lessonName;
   }

   public function getLessonVersionNativeLanguageProviderNameFromLessonVersionVO(vo:LessonVersionVO):String {
      var lvnlVO:LessonVersionNativeLanguageVO = getLessonVersionNativeLanguageVOFromLessonVersionVO(vo);
      return lvnlVO.contentProviderName;
   }

   public function getLessonVersionNativeLanguageSortableNameFromLessonVersionVO(vo:LessonVersionVO):String {
      var lvnlVO:LessonVersionNativeLanguageVO = getLessonVersionNativeLanguageVOFromLessonVersionVO(vo);
      if ((lvnlVO.lessonSortName is String) && (lvnlVO.lessonSortName.length > 0)) {
         return lvnlVO.lessonSortName;
      } else {
         return lvnlVO.lessonName;
      }
   }

   public function getLessonVersionNativeLanguageVOFromLessonVersionVO(vo:LessonVersionVO):LessonVersionNativeLanguageVO {
      return LessonVersionNativeLanguageVO(Utils_ArrayVectorEtc.useVoEqualsFunctionToGetItemFromDictionary(vo, _index_LessonVersionNativeLanguageVOs_by_LessonVersionVO, true));
   }

   public function getLessonVersionNativeLanguageVOListFromLessonVersionVO(vo:LessonVersionVO):Array {
      var queryVO:LessonVersionNativeLanguageVO = new LessonVersionNativeLanguageVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      var report:MainModelDBOperationReport = selectData("getLessonVersionNativeLanguageVOListFromLessonVersionVO", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLessonVersionNativeLanguageVOListFromLessonVersionVO(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getLessonVersionNativeLanguageVOs():Array {
      var queryVO:LessonVersionNativeLanguageVO = new LessonVersionNativeLanguageVO();
      var report:MainModelDBOperationReport = selectData("getLessonVersionNativeLanguageVOs", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLessonVersionNativeLanguageVOs(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getLessonVersionTargetLanguageVOFromLessonVersionVOAndLanguageID(vo:LessonVersionVO, languageId:int):LessonVersionTargetLanguageVO {
      // dmccarroll 20130723
      // We include the language ID in this method's arguments because we may at some point implement lessons with multiple native languages. It's
      // not clear that we'll ever do this, but we'll keep this as-is for now.
      var queryVO:LessonVersionTargetLanguageVO = new LessonVersionTargetLanguageVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      queryVO.languageId = languageId;
      var report:MainModelDBOperationReport = selectData("getLessonVersionTargetLanguageVOFromLessonVersionVOAndLanguageID", queryVO, null, 1, 1);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLessonVersionTargetLanguageVOFromLessonVersionVOAndLanguageID(): selectData() reports problem", report]);
      var result:LessonVersionTargetLanguageVO = LessonVersionTargetLanguageVO(report.resultData[0]);
      report.dispose();
      return result;
   }

   public function getLessonVersionTargetLanguageVOListFromLessonVersionVO(vo:LessonVersionVO):Array {
      var queryVO:LessonVersionTargetLanguageVO = new LessonVersionTargetLanguageVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      var report:MainModelDBOperationReport = selectData("getLessonVersionTargetLanguageVOListFromLessonVersionVO", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLessonVersionTargetLanguageVOListFromLessonVersionVO(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getLessonVersionTargetLanguageVOs():Array {
      var queryVO:LessonVersionTargetLanguageVO = new LessonVersionTargetLanguageVO();
      var report:MainModelDBOperationReport = selectData("getLessonVersionTargetLanguageVOs", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLessonVersionTargetLanguageVOs(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getLessonVersionVOFromContentProviderIdAndLessonVersionSignature(cpid:String, lvSig:String):LessonVersionVO {
      var queryVO:LessonVersionVO = new LessonVersionVO();
      queryVO.contentProviderId = cpid;
      queryVO.lessonVersionSignature = lvSig;
      var report:MainModelDBOperationReport = selectData("getLessonVersionVOFromContentProviderIdAndLessonVersionSignature", queryVO, null, 1, 1);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLessonVersionVOFromContentProviderIdAndLessonVersionSignature(): selectData() reports problem", report]);
      var result:LessonVersionVO = LessonVersionVO(report.resultData[0]);
      report.dispose();
      return result;
   }

   public function getLessonVersionVOs():Array {
      return _list_LessonVersionVOs.slice();
   }

   public function getLessonVersionVOsFromContentProviderIdAndPublishedLessonVersionId(contentProviderId:String, lessonId:String):Array {
      var queryVO:LessonVersionVO = new LessonVersionVO();
      queryVO.contentProviderId = contentProviderId;
      queryVO.publishedLessonVersionId = lessonId;
      var report:MainModelDBOperationReport = selectData("getLessonVersionVOsFromContentProviderIdAndPublishedLessonVersionId", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLessonVersionVOsFromContentProviderIdAndPublishedLessonVersionId(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getLevelIdFromLevelLabelToken(token:String):int {
      return _index_LevelIDs_by_LabelToken[token];
   }

   public function getLevelIdFromNativeLanguageLevelLabel(label:String):int {
      var levelIdList:Array = getLevelIdList();
      for each (var levelId:int in levelIdList) {
         var candidateLabel:String = getNativeLanguageLevelLabelFromLevelId(levelId);
         if (candidateLabel == label)
            return levelId;
      }
      Log.fatal("MainModel.getNativeLanguageLevelIdFromLevelLabel(): Can't find match for label: + label");
      return 0;
   }

   public function getLevelIdList():Array {
      var queryVO:LevelVO = new LevelVO();
      var report:MainModelDBOperationReport = selectData("getLevelIdList", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLevelIdList(): selectData() reports problem", report]);
      var result:Array = Utils_ArrayVectorEtc.createArrayContainingValuesFromSpecifiedPropForPassedArrayItems(report.resultData, "id", true);
      report.dispose();
      return result;
   }

   public function getLevelLabelTokenFromId(id:int):String {
      return getLevelVOFromID(id)["labelToken"];
   }

   public function getLevelLabelTokenFromNativeLanguageLevelLabel(label:String):String {
      var levelId:int = getLevelIdFromNativeLanguageLevelLabel(label);
      var result:String = getLevelLabelTokenFromId(levelId);
      return result;
   }

   public function getLevelLocationInOrderFromLevelId(id:int):int {
      var levelVO:LevelVO = getLevelVOFromID(id);
      var locationInOrder:int = levelVO.locationInOrder;
      return locationInOrder;
   }

   public function getLevelOrderLevelFromId(id:int):String {
      return getLevelVOFromID(id)["locationInOrder"]
   }

   public function getLevelVOFromID(id:int):LevelVO {
      return _index_LevelVOs_by_ID[id];
   }

   public function getLevelVOs():Array {
      var queryVO:LevelVO = new LevelVO();
      var report:MainModelDBOperationReport = selectData("getLevelVOs", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLevelVOs(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getLibraryCount():uint {
      var queryVO:LibraryVO = new LibraryVO();
      var report:MainModelDBOperationReport = selectData("getLibraryCount", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLibraryCount(): selectData() reports problem", report]);
      var result:uint = report.resultData.length;
      report.dispose();
      return result;
   }

   public function getNativeChunkFileVOFromChunkVO(vo:ChunkVO):ChunkFileVO {
      var result:ChunkFileVO = getChunkFileVOFromChunkVOAndLanguageCode(vo, _currentNativeLanguageVO.iso639_3Code);
      return result;
   }

   public function getNativeLanguageIso639_3Code():String {
      return _currentNativeLanguageVO.iso639_3Code;
   }

   public function getNativeLanguageLevelLabelFromLevelId(id:int):String {
      var labelToken:String = getLevelLabelTokenFromId(id);
      var label:String = getNativeLanguageResource("label_Level_" + labelToken);
      return label;
   }

   public function getNativeLanguageResource(type:String):String {
      var result:String = _currentNativeLanguageResourceXML[type].toString();
      if (result == "")
         Log.fatal(["MainModel.getNativeLanguageResource(): 'type' arg is '" + type + "' - no resource by this name in native language resource XML (i.e. for '" + _currentNativeLanguageVO.iso639_3Code + "' language)", "_currentNativeLanguageResourceXML:", _currentNativeLanguageResourceXML]);
      return result;
   }

   public function getLibraryNativeLanguageNameFromLessonVersionVO(vo:LessonVersionVO):String {
      var lvnlVO:LessonVersionNativeLanguageVO = getLessonVersionNativeLanguageVOFromLessonVersionVO(vo);
      return lvnlVO.libraryName;
   }

   public function getReleaseTypeVOs():Array {
      var queryVO:ReleaseTypeVO = new ReleaseTypeVO();
      var report:MainModelDBOperationReport = selectData("getReleaseTypeVOs", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getReleaseTypeVOs(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getSingleOrNoLessonVersionVOFromContentProviderIdAndPublishedLessonVersionId(contentProviderId:String, lessonId:String):LessonVersionVO {
      var matchingVOs:Array = getLessonVersionVOsFromContentProviderIdAndPublishedLessonVersionId(contentProviderId, lessonId);
      if (matchingVOs.length == 0)
         return null;
      if (matchingVOs.length > 1) {
         // We have a problem. This should never happen. Command_DownloadLessons should be ensuring that previous versions are
         // completely deleted before saving new versions.
         Log.error("MainModel.getSingleOrNoLessonVersionVOFromContentProviderIdAndPublishedLessonVersionId(): Multiple lessons downloaded with matching contentProviderId (" + contentProviderId + ") and publishedLessonId (" + lessonId + ")");
      }
      return LessonVersionVO(matchingVOs[0]);
   }

   public function getTargetChunkFileVOFromChunkVO(vo:ChunkVO):ChunkFileVO {
      var result:ChunkFileVO = getChunkFileVOFromChunkVOAndLanguageCode(vo, _currentTargetLanguageVO.iso639_3Code);
      return result;
   }

   public function getTargetLanguageChunkFileDurationFromChunkVO(vo:ChunkVO):int {
      var cfVO:ChunkFileVO = getTargetChunkFileVOFromChunkVO(vo);
      var result:int = cfVO.duration;
      return result;
   }

   public function getTargetLanguageIso639_3Code():String {
      return _currentTargetLanguageVO.iso639_3Code;
   }

   public function getTargetLanguageResource(nodePathList:Array):String {
      var result:String;
      var nodeCount:uint = nodePathList.length;
      var currNode:XML = _currentTargetLanguageResourceXML;
      for (var i:int = 0; i < nodeCount; i++) {
         if (!currNode)
               return null;
         var nodeName:String = nodePathList[i];
         if (currNode[nodeName].length() == 1) {
            var isFinalNode:Boolean = (i == (nodeCount - 1));
            if (isFinalNode) {
               result = currNode[nodeName].toString();
            }
            else {
               currNode = currNode[nodeName][0];
            }
         }
      }
      if (result == "")
         return null;
      return result;
   }

   public function getTextDisplayTypeIdFromTypeName(typeName:String):int {
      return _index_TextDisplayTypeID_by_TextDisplayTypeName[typeName];
   }

   public function getTextDisplayTypeTypeNameFromId(id:uint):String {
      return _index_TextDisplayTypeName_by_TextDisplayTypeID[id];
   }

   public function getTextDisplayTypeVOs():Array {
      var queryVO:TextDisplayTypeVO = new TextDisplayTypeVO();
      var report:MainModelDBOperationReport = selectData("getTextDisplayTypeVOs", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getTextDisplayTypeVOs(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   public function getURL_MainConfigFolder():String {
      var result:String = configFileInfo.mainConfigFolderURL;
      if (Utils_System.isRunningOnDesktop())
         result = Utils_URL.convertUrlToDesktopServerUrl(result);
      return result;
   }

   public function getURL_RootInfoFolder():String {
      var result:String = Constant_MentorTypeSpecific.ROOT_INFO_FOLDER_URL;
      if (Utils_System.isRunningOnDesktop())
         result = Utils_URL.convertUrlToDesktopServerUrl(result);
      return result;
   }

   public function init():void {
      // Next line is for cases where we're init'ing after data wipe
      isDataWipeActivityBlockActive = false;
      configFileInfo = new ConfigFileInfo(this);
      _data = new Data(Utils_LangCollab.sqLiteDatabaseFileURL);
      //_data.dbAccessReportCallback = onDBAccessReport;
      var cb:Callbacks = new Callbacks(onLoadConfigDataComplete, onLoadConfigDataFailure);
      configFileInfo.loadData(cb);
   }

   public function initSingleton():void {
      _appStatePersistenceManager = AppStatePersistenceManager.getInstance();
      // If they're not already set, set defaults for autoDownloadLessons and useRecommendedLibraries
      if (!_appStatePersistenceManager.retrieveIsAutoDownloadLessonsSaved())
         _autoDownloadLessons = true;
      if (!_appStatePersistenceManager.retrieveIsUseRecommendedLibrariesSaved())
         _useRecommendedLibraries = true;
      _currentLessons = CurrentLessons.getInstance();
   }

   public function initTargetLanguage(languageId:int, newSelectionByUser:Boolean = false):void {
      _currentTargetLanguageId = languageId;
      if (newSelectionByUser)
         _appStatePersistenceManager.persistTargetLanguageId(languageId);
      initTargetLanguageBasedDataIfReady();
   }

   public function insertData(callingMethodName:String, queryDataList:Array, diagnosticInfoString:String = null):MainModelDBOperationReport {
      var startTime:Number = Utils_DateTime.getCurrentMS_BasedOnDate();
      var result:MainModelDBOperationReport = new MainModelDBOperationReport();
      result.diagnosticInfoString = diagnosticInfoString;
      result.sqliteTransactionReport = _data.insertData(queryDataList, diagnosticInfoString);
      if (!result.sqliteTransactionReport.isSuccessful)
         result.isAnyProblems = true;
      var index_dataProblemTypes_by_problematicQueryDataInstances:Dictionary = new Dictionary;
      for each (var queryData:SQLiteQueryData_Insert in queryDataList) {
         var o:Object = result.sqliteTransactionReport.index_rowsAffected_by_queryData[queryData];
         if (o is Number) {
            if (!queryData.isRowsAffectedCountValid(Number(o))) {
               index_dataProblemTypes_by_problematicQueryDataInstances[queryData] = SQLiteQueryData.PROBLEM_TYPE__ROWS_AFFECTED_COUNT_INVALID;
               result.isAnyProblems = true;
            }
         } else {
            index_dataProblemTypes_by_problematicQueryDataInstances[queryData] = SQLiteQueryData.PROBLEM_TYPE__NO_ROWS_AFFECTED_COUNT;
            result.isAnyProblems = true;
         }
      }
      if (Utils_ArrayVectorEtc.getDictionaryLength(index_dataProblemTypes_by_problematicQueryDataInstances) > 0)
         result.index_dataProblemTypes_by_problematicQueryDataInstances = index_dataProblemTypes_by_problematicQueryDataInstances;
      var duration:Number = Utils_DateTime.getCurrentMS_BasedOnDate() - startTime;
      Log.info("MainModel.insertData(): " + duration + "ms - " + callingMethodName + "()");
      return result;
   }

   public function insertVO(vo:IVO):MainModelDBOperationReport {
      var result:MainModelDBOperationReport = new MainModelDBOperationReport();
      var queryData:SQLiteQueryData_Insert = new SQLiteQueryData_Insert(vo, 1, 1);
      result.sqliteTransactionReport = _data.insertData([queryData]);
      if (!result.sqliteTransactionReport.isSuccessful)
         result.isAnyProblems = true;
      return result;
   }

   public function isAppDualLanguage():Boolean {
      if ((!_currentNativeLanguageVO) || (!_currentTargetLanguageVO))
         Log.fatal("MainModel.isAppDualLanguage(): current native and/or target languages aren't set yet");
      return !(_currentNativeLanguageVO.id == _currentTargetLanguageVO.id);
   }

   public function isCurrentLearningModeDualLanguage():Boolean {
      var vo:LearningModeVO = getCurrentLearningModeVO();
      if (!vo)
         return false;
      return vo.isDualLanguage;
   }

   public function isLessonLevelAStandardLevelLabelToken(level:String):Boolean {
      var vo:LevelVO = _index_LevelVOs_by_LabelToken[level];
      return (vo != null);
   }

   public function isLessonLevelSelectedForDownloading(level:uint):Boolean {
      for each (var vo:LevelVO in getSelectedLessonDownloadLevels_AllLevels()) {
         if (vo.id == level)
            return true;
      }
      return false;
   }

   public function isLibraryWithLibraryURLExists(libraryURL:String):Boolean {
      var queryVO:LibraryVO = new LibraryVO();
      queryVO.libraryFolderURL = libraryURL;
      var report:MainModelDBOperationReport = selectData("isLibraryWithLibraryURLExists", queryVO, null, 0, 1);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.isLibraryWithLibraryURLExists(): selectData() reports problem", report]);
      return (report.resultData.length == 1);
   }

   private function isRecommendedLibraryInfoFromRootConfigFileAvailable():Boolean {
      return (configFileInfo.targetLanguagesForWhichRecommendedLibrariesAreAvailable is XML);
   }

   public function isReleaseTypeAStandardReleaseTypeLabelToken(releaseType:String):Boolean {
      var vo:ReleaseTypeVO = _index_ReleaseTypeVOs_by_ReleaseTypeToken[releaseType];
      return (vo != null);
   }

   public function isSetupProcessComplete():Boolean {
      return ((_appStatePersistenceManager.retrieveAppInstallDate()) &&
            (_appStatePersistenceManager.retrieveIsTargetLanguageIdSaved()));
   }

   public function isTargetLanguageSelected():Boolean {
      return (_currentTargetLanguageVO != null);
   }

   public function isTargetPhoneticTextAvailable():Boolean {
      var result:Boolean = false;
      var hasPhoneticTextValueFromLanguageResourceFile_IfSpecified:String = getTargetLanguageResource(["hasPhoneticText"]);
      if (hasPhoneticTextValueFromLanguageResourceFile_IfSpecified) {
         result = (hasPhoneticTextValueFromLanguageResourceFile_IfSpecified == "true");
      }
      return result;
   }

   public function isTextDisplayTypeExists(typeName:String):Boolean {
      var vo:TextDisplayTypeVO = _index_TextDisplayTypeVOs_by_TypeName[typeName];
      return (vo != null);
   }

   public function retrievePersistedAppStateData():void {
      if (!_appStatePersistenceManager.isEnabled())
         return;
      if (_appStatePersistenceManager.retrieveIsHasUserSelectedDownloadBetaLessonsOptionSaved())
         _hasUserSelectedDownloadBetaLessonsOption = _appStatePersistenceManager.retrieveHasUserSelectedDownloadBetaLessonsOption();
      if (_appStatePersistenceManager.retrieveIsAutoDownloadLessonsSaved()) {
         // dmccarroll 20121129
         // We set autoDownloadLessons rather than _autoDownloadLessons because that triggers binding
         // events. This also has the effect of re-persisting the value we retrieve here, which is
         // a bit inefficient but does no great harm.
         autoDownloadLessons = _appStatePersistenceManager.retrieveAutoDownloadLessons();
      }
      if (_appStatePersistenceManager.retrieveIsSelectedLessonDownloadLevelsSaved()) {
         _selectedLessonDownloadLevels_PrimaryLevels = [];
         var savedLevels:Array = _appStatePersistenceManager.retrieveSelectedLessonDownloadLevels();
         for each (var level:uint in savedLevels) {
            _selectedLessonDownloadLevels_PrimaryLevels.push(getLevelVOFromID(level));
         }
      }
      if (_appStatePersistenceManager.retrieveIsUseRecommendedLibrariesSaved())
         _useRecommendedLibraries = _appStatePersistenceManager.retrieveUseRecommendedLibraries();
      var newCurrentLessons:ArrayCollection = new ArrayCollection();
      if (_appStatePersistenceManager.retrieveIsSelectedLessonVersionsSaved()) {
         var selectedLessonVersionInfos:Vector.<LessonVersionInfo> = _appStatePersistenceManager.retrieveSelectedLessonVersions();
         for each (var lvi:LessonVersionInfo in selectedLessonVersionInfos) {
            var lvvo:LessonVersionVO = getLessonVersionVOFromContentProviderIdAndLessonVersionSignature(lvi.contentProviderId, lvi.lessonVersionSignature);
            if (!lvvo) {
               Log.warn("MainModel.retrievePersistedAppStateData(): Retrieved 'Selected' LessonVersionInfo has no matching LessonVersionVO in DB - not unusual during development - " + lvvo.publishedLessonVersionId);
            } else {
               newCurrentLessons.addItem(lvvo);
            }
         }
      }
      if (newCurrentLessons.length == 0)
         return;
      _currentLessons.removeAll(true, true);
      _currentLessons.addAll(newCurrentLessons, false, true);
      // Now that we've added saved lesson versions (if any) to CurrentLessons, we can check for LVs with no unsuppressed chunks. We don't do this earlier because
      // we want to get this info from CurrentLessons, rather than accessing the DB.
      for each (lvvo in newCurrentLessons) {
         if (!_currentLessons.doesLessonVersionContainAnyUnsuppressedChunks(lvvo)) {
            Log.warn("MainModel.retrievePersistedAppStateData(): Retrieved 'Selected' LessonVersionInfo has no unsuppressed chunks - " + lvvo.publishedLessonVersionId);
         }
      }
      if (_currentLessons.isAnySelectedLessonVersionsHaveUnsuppressedChunks()) {
         var newCurrentLessonVersionVO:LessonVersionVO = null;
         var newCurrentLessonVersionIndex:int = -1;
         var bProblemWithLessonAndOrChunkIndexes:Boolean = false;
         if (_appStatePersistenceManager.retrieveIsCurrLessonVersionSaved()) {
            var info:LessonVersionInfo = _appStatePersistenceManager.retrieveCurrLessonVersion();
            if (info) {
               newCurrentLessonVersionVO = getLessonVersionVOFromContentProviderIdAndLessonVersionSignature(info.contentProviderId, info.lessonVersionSignature);
            }
         }
         if (!newCurrentLessonVersionVO) {
            bProblemWithLessonAndOrChunkIndexes = true;
         } else if (Utils_ArrayVectorEtc.useVoEqualsFunctionToGetIndexOfVoInArrayCollection(newCurrentLessonVersionVO, newCurrentLessons) == -1) {
            bProblemWithLessonAndOrChunkIndexes = true;
         } else if (!_currentLessons.doesLessonVersionContainAnyUnsuppressedChunks(newCurrentLessonVersionVO)) {
            bProblemWithLessonAndOrChunkIndexes = true;
         } else {
            newCurrentLessonVersionIndex = Utils_ArrayVectorEtc.useVoEqualsFunctionToGetIndexOfVoInArrayCollection(newCurrentLessonVersionVO, newCurrentLessons);
         }
         if (!bProblemWithLessonAndOrChunkIndexes) {
            var newCurrentChunkIndex:int = -1;
            if (_appStatePersistenceManager.retrieveIsCurrChunkIndexSaved()) {
               newCurrentChunkIndex = _appStatePersistenceManager.retrieveCurrChunkIndex();
            } else {
               bProblemWithLessonAndOrChunkIndexes = true;
            }
         }
         if (bProblemWithLessonAndOrChunkIndexes) {
            // There's a problem with the retrieved data, but we know that we have at least one playable lesson
            _currentLessons.setCurrentLessonAndChunkIndexesToFirstPlayableLessonAndChunk();
         } else {
            if (_currentLessons.areNewCurrentLessonAndChunkIndexesAllowed(newCurrentLessonVersionIndex, newCurrentChunkIndex)) {
               _currentLessons.setCurrentLessonAndChunkIndexes(newCurrentLessonVersionIndex, newCurrentChunkIndex, true);
            } else {
               _currentLessons.setCurrentLessonAndChunkIndexesToFirstPlayableLessonAndChunk();
            }
         }
      } else {
         // No selected lesson versions are playable - app will display explanatory message when user clicks Play Lessons
         _currentLessons.setCurrentLessonAndChunkIndexes(-1, -1);
      }
   }

   public function selectData(
         callingMethodName:String,
         selectionCriteriaVO:IVO,
         orderByPropNames:Vector.<String> = null,
         minAllowedResultCount:Number = 0,
         maxAllowedResultCount:Number = Number.MAX_VALUE):MainModelDBOperationReport {
      var startTime:Number = Utils_DateTime.getCurrentMS_BasedOnDate();
      var queryData:SQLiteQueryData_Select =
            new SQLiteQueryData_Select(selectionCriteriaVO, orderByPropNames, minAllowedResultCount, maxAllowedResultCount);
      var result:MainModelDBOperationReport = new MainModelDBOperationReport();
      result.sqliteTransactionReport = _data.selectData(queryData);
      if (!result.sqliteTransactionReport.isSuccessful) {
         result.isAnyProblems = true;
         // For debugging...
         result.sqliteTransactionReport = _data.selectData(queryData);
      }
      if ((result.sqliteTransactionReport.index_resultData_by_queryData) &&
            (result.sqliteTransactionReport.index_resultData_by_queryData[queryData] is Array)) {
         result.resultData = result.sqliteTransactionReport.index_resultData_by_queryData[queryData];
         if (!queryData.isResultCountValid(result.resultData.length))
            result.isAnyProblems = true;
      } else {
         result.isAnyProblems = true;
      }
      var duration:Number = Utils_DateTime.getCurrentMS_BasedOnDate() - startTime;
      Log.info("MainModel.selectData(): " + duration + "ms - " + callingMethodName + "()");
      return result;
   }

   public function setAutoDownloadLessonsWithoutPersistingSetting(value:Boolean):void {
      _autoDownloadLessons = value;
   }

   public function updateCurrentTargetLanguageVO_hasRecommendedLibraries(b:Boolean):void {
      if (!_currentTargetLanguageVO) {
         Log.error("MainModel.updateCurrentTargetLanguageVO_hasRecommendedLibraries() - _currentTargetLanguageVO is null - calling code should check for this condition")
         return;
      }
      _currentTargetLanguageVO.hasRecommendedLibraries = b;
   }

   public function updateVO_NoKeyPropChangesAllowed(callingMethodName:String, vo:IVO, updatedPropNames:Array):MainModelDBOperationReport {
      // dmccarroll 20130723 - Constraint: We should never be changing 'key properties' in a VO, i.e. the properties that are used to specify its unique identity
      var startTime:Number = Utils_DateTime.getCurrentMS_BasedOnDate();
      var result:MainModelDBOperationReport = new MainModelDBOperationReport();
      var queryData:SQLiteQueryData_Update = new SQLiteQueryData_Update(vo, updatedPropNames, true);
      if (queryData.doesUpdateKeyProps()) {
         result.isAnyProblems = true;
         result.errorType = Constant_MainModelErrorTypes.UPDATE__UNALLOWED_FIELDS;
         result.unallowedFieldNameList = queryData.getListOfKeyPropsBeingUpdated();
         return result;
      }
      result.sqliteTransactionReport = _data.updateData([queryData]);
      if (!result.sqliteTransactionReport.isSuccessful)
         result.isAnyProblems = true;
      var index_dataProblemTypes_by_problematicQueryDataInstances:Dictionary = new Dictionary;
      var o:Object = result.sqliteTransactionReport.index_rowsAffected_by_queryData[queryData];
      if (o is Number) {
         if (!queryData.isRowsAffectedCountValid(Number(o))) {
            index_dataProblemTypes_by_problematicQueryDataInstances[queryData] = SQLiteQueryData.PROBLEM_TYPE__ROWS_AFFECTED_COUNT_INVALID;
            result.isAnyProblems = true;
         }
      } else {
         index_dataProblemTypes_by_problematicQueryDataInstances[queryData] = SQLiteQueryData.PROBLEM_TYPE__NO_ROWS_AFFECTED_COUNT;
         result.isAnyProblems = true;
      }
      if (Utils_ArrayVectorEtc.getDictionaryLength(index_dataProblemTypes_by_problematicQueryDataInstances) > 0)
         result.index_dataProblemTypes_by_problematicQueryDataInstances = index_dataProblemTypes_by_problematicQueryDataInstances;
      var duration:Number = Utils_DateTime.getCurrentMS_BasedOnDate() - startTime;
      Log.info("MainModel.updateVO_NoKeyPropChangesAllowed(): " + duration + "ms - " + callingMethodName + "()");
      return result;
   }

   public function updateVOsOfType_NoKeyPropChangesAllowed(callingMethodName:String, vo:IVO, updatedPropNames:Array, index_propNames_to_selectValues:Dictionary = null):MainModelDBOperationReport {
      // dmccarroll 20130723 - Constraint: We should never be changing 'key properties' in a VO, i.e. the properties that are used to specify its unique identity
      var startTime:Number = Utils_DateTime.getCurrentMS_BasedOnDate();
      var result:MainModelDBOperationReport = new MainModelDBOperationReport();
      var queryData:SQLiteQueryData_Update = new SQLiteQueryData_Update(vo, updatedPropNames, false, index_propNames_to_selectValues);
      if (queryData.doesUpdateKeyProps()) {
         result.isAnyProblems = true;
         result.errorType = Constant_MainModelErrorTypes.UPDATE__UNALLOWED_FIELDS;
         result.unallowedFieldNameList = queryData.getListOfKeyPropsBeingUpdated();
         return result;
      }
      result.sqliteTransactionReport = _data.updateData([queryData]);
      var duration:Number = Utils_DateTime.getCurrentMS_BasedOnDate() - startTime;
      Log.info("MainModel.updateVOsOfType_NoKeyPropChangesAllowed(): " + duration + "ms - " + callingMethodName + "()");
      return result;
   }

   public function uploadableDataExists():Boolean {
      // This would look through the data for data types that have an
      // 'uploaded' field - if any are true, then return true
      return false;
   }

   public function wipeData():void {
      _currentNativeLanguageVO = null;
      _currentTargetLanguageVO = null;
      useRecommendedLibraries = true;
      currentApplicationState = 0;
      currentLearningModeId = 0;
      _isDBDataInitialized = false;
      hasUserSelectedDownloadBetaLessonsOption = false;
      lessonsSelectionTreeSortOptions = null;
      // Dispose Cache
      Utils_Dispose.disposeDictionary(_index_LanguageIDs_by_Iso639_3Code, true);
      Utils_Dispose.disposeDictionary(_index_LearningModeVOs_by_ID, true);
      Utils_Dispose.disposeDictionary(_index_LessonVersionNativeLanguageVOs_by_LessonVersionVO, true);
      Utils_Dispose.disposeDictionary(_index_LessonVersionTargetLanguageVOs_by_LessonVersionVO, true);
      Utils_Dispose.disposeDictionary(_index_LevelIDs_by_LabelToken, true);
      Utils_Dispose.disposeDictionary(_index_LevelVOs_by_ID, true);
      Utils_Dispose.disposeDictionary(_index_LevelVOs_by_LabelToken, true);
      Utils_Dispose.disposeDictionary(_index_ReleaseTypeVOs_by_ReleaseTypeToken, true);
      Utils_Dispose.disposeDictionary(_index_TextDisplayTypeID_by_TextDisplayTypeName, true);
      Utils_Dispose.disposeDictionary(_index_TextDisplayTypeName_by_TextDisplayTypeID, true);
      Utils_Dispose.disposeDictionary(_index_TextDisplayTypeVOs_by_TypeName, true);
      Utils_Dispose.disposeArray(_list_LessonVersionVOs, true);
      Utils_Dispose.disposeArray(_selectedLessonDownloadLevels_PrimaryLevels, true);
      _currentLessons.removeAll();
      if (_data) {
         _data.dispose();
         _data = null;
      }
      isDataWipeActivityBlockActive = true;
      _appStatePersistenceManager.wipeData();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function doPostLoadConfigDataAppInit():void {
      initCache();
      retrievePersistedAppStateData();
      _currentNativeLanguageVO = getLanguageVOFromIso639_3Code(Constant_MentorTypeSpecific.LANGUAGE__DEFAULT__NATIVE__ISO639_3_CODE);
      _currentNativeLanguageId = _currentNativeLanguageVO.id;
      initLessonsSelectionTreeSortOptions();
      _isDBDataInitialized = true;
      dispatchEvent(new Event("isDBDataInitializedChange"));
      initTargetLanguageBasedDataIfReady();
   }

   private function getLessonVersionNativeLanguageVOFromLessonVersionVOFromDB(vo:LessonVersionVO):LessonVersionNativeLanguageVO {
      var queryVO:LessonVersionNativeLanguageVO = new LessonVersionNativeLanguageVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      queryVO.languageId = _currentNativeLanguageVO.id;
      var report:MainModelDBOperationReport = selectData("getLessonVersionNativeLanguageVOFromLessonVersionVOFromDB", queryVO, null, 1, 1);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLessonVersionNativeLanguageVOFromLessonVersionVOFromDB(): selectData() reports problem", report]);
      var result:LessonVersionNativeLanguageVO = LessonVersionNativeLanguageVO(report.resultData[0]);
      report.dispose();
      return result;
   }

   private function getLessonVersionTargetLanguageVOFromLessonVersionVOFromDB(vo:LessonVersionVO):LessonVersionTargetLanguageVO {
      var queryVO:LessonVersionTargetLanguageVO = new LessonVersionTargetLanguageVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      queryVO.languageId = _currentTargetLanguageVO.id;
      var report:MainModelDBOperationReport = selectData("getLessonVersionTargetLanguageVOFromLessonVersionVOFromDB", queryVO, null, 1, 1);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLessonVersionTargetLanguageVOFromLessonVersionVOFromDB(): selectData() reports problem", report]);
      var result:LessonVersionTargetLanguageVO = LessonVersionTargetLanguageVO(report.resultData[0]);
      report.dispose();
      return result;
   }

   private function getLessonVersionVOsFromDB():Array {
      var queryVO:LessonVersionVO = new LessonVersionVO();
      var report:MainModelDBOperationReport = selectData("getLessonVersionVOsFromDB", queryVO);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLessonVersionVOsFromDB(): selectData() reports problem", report]);
      var result:Array = report.resultData.slice();
      report.dispose();
      return result;
   }

   private function getSelectedLessonDownloadLevels_AllLevels():Vector.<LevelVO> {
      /// kludge! and also untested, as we're not using sublevels yet
      var result:Vector.<LevelVO> = new Vector.<LevelVO>();
      var selectedLevelIds:Array = [];
      for each (var vo:LevelVO in _selectedLessonDownloadLevels_PrimaryLevels) {
         var newValues:Array;
         switch (vo.id) {
            case 1:
               newValues = [1];
               break;
            case 2:
               newValues = [2, 3, 4, 5];
               break;
            case 6:
               newValues = [6, 7, 8, 9];
               break;
            case 10:
               newValues = [10, 11, 12, 13];
               break;
            default:
               Log.error("MainModel.getSelectedLessonDownloadLevels_AllLevels(): No case for LevelVO.id of: " + vo.id);
         }
         for each (var id:uint in newValues) {
            selectedLevelIds.push(id);
         }
      }
      for each (id in selectedLevelIds) {
         result.push(getLevelVOFromID(id));
      }
      return result;
   }

   private function initCache():void {
      var voList:Array;
      // Language
      voList = getLanguageVOs();
      for each (var languageVO:LanguageVO in voList) {
         _index_LanguageVOs_by_LanguageId[languageVO.id] = languageVO;
         _index_LanguageIDs_by_Iso639_3Code[languageVO.iso639_3Code] = languageVO.id;
      }
      var currentNativeLanguageId:int = _index_LanguageIDs_by_Iso639_3Code[Constant_MentorTypeSpecific.LANGUAGE__DEFAULT__NATIVE__ISO639_3_CODE];
      voList = getLanguageDisplayNameVOs();
      for each (var languageDisplayNameVO:LanguageDisplayNameVO in voList) {
         if (languageDisplayNameVO.displayLanguageId == currentNativeLanguageId) {
            _index_LanguageDisplayNames_ForCurrentNativeLanguage_by_LanguageId[languageDisplayNameVO.languageId] = languageDisplayNameVO.displayName;
            _index_LanguageDisplayNames_Alphabetizable_ForCurrentNativeLanguage_by_LanguageId[languageDisplayNameVO.languageId] = languageDisplayNameVO.displayNameAlphabetizable;
         }
      }
      // LearningMode
      voList = getLearningModeVOList();
      for each (var learningModeVO:LearningModeVO in voList) {
         _index_LearningModeVOs_by_ID[learningModeVO.id] = learningModeVO;
      }
      // LessonVersion
      _list_LessonVersionVOs = getLessonVersionVOsFromDB();
      voList = getLessonVersionNativeLanguageVOs();
      for each (var lvvo:LessonVersionVO in _list_LessonVersionVOs) {
         for each (var lvnlvo:LessonVersionNativeLanguageVO in voList) {
            if (lvvo.isReferencingInstance(lvnlvo)) {
               _index_LessonVersionNativeLanguageVOs_by_LessonVersionVO[lvvo] = lvnlvo;
               break;
            }
         }
         // Confirm that a match was found and added to index
         lvnlvo = _index_LessonVersionNativeLanguageVOs_by_LessonVersionVO[lvvo];
         if (!lvnlvo)
            Log.fatal(["MainModel.initCache(): No LessonVersionNativeLanguageVO found that matches LessonVersionVO", lvvo, voList]);
      }
      voList = getLessonVersionTargetLanguageVOs();
      for each (lvvo in _list_LessonVersionVOs) {
         for each (var lvtlvo:LessonVersionTargetLanguageVO in voList) {
            if (lvvo.isReferencingInstance(lvtlvo)) {
               _index_LessonVersionTargetLanguageVOs_by_LessonVersionVO[lvvo] = lvtlvo;
               break;
            }
         }
         // Confirm that a match was found and added to index
         lvtlvo = _index_LessonVersionTargetLanguageVOs_by_LessonVersionVO[lvvo];
         if (!lvtlvo)
            Log.fatal(["MainModel.initCache(): No LessonVersionTargetLanguageVO found that matches LessonVersionVO", lvvo, voList]);
      }
      // Level
      voList = getLevelVOs();
      for each (var levelVO:LevelVO in voList) {
         _index_LevelIDs_by_LabelToken[levelVO.labelToken] = levelVO.id;
         _index_LevelVOs_by_ID[levelVO.id] = levelVO;
         _index_LevelVOs_by_LabelToken[levelVO.labelToken] = levelVO;
      }
      // ReleaseType
      voList = getReleaseTypeVOs();
      for each (var releaseTypeVO:ReleaseTypeVO in voList) {
         _index_ReleaseTypeVOs_by_ReleaseTypeToken[releaseTypeVO.labelToken] = releaseTypeVO;
         _index_ReleaseTypeVOs_by_ID[releaseTypeVO.id] = releaseTypeVO;
         _index_ReleaseTypeVOs_by_LabelToken[releaseTypeVO.labelToken] = releaseTypeVO;
      }
      // TextDisplayType
      voList = getTextDisplayTypeVOs();
      for each (var textDisplayTypeVO:TextDisplayTypeVO in voList) {
         _index_TextDisplayTypeID_by_TextDisplayTypeName[textDisplayTypeVO.typeName] = textDisplayTypeVO.id;
         _index_TextDisplayTypeName_by_TextDisplayTypeID[textDisplayTypeVO.id] = textDisplayTypeVO.typeName;
         _index_TextDisplayTypeVOs_by_TypeName[textDisplayTypeVO.typeName] = textDisplayTypeVO;
      }
   }

   private function initLessonsSelectionTreeSortOptions():void {
      if (lessonsSelectionTreeSortOptions)
         Utils_Dispose.disposeArray(lessonsSelectionTreeSortOptions, true);
      lessonsSelectionTreeSortOptions = [];
      var levelInfo:TreeListLevelInfo;
      levelInfo = new TreeListLevelInfo();
      levelInfo.levelDisplayName = LessonVersionList.LEVEL_DISPLAY_NAME__LEVEL;
      levelInfo.displayAndGroupingProp = "levelDisplayString";
      levelInfo.customSort = true;
      levelInfo.customSortDataIsNumeric = true;
      levelInfo.sortInfoProp = "levelSortInfo";
      lessonsSelectionTreeSortOptions.push(levelInfo);
      levelInfo = new TreeListLevelInfo();
      levelInfo.levelDisplayName = LessonVersionList.LEVEL_DISPLAY_NAME__LIBRARY;
      levelInfo.displayAndGroupingProp = "libraryDisplayString";
      lessonsSelectionTreeSortOptions.push(levelInfo);
      levelInfo = new TreeListLevelInfo();
      levelInfo.levelDisplayName = LessonVersionList.LEVEL_DISPLAY_NAME__LESSONS;
      levelInfo.displayAndGroupingProp = "nameDisplayString";
      levelInfo.customSort = true;
      levelInfo.sortInfoProp = "sortableNameString";
      lessonsSelectionTreeSortOptions.push(levelInfo);
   }

   /// eliminate _isDBDataInitialized check - this is used in two different ways - as checked here, probably no longer needed
   // - is set in init() - as announced via change event here - notifies View_Home - via binding - model is ready
   // - also various other classes check this prop - should probably be renamed isModelInitialized
   private function initTargetLanguageBasedDataIfReady():void {
      if (Constant_MentorTypeSpecific.MENTOR_TYPE__CODE != Constant_MentorTypes.MENTOR_TYPE_CODE__UNIVERSAL) {
         // This isn't "standard" mentor type, which means that the target language is specified in this constant...
         _currentTargetLanguageId = getLanguageIdFromIso639_3Code(Constant_MentorTypeSpecific.LANGUAGE__DEFAULT__TARGET__ISO639_3_CODE);
         _appStatePersistenceManager.persistTargetLanguageId(_currentTargetLanguageId);
      }
      if (_currentTargetLanguageId == -1)
         return;
      if (!_isDBDataInitialized)
         return;
      _currentTargetLanguageVO = getLanguageVOFromID(_currentTargetLanguageId);
      if (isRecommendedLibraryInfoFromRootConfigFileAvailable()) {
         _currentTargetLanguageVO.hasRecommendedLibraries = doesLanguageHaveRecommendedLibrariesBasedOnRootConfigFile(_currentTargetLanguageVO.iso639_3Code);
         isRecommendedLibraryInfoUpdatedForCurrentTargetLanguage = true;
      }
      loadLanguageResourceXML();
      _isTargetLanguageInitialized = true;
      setInitialLearningMode(); // We do this here, rather than in retrievePersistedAppStateData(), because the user may have chosen a target language that is the same as the native language, thus the app is in "single-language mode", which affects which default mode we use
      var cb:Callbacks = new Callbacks(onLoadLearningModeDescriptionsComplete, onLoadLearningModeDescriptionsFailure);
      var c:Command_LoadLearningModeDescriptions = new Command_LoadLearningModeDescriptions(cb);
      c.execute();
      dispatchEvent(new Event("isDBDataAndTargetLanguageInitializedChange"));
      reportAppStartupToAnalytics();
   }

   private function loadLanguageResourceXML():void {
      var appDir:File = File.applicationDirectory;
      var f:File;
      var s:String = Constant_LangMentor_Misc.FILEPATHINFO__LANGUAGE_RESOURCE_FOLDER_NAME + File.separator + _currentNativeLanguageVO.iso639_3Code + ".xml";
      f = appDir.resolvePath(Constant_LangMentor_Misc.FILEPATHINFO__LANGUAGE_RESOURCE_FOLDER_NAME + File.separator + _currentNativeLanguageVO.iso639_3Code + ".xml");
      if (f.exists) {
         _currentNativeLanguageResourceXML = Utils_XML.synchronousLoadXML(f, true);
      } else {
         // This occurs sometimes when running desktop emulator, and resource files haven't gotten copied to the output folder
         Log.error("MainModel.loadLanguageResourceXML(): language resource file for native language (" + _currentNativeLanguageVO.iso639_3Code + ") is missing");
      }
      f = appDir.resolvePath(Constant_LangMentor_Misc.FILEPATHINFO__LANGUAGE_RESOURCE_FOLDER_NAME + File.separator + _currentTargetLanguageVO.iso639_3Code + ".xml");
      if (f.exists)
         _currentTargetLanguageResourceXML = Utils_XML.synchronousLoadXML(f, true);
      else
         Log.error("MainModel.loadLanguageResourceXML(): language resource file for target language (" + _currentTargetLanguageVO.iso639_3Code + ") is missing");
   }

   private function onDBAccessReport():void {
      if (!(_dbAccessTimes is Array))
         _dbAccessTimes = [];
      var currTime:Number = Utils_DateTime.getCurrentMS_BasedOnDate();
      var lookbackPeriod:Number = 10000;
      _dbAccessTimes.unshift(currTime);
      var count:Number = 0;
      for each (var n:Number in _dbAccessTimes) {
         var duration:Number = currTime - n;
         if (duration > lookbackPeriod)
            break;
         count++;
      }
      recentDBAccessCount = count;
   }

   private function onLoadConfigDataComplete(techReport:ConfigFileInfoTechReport):void {
      Log.debug("MainModel.onLoadConfigDataComplete()");
      if (Utils_AIR.appVersionNumber < configFileInfo.requiredMinimumVersion) {
         // We wipe data to ensure that when the new version is installed a new DB file is created, and the user starts from a clean slate.
         _appStatePersistenceManager.wipeData();
         Utils_File.deleteDirectory(Utils_AIR.applicationStorageDirectory);
         Utils_File.deleteDirectory(Utils_LangCollab.sqLiteDatabaseFileDirectoryURL);
         NativeApplication.nativeApplication.dispatchEvent(new BwEvent(BwEvent.UPDATE_REQUIRED));
      }
      else {
         // We now have our config data, and the DB version is okay, so we can continue on with stuff that would be in the init() method if we didn't need to confirm these details first...
         internetConnectionActive = true;
         doPostLoadConfigDataAppInit();
         updateLanguageVOsWithHasRecommendedLibrariesInfoFromRootConfigFile();
         configFileInfo.doLowPriorityDataFetching();
      }
   }

   private function onLoadConfigDataFailure(techReport:ConfigFileInfoTechReport):void {
      //
      //    We are probably either running on the desktop, without Tomcat running, or are running on a wifi-only device
      //    with no wifi connection.
      //
      if (_appStatePersistenceManager.retrieveIsAppInstallDateSaved()) {
         // We have no internet connection, but the app has been initialized so there are probably lessons downloaded, and the user can use the app
         // App_LanguageMentor_Base.onNoInternetConnection() will check to see if there are lessons, so we don't do that here.
         doPostLoadConfigDataAppInit();
      }
      NativeApplication.nativeApplication.dispatchEvent(new BwEvent(BwEvent.NO_INTERNET_CONNECTION));
      Log.info(["MainModel.onLoadConfigDataFailure()", techReport]);
   }

   private function onLoadLearningModeDescriptionsComplete(info:Object):void {
      Log.debug("MainModel.onLoadLearningModeDescriptionsComplete()");
   }

   private function onLoadLearningModeDescriptionsFailure(info:Object = null):void {
      if ((info is FaultEvent) || (info is String)) {
         Log.fatal(["MainModel.onLoadLearningModeDescriptionsFailure():", info]);
      } else {
         Log.fatal(["MainModel.onLoadLearningModeDescriptionsFailure(): Error info type not handled", info]);
      }
   }

   private function reportAppStartupToAnalytics():void {
      var data:String = "";
      data += "appName=" + Constant_MentorTypeSpecific.APP_NAME__FULL + ":";
      data += "appVersion=" + String(Utils_AIR.appVersionNumber) + ":";
      data += "mentorType=" + Constant_MentorTypeSpecific.MENTOR_TYPE__CODE + ":";
      data += "languages=" + getNativeLanguageIso639_3Code() + ">" + getTargetLanguageIso639_3Code();
      Utils_GoogleAnalytics.trackAppStartup(data);
   }

   private function setInitialLearningMode():void {
      if (_appStatePersistenceManager.retrieveIsSelectedLearningModeIdSaved())
         currentLearningModeId = _appStatePersistenceManager.retrieveSelectedLearningModeId();
      else
         currentLearningModeId = 0;
   }

   private function updateLanguageVOsWithHasRecommendedLibrariesInfoFromRootConfigFile():void {
      /// Language VOs start with their hasRecommendedLibraries props set to false, so, for now we'll only update those where this prop should be true
      /// Eventually, we should update all VOs, as we'll have situations like a) a library has become non-recommended, b) a user switches native language (?)
      var matchFoundBetweenRecommendedLibrariesInfoAndCurrentTargetLanguage:Boolean = false;
      for (var i:int = 0; i < configFileInfo.targetLanguagesForWhichRecommendedLibrariesAreAvailable.children().length(); i++) {
         var targetLanguageNode:XML = configFileInfo.targetLanguagesForWhichRecommendedLibrariesAreAvailable.children()[i];
         var iso639_3Code:String = targetLanguageNode.name();
         var vo:LanguageVO = getLanguageVOFromIso639_3Code(iso639_3Code);
         vo.hasRecommendedLibraries = true;
         updateVO_NoKeyPropChangesAllowed("ConfigFileInfo.updateLanguageVOsWithHasRecommendedLibrariesInfoFromRootConfigFile", vo, ["hasRecommendedLibraries"]);
         if (getCurrentTargetLanguageISO639_3Code() == iso639_3Code) {   // This also evaluates to false if the currentTargetLanguage hasn't been set yet - which occurs in some scenarios - but this isn't a problem because the value has also been set in the DB (above)
            matchFoundBetweenRecommendedLibrariesInfoAndCurrentTargetLanguage = true;
         }
      }
      if (matchFoundBetweenRecommendedLibrariesInfoAndCurrentTargetLanguage) {
         updateCurrentTargetLanguageVO_hasRecommendedLibraries(true);
         isRecommendedLibraryInfoUpdatedForCurrentTargetLanguage = true;
      }
      else {
         if (_currentTargetLanguageVO) {
            updateCurrentTargetLanguageVO_hasRecommendedLibraries(false);    // This was almost surely already false - this code is here more to communicate intent to humans (that's you :) than to actually do anything
            isRecommendedLibraryInfoUpdatedForCurrentTargetLanguage = true;
         }
         else {
            // We haven't really determined anything at this point
         }
      }
   }



}
}

