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
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_AIR;
import com.brightworks.util.Utils_ArrayVectorEtc;
import com.brightworks.util.Utils_DateTime;
import com.brightworks.util.Utils_Dispose;
import com.brightworks.util.Utils_GoogleAnalytics;
import com.brightworks.util.Utils_ANEs;
import com.brightworks.util.Utils_String;
import com.brightworks.util.Utils_System;
import com.brightworks.util.Utils_URL;
import com.brightworks.util.Utils_XML;
import com.brightworks.util.download.DownloadBandwidthRecorder;
import com.brightworks.util.singleton.SingletonManager;
import com.brightworks.util.tree.Utils_Tree;
import com.brightworks.vo.IVO;
import com.langcollab.languagementor.component.lessonversionlist.LessonVersionList;
import com.langcollab.languagementor.constant.Constant_AppConfiguration;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.constant.Constant_MentorTypes;
import com.langcollab.languagementor.controller.Command_LoadLearningModeDescriptions;
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
import com.langcollab.languagementor.vo.TextDisplayTypeVO;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.rpc.events.FaultEvent;

public class MainModel extends EventDispatcher implements IManagedSingleton {
   private static const DEFAULT_LEARNING_MODE_ID__DUAL_LANGUAGE:int = 1;
   private static const DEFAULT_LEARNING_MODE_ID__SINGLE_LANGUAGE:int = 2;

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
   public var isDataWipeActivityBlockActive:Boolean;
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
   private var _index_LanguageIDs_by_Iso639_3Code:Dictionary = new Dictionary();
   private var _index_LearningModeVOs_by_ID:Dictionary = new Dictionary();
   private var _index_LessonVersionNativeLanguageVOs_by_LessonVersionVO:Dictionary = new Dictionary();
   private var _index_LessonVersionTargetLanguageVOs_by_LessonVersionVO:Dictionary = new Dictionary();
   private var _index_LevelIDs_by_LabelToken:Dictionary = new Dictionary();
   private var _index_LevelVOs_by_ID:Dictionary = new Dictionary();
   private var _index_LevelVOs_by_LabelToken:Dictionary = new Dictionary();
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

   [Bindable(event="isDataInitializedChange")]
   public function get isDataInitialized():Boolean {
      return (_isDBDataInitialized && _isTargetLanguageInitialized);
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

   private var _useRecommendedLibraries:Boolean = false;

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
         Log.fatal(["MainModel.addLessonVersionVOToCache(): Cannot retreive LessonVersionTargetLanguageVO for LessonVersionVO from DB", vo]);
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

   public function getChunkFileVOFromChunkVOAndLanguageId(vo:ChunkVO, languageId:int):ChunkFileVO {
      var queryVO:ChunkFileVO = new ChunkFileVO();
      queryVO.contentProviderId = vo.contentProviderId;
      queryVO.lessonVersionSignature = vo.lessonVersionSignature;
      queryVO.chunkLocationInOrder = vo.locationInOrder;
      queryVO.languageId = languageId;
      var report:MainModelDBOperationReport = selectData("getChunkFileVOFromChunkVOAndLanguageId", queryVO, null, 1, 1);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getChunkFileVOFromChunkVOAndLanguageId(): selectData() reports problem", report]);
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

   public function getCurrentLearningModeVO():LearningModeVO {
      var result:LearningModeVO = getLearningModeVOFromID(currentLearningModeId);
      return result;
   }

   public function getCurrentNativeLanguageDisplayName_InCurrentNativeLanguage():String {
      return getLanguageDisplayName_FromLanguageIdAndDisplayLanguageId(_currentNativeLanguageVO.id, _currentNativeLanguageVO.id);
      /// Previously, we got this from resource XML - should we return to something like this?
      // return getLanguageNameTranslation(_currentNativeLanguageResourceXML, _currentNativeLanguageVO.iso639_3Code);
   }

   public function getCurrentNativeLanguageISO639_3Code():String {
      if (!_currentNativeLanguageVO)
            return null;
      return _currentNativeLanguageVO.iso639_3Code;
   }

   public function getCurrentTargetLanguageDisplayName_InCurrentNativeLanguage():String {
      return getLanguageDisplayName_FromLanguageIdAndDisplayLanguageId(_currentTargetLanguageVO.id, _currentNativeLanguageVO.id);
      /// Previously, we got this from resource XML - should we return to something like this?
      //return getLanguageNameTranslation(_currentTargetLanguageResourceXML, _currentNativeLanguageVO.iso639_3Code);
   }

   public function getDownloadedLessonSelectionTreeData():ArrayCollection {
      var report:MainModelDBOperationReport = selectData("getDownloadedLessonSelectionTreeData", new LessonVersionVO());
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getDownloadedLessonSelectionTreeData(): selectData() reports problem", report]);
      var tempDownloadedLessonData:ArrayCollection = new ArrayCollection();
      for each (var vo:LessonVersionVO in report.resultData) {
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
      var result:ArrayCollection = Utils_Tree.createDataSourceObject(tempDownloadedLessonData, lessonsSelectionTreeSortOptions);
      report.dispose();
      return result;
   }

   public static function getInstance():MainModel {
      if (!(_instance))
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function getLanguageDisplayName_AlphabetizableFromLanguageIdAndDisplayLanguageId(languageId:int, displayLanguageId:int):String {
      var ldnvo:LanguageDisplayNameVO = getLanguageDisplayNameVOFromLanguageIdAndDisplayLanguageId(languageId, displayLanguageId);
      if (!ldnvo)
         return null;
      return ldnvo.displayNameAlphabetizable;
   }

   public function getLanguageDisplayName_Alphabetizable_InCurrentNativeLanguage(languageId:int):String {
      return getLanguageDisplayName_AlphabetizableFromLanguageIdAndDisplayLanguageId(languageId, _currentNativeLanguageVO.id);
   }

   public function getLanguageDisplayName_FromLanguageIdAndDisplayLanguageId(languageId:int, displayLanguageId:int):String {
      var ldnvo:LanguageDisplayNameVO = getLanguageDisplayNameVOFromLanguageIdAndDisplayLanguageId(languageId, displayLanguageId);
      if (!ldnvo)
         return null;
      return ldnvo.displayName;
   }

   public function getLanguageDisplayName_InCurrentNativeLanguage(languageId:int):String {
      return getLanguageDisplayName_FromLanguageIdAndDisplayLanguageId(languageId, _currentNativeLanguageVO.id);
   }

   public function getLanguageDisplayNameVOFromLanguageIdAndDisplayLanguageId(languageId:int, displayLanguageId:int):LanguageDisplayNameVO {
      var queryVO:LanguageDisplayNameVO = new LanguageDisplayNameVO();
      queryVO.languageId = languageId;
      queryVO.displayLanguageId = displayLanguageId;
      var report:MainModelDBOperationReport = selectData("getLanguageDisplayNameVOFromLanguageIdAndDisplayLanguageId", queryVO, null, 1, 1);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLanguageDisplayNameVOFromLanguageIdAndDisplayLanguageId(): selectData() reports problem", report]);
      var result:LanguageDisplayNameVO = LanguageDisplayNameVO(report.resultData[0]);
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

   public function getLanguageVOFromID(id:int):LanguageVO {
      var queryVO:LanguageVO = new LanguageVO();
      queryVO.id = id;
      var report:MainModelDBOperationReport = selectData("getLanguageVOFromID", queryVO, null, 1, 1);
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLanguageVOFromID(): selectData() reports problem", report]);
      var result:LanguageVO = LanguageVO(report.resultData[0]);
      report.dispose();
      return result;
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
      if (report.isAnyProblems)
         Log.fatal(["MainModel.getLanguageVOs(): selectData() reports problem", report]);
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

   public function getLearningModeDisplayNameFromLabelToken(token:String):String {
      var result:String = getNativeLanguageResource("label_LearningMode_" + token);
      result = Utils_String.replaceAll(result, Constant_LangMentor_Misc.TOKEN_NATIVE_LANGUAGE_NAME, getCurrentNativeLanguageDisplayName_InCurrentNativeLanguage());
      result = Utils_String.replaceAll(result, Constant_LangMentor_Misc.TOKEN_TARGET_LANGUAGE_NAME, getCurrentTargetLanguageDisplayName_InCurrentNativeLanguage());
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

   public function getLessonVersionCount():int {
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
      var result:ChunkFileVO = getChunkFileVOFromChunkVOAndLanguageId(vo, _currentNativeLanguageVO.id);
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
      var result:ChunkFileVO = getChunkFileVOFromChunkVOAndLanguageId(vo, _currentTargetLanguageVO.id);
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

   public function getTargetLanguageResource(type:String):String {
      if (!_currentTargetLanguageResourceXML)
         return null;
      var result:String = _currentTargetLanguageResourceXML[type].toString();
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
      var result:String = Constant_LangMentor_Misc.FILEPATHINFO__ROOT_INFO_FOLDER_URL;
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
      initCache();
      _currentNativeLanguageVO = getLanguageVOFromIso639_3Code(Constant_AppConfiguration.LANGUAGE__DEFAULT__NATIVE__ISO639_3_CODE);
      initLessonsSelectionTreeSortOptions();
      _isDBDataInitialized = true;
      initTargetLanguageBasedDataIfReady();
      var cb:Callbacks = new Callbacks(onLoadConfigDataComplete, onLoadConfigDataFailure);
      configFileInfo.loadData(cb);
   }

   public function initSingleton():void {
      _appStatePersistenceManager = AppStatePersistenceManager.getInstance();
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

   public function isTargetLanguageSelected():Boolean {
      return (_currentTargetLanguageVO != null);
   }

   public function isTextDisplayTypeExists(typeName:String):Boolean {
      var vo:TextDisplayTypeVO = _index_TextDisplayTypeVOs_by_TypeName[typeName];
      return (vo != null);
   }

   public function retrievePersistedAppStateData():void {
      if (!_appStatePersistenceManager.isEnabled())
         return;
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
      if (!result.sqliteTransactionReport.isSuccessful)
         result.isAnyProblems = true;
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
      currentApplicationState = 0;
      currentLearningModeId = 0;
      _isDBDataInitialized = false;
      lessonsSelectionTreeSortOptions = null;
      // Dispose Cache
      Utils_Dispose.disposeDictionary(_index_LanguageIDs_by_Iso639_3Code, true);
      Utils_Dispose.disposeDictionary(_index_LearningModeVOs_by_ID, true);
      Utils_Dispose.disposeDictionary(_index_LessonVersionNativeLanguageVOs_by_LessonVersionVO, true);
      Utils_Dispose.disposeDictionary(_index_LessonVersionTargetLanguageVOs_by_LessonVersionVO, true);
      Utils_Dispose.disposeDictionary(_index_LevelIDs_by_LabelToken, true);
      Utils_Dispose.disposeDictionary(_index_LevelVOs_by_ID, true);
      Utils_Dispose.disposeDictionary(_index_LevelVOs_by_LabelToken, true);
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

   private function getDefaultLearningModeId():uint {
      return isAppDualLanguage() ?
            DEFAULT_LEARNING_MODE_ID__DUAL_LANGUAGE :
            DEFAULT_LEARNING_MODE_ID__SINGLE_LANGUAGE;
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
         _index_LanguageIDs_by_Iso639_3Code[languageVO.iso639_3Code] = languageVO.id;
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

   //// eliminate _isDBDataInitialized check - this is used in two different ways - as checked here, probably no longer needed
   // - is set in init() - as announced via change event here - notifies View_Home - via binding - model is ready
   // - also various other classes check this prop - should probably be renamed isModelInitialized
   private function initTargetLanguageBasedDataIfReady():void {
      if (Constant_AppConfiguration.CURRENT_MENTOR_TYPE__CODE != Constant_MentorTypes.MENTOR_TYPE_CODE__GLOBAL) {
         // This isn't "standard" mentor type, which means that the target language is specified in this constant...
         _currentTargetLanguageId = getLanguageIdFromIso639_3Code(Constant_AppConfiguration.LANGUAGE__DEFAULT__TARGET__ISO639_3_CODE);
         _appStatePersistenceManager.persistTargetLanguageId(_currentTargetLanguageId);
      }
      if (_currentTargetLanguageId == -1)
         return;
      if (!_isDBDataInitialized)
         return;
      _currentTargetLanguageVO = getLanguageVOFromID(_currentTargetLanguageId);
      loadLanguageResourceXML();
      _isTargetLanguageInitialized = true;
      setInitialLearningMode(); // We do this here, rather than in retrievePersistedAppStateData(), because the user may have chosen a target language that is the same as the native language, thus the app is in "single-language mode", which affects which default mode we use
      var cb:Callbacks = new Callbacks(onLoadLearningModeDescriptionsComplete, onLoadLearningModeDescriptionsFailure);
      var c:Command_LoadLearningModeDescriptions = new Command_LoadLearningModeDescriptions(cb);
      c.execute();
      dispatchEvent(new Event("isDataInitializedChange")); // We do this here because this is the point at which data is truly initialized, i.e. we have both DB data and _currentTargetLanguageVO
      reportAppStartupToAnalytics();
   }

   private function loadLanguageResourceXML():void {
      var appDir:File = File.applicationDirectory;
      var f:File;
      var s:String = Constant_LangMentor_Misc.FILEPATHINFO__LANGUAGE_RESOURCE_FOLDER_NAME + File.separator + _currentNativeLanguageVO.iso639_3Code + ".xml";
      f = appDir.resolvePath(Constant_LangMentor_Misc.FILEPATHINFO__LANGUAGE_RESOURCE_FOLDER_NAME + File.separator + _currentNativeLanguageVO.iso639_3Code + ".xml");
      if (f.exists)
         _currentNativeLanguageResourceXML = Utils_XML.synchronousLoadXML(f, true);
      else
         Log.error("MainModel.loadLanguageResourceXML(): language resource file for native language (" + _currentNativeLanguageVO.iso639_3Code + ") is missing");
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
   }

   private function onLoadConfigDataFailure(techReport:ConfigFileInfoTechReport):void {
      //
      //    Are you running on the desktop, without Tomcat running?  :)
      //
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
      data += "appName=" + Constant_AppConfiguration.APP_NAME + ":";
      data += "appVersion=" + String(Utils_AIR.appVersionNumber) + ":";
      data += "mentorType=" + Constant_AppConfiguration.CURRENT_MENTOR_TYPE__CODE + ":";
      data += "languages=" + getNativeLanguageIso639_3Code() + ">" + getTargetLanguageIso639_3Code();
      Utils_GoogleAnalytics.trackAppStartup(data);
   }

   private function setInitialLearningMode():void {
      if (_appStatePersistenceManager.retrieveIsSelectedLearningModeIdSaved())
         currentLearningModeId = _appStatePersistenceManager.retrieveSelectedLearningModeId();
      else
         currentLearningModeId = getDefaultLearningModeId();
   }

}
}

