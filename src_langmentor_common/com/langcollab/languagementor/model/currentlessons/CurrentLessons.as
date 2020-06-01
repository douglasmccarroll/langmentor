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






 CurrentLessons's responsibilities include:
 - To compute and keep track of what lesson and chunk are "current".
 - To handle concepts like "iterate chunk" and "iterate lesson" - in both forward and backward directions.
 - To serve as a buffer between user actions and AudioController. It uses CurrentLessonsAudioTimer to delay audio play
 slightly. Why? AudioController.playCurrentLessonVersionAndCurrentChunk() can be a fairly CPU intensive process,
 especially when starting a new lesson - it creates many instances etc. If the user repeatedly initiates actions that
 will result in this method being called - such as Next Chunk, Next Lesson, etc. - and does these within a short
 period of time - we don't want AudioController.playCurrentLessonVersionAndCurrentChunk() to get called repeatedly. We
 only want it to get called once. Also, delaying audio play allows the app to update its display during the pause and
 actually makes the app feel more responsive.






 */
package com.langcollab.languagementor.model.currentlessons {
import com.brightworks.constant.Constant_ReleaseType;
import com.brightworks.event.Event_Audio;
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_ANEs;
import com.brightworks.util.Utils_ArrayVectorEtc;
import com.brightworks.util.Utils_Dispose;
import com.brightworks.util.Utils_GoogleAnalytics;
import com.brightworks.util.Utils_System;
import com.brightworks.util.audio.AudioPlayer;
import com.brightworks.util.audio.Utils_ANEs_Audio;
import com.brightworks.util.audio.Utils_Audio_Files;
import com.brightworks.util.singleton.SingletonManager;
import com.langcollab.languagementor.constant.Constant_MentorTypeSpecific;
import com.langcollab.languagementor.constant.Constant_UserActionTypes;
import com.langcollab.languagementor.controller.audio.AudioController;
import com.langcollab.languagementor.controller.useractionreporting.UserAction;
import com.langcollab.languagementor.controller.useractionreporting.UserActionReportingManager;
import com.langcollab.languagementor.event.Event_CurrentLessonsAudioTimer;
import com.langcollab.languagementor.model.MainModel;
import com.langcollab.languagementor.model.appstatepersistence.AppStatePersistenceManager;
import com.langcollab.languagementor.vo.ChunkVO;
import com.langcollab.languagementor.vo.LessonVersionVO;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;

import mx.collections.ArrayCollection;

import spark.collections.Sort;
import spark.collections.SortField;

public class CurrentLessons extends EventDispatcher implements IManagedSingleton {
   private static var _instance:CurrentLessons;

   private var _appStatePersistenceManager:AppStatePersistenceManager;
   private var _audioTimer:CurrentLessonsAudioTimer = new CurrentLessonsAudioTimer();
   private var _audioController:AudioController;
   private var _audioPlayer:AudioPlayer;
   private var _currentLessons:ArrayCollection;
   private var _index_ChunkFileLists_by_LessonVersionVO:Dictionary = new Dictionary();
   private var _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO:Dictionary = new Dictionary();
   private var _index_LessonVersionVOs_by_ChunkVO:Dictionary = new Dictionary();
   private var _model:MainModel;
   private var _sleepTimer:Timer;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private var _currentChunkVO_OnlySetViaSetCurrentLessonAndChunkIndexes:ChunkVO;

   [Bindable(event="currentChunkVOChange")]
   public function get currentChunkVO():ChunkVO {
      return _currentChunkVO_OnlySetViaSetCurrentLessonAndChunkIndexes;
   }

   private var _currentChunkIndex_OnlySetViaSetCurrentLessonAndChunkIndexes:int = 0;

   public function get currentChunkIndex():int {
      return _currentChunkIndex_OnlySetViaSetCurrentLessonAndChunkIndexes;
   }

   public function get currentLessonChunks_SortedByLocationInOrder():Array {
      if (currentLessonVO == null)
         return null;
      var result:Array = (Utils_ArrayVectorEtc.useVoEqualsFunctionToGetItemFromDictionary(currentLessonVO, _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO, true) as Array).slice();
      return result;
   }

   public function get currentLessonChunkFiles():Array {
      if (currentLessonVO == null)
         return null;
      var result:Array = (Utils_ArrayVectorEtc.useVoEqualsFunctionToGetItemFromDictionary(currentLessonVO, _index_ChunkFileLists_by_LessonVersionVO, true) as Array).slice();
      return result;
   }

   private var _currentLessonIndex_OnlySetViaSetCurrentLessonAndChunkIndexes:int = -1;

   public function get currentLessonIndex():int {
      return _currentLessonIndex_OnlySetViaSetCurrentLessonAndChunkIndexes;
   }

   public function get currentLessons():Array {
      var result:Array = [];
      for each (var info:SortableLessonVersionInfo in _currentLessons) {
         result.push(info.lessonVersionVO);
      }
      return result;
   }

   public function get currentLessonVersionLessonId():String {
      if (!currentLessonVO) {
         return null;
      }
      return currentLessonVO.publishedLessonVersionId;
   }

   public function get currentLessonVersionLessonName_NativeLanguage():String {
      if (!currentLessonVO) {
         return null;
      }
      if (!_model) {
         return null;
      }
      return _model.getLessonVersionNativeLanguageNameFromLessonVersionVO(currentLessonVO);
   }

   public function get currentLessonVersionProviderId():String {
      if (!currentLessonVO) {
         return null;
      }
      return currentLessonVO.contentProviderId;
   }

   public function get currentLessonVersionVersion():String {
      if (!currentLessonVO) {
         return null;
      }
      return currentLessonVO.publishedLessonVersionVersion;
   }

   public function get currentLessonUnsuppressedChunks():Array {
      if (!(currentLessonVO))
         return null;
      var result:Array = [];
      for each (var chunkVO:ChunkVO in currentLessonChunks_SortedByLocationInOrder) {
         if (!chunkVO.suppressed)
            result.push(chunkVO);
      }
      return result;
   }

   public function get currentLessonVO():LessonVersionVO {
      if (_currentLessons.length == 0)
         return null;
      if (currentLessonIndex == -1)
         return null;
      if (currentLessonIndex >= _currentLessons.length) {
         Log.error("CurrentLessons.get currentLesson(): currentLessonIndex = " + currentLessonIndex + "; _currentLessons.length = " + _currentLessons.length);
         return null;
      }
      var result:LessonVersionVO = SortableLessonVersionInfo(_currentLessons[currentLessonIndex]).lessonVersionVO;
      return result;
   }

   private var _isLessonPaused:Boolean = true;

   public function get isLessonPaused():Boolean {
      return _isLessonPaused;
   }

   private var _isLessonPlaying:Boolean = false;

   public function get isLessonPlaying():Boolean {
      return _isLessonPlaying;
   }

   [Bindable("sleepTimerActiveChange")]
   public function get isSleepTimerActive():Boolean {
      return (_sleepTimer != null);
   }

   [Bindable("lengthChange")]
   public function get length():int {
      return _currentLessons.length;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function CurrentLessons(manager:SingletonManager) {
      _instance = this;
      _currentLessons = new ArrayCollection();
      sortArrayCollectionOfSortableLessonVersionInfoInstances(_currentLessons);
      _audioTimer.addEventListener(Event_CurrentLessonsAudioTimer.AUDIO_PLAY_ALLOWED, onAudioPlayAllowed);
   }

   public function add(vo:LessonVersionVO, suppressLengthChangeEvent:Boolean = false, suppressPersistingData:Boolean = false):void {
      Log.debug(["CurrentLessons.add()", vo]);
      if (contains(vo)) {
         Log.error("CurrentLessons.add(): Lesson is already added");
         return;
      }
      var chunkFileList:Array = _model.getChunkFileVOListFromLessonVersionVO(vo);
      _index_ChunkFileLists_by_LessonVersionVO[vo] = chunkFileList;
      var chunkList:Array = _model.getChunkVOsSortedByLocationInOrderFromLessonVersionVO(vo);
      _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO[vo] = chunkList;
      for each (var chunkVO:ChunkVO in chunkList) {
         _index_LessonVersionVOs_by_ChunkVO[chunkVO] = vo;
      }
      var info:SortableLessonVersionInfo = createSortableLessonVersionInfoInstanceBasedOnLessonVersionVO(vo);
      _currentLessons.addItem(info);
      if (currentLessonIndex == -1) {
         setCurrentLessonAndChunkIndexesToFirstPlayableLessonAndChunk(suppressPersistingData);
      } else if (getLessonIndex(vo) <= currentLessonIndex) {
         // 20190116 dmccarroll - this comment written after modifying View_SelectLessons so that it sets the current lesson when the user exits the screen
         // In abstract terms, this is probably a reasonable thing to do as a general strategy.
         // Is it useful in practical terms? It doesn't look as though it is.
         // This method is called in two places:
         //   1. Command_AddOrRemoveSelectedLessonVersion.execute() - which is only called from the Select Lessons screen
         //      In this case, what we do here gets overridden - when the user leaves this screen the current lesson is usually set again
         //   2. CurrentLessons.addAll() - I'm guessing that this is only called when we start the app and are initializing with persisted data.
         //      We also initialize 'current selected lesson' (though I can't (quickly) find the code that does this.
         //      So what we do here also gets overridden in that case.
         setCurrentLessonAndChunkIndexes(currentLessonIndex + 1, currentChunkIndex);  /// See comment above - we should probably drop this - but we need a fair amount of testing before we release such a change
      }
      if (!suppressPersistingData)
         persistSelectedLessonVersionData();
      if (!suppressLengthChangeEvent)
         dispatchEvent(new Event("lengthChange"));
   }

   public function addAll(lessonVOs:ArrayCollection, suppressLengthChangeEvent:Boolean = false, suppressPersistingData:Boolean = false):void {
      Log.debug(["CurrentLessons.addAll()", lessonVOs]);
      for each (var lessonVO:LessonVersionVO in lessonVOs) {
         add(lessonVO, true, true);
      }
      if ((!suppressLengthChangeEvent) && (lessonVOs.length > 0))
         dispatchEvent(new Event("lengthChange"));
      if (!suppressPersistingData)
         persistSelectedLessonVersionData();
   }

   public function areNewCurrentLessonAndChunkIndexesAllowed(newLessonIndex:int, newChunkIndex:int):Boolean {
      if ((newLessonIndex == -1) && (newChunkIndex == -1))
         return true;
      if ((newLessonIndex < 0) || (newChunkIndex < 0)) {
         Log.debug("CurrentLessons.areNewCurrentLessonAndChunkIndexesAllowed(): Not allowed because newLessonIndex < 0");
         return false;
      }
      if (newLessonIndex > (length - 1)) {
         Log.debug("CurrentLessons.areNewCurrentLessonAndChunkIndexesAllowed(): Not allowed because newLessonIndex > (length - 1)");
         return false;
      }
      var lvvo:LessonVersionVO = getLessonByIndex(newLessonIndex);
      if (newChunkIndex < 0) {
         Log.debug("CurrentLessons.areNewCurrentLessonAndChunkIndexesAllowed(): Not allowed because newChunkIndex < 0");
         return false;
      }
      if (newChunkIndex > (getChunkCountForLessonVersionVO(lvvo) - 1)) {
         Log.debug("CurrentLessons.areNewCurrentLessonAndChunkIndexesAllowed(): Not allowed because newChunkIndex greater than chunk count - 1");
         return false;
      }
      var chunkVO:ChunkVO = getChunkVOByLessonVersionVOAndChunkLocationInOrder(lvvo, newChunkIndex + 1);
      if (chunkVO.suppressed) {
         Log.debug("CurrentLessons.areNewCurrentLessonAndChunkIndexesAllowed(): Not allowed because chunk suppressed");
         return false;
      }
      return true;
   }

   public function contains(vo:LessonVersionVO):Boolean {
      for each (var info:SortableLessonVersionInfo in _currentLessons) {
         if (info.lessonVersionVO.equals(vo))
            return true;
      }
      return false;
   }

   public function doesLessonVersionContainAnyUnsuppressedChunks(lvvo:LessonVersionVO):Boolean {
      var chunkVOs:Array = (Utils_ArrayVectorEtc.useVoEqualsFunctionToGetItemFromDictionary(lvvo, _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO, true) as Array);
      for each (var cvo:ChunkVO in chunkVOs) {
         if (!cvo.suppressed)
            return true;
      }
      return false;
   }

   public function ensureStateIntegrity(previousCurrentLessonVO:LessonVersionVO = null, previousCurrentChunkIndex:int = -2):void {
      // This method was originally written to deal with the ramifications of setting
      // the 'supressed' property of ChunkVO instances to true, e.g. the fact that a
      // lesson may no longer contain any unsupressed chunks, etc.
      // We called this from Command_DoIKnowThis because sometimes it
      // happens that, well, 'things got screwed up'. It seems that perhaps
      // this happens/happened because sometimes the sort of things that are done here
      // don't get persisted when done elsewhere, and we're in a state where the
      // chunk suppression got persisted but the other stuff didn't.
      // While you might think that we could persist all this stuff as a single transaction,
      // this is complicated by the fact that we're persisting the things that
      // this method does using our state persistence mechanism (using SharedObject),
      // and the chunk suppression is persisted to SQLite.
      //
      // With the passing of time, this method has evolved into the go-to method for 'ensuring
      // state integrity'. Specifically, we do the following:
      //  - Remove lessons where all chunks are suppressed
      //  - Determine a new current lesson index
      //  - Determine a new current chunk index
      //
      // Variables whose names start with 'new...':
      //     One of the goals of this method is to avoid multiple firings of events that announce that
      // bindable props have changed. These props include 'length', 'currentLessonIndex' and 'currentChunkIndex'.
      // In order to accomplish this we store new values in temp vars that have names starting with 'new...', then
      // set the properties (once) at the end of the method.
      //
      // We use this logic to determine the new lesson index:
      //  - If no lessons are selected, set currentLessonIndex = -1
      //  - If, for some reason, we don't have a previousCurrentLessonVO, set the first lesson in
      //    list as current lesson
      //  - If previousCurrentLessonVO is still selected, keep it as current lesson.
      //  - If none of the above conditions are met, this means that we have one or more
      //    lessons selected, other than the previousCurrentLessonVO, and we need to select one of
      //    these. We do this by selecting the one that is 'next' after the previousCurrentLessonVO.
      //    See comments in code for details.
      //
      //
      Log.debug(["CurrentLessons.ensureStateIntegrity()"]);
      if (!previousCurrentLessonVO)
         previousCurrentLessonVO = currentLessonVO;
      if (previousCurrentChunkIndex == -2)
         previousCurrentChunkIndex = currentChunkIndex;
      var previousCurrentLessonsData:ArrayCollection = new ArrayCollection();
      var previousLength:uint = length;
      for each (var lvvo:LessonVersionVO in currentLessons) {
         previousCurrentLessonsData.addItem(lvvo);
      }
      var newCurrentLessonsData:ArrayCollection = new ArrayCollection();
      var newCurrentChunkIndex:int = -1;
      var newCurrentLessonIndex:int = -1;
      // 20130711 dmccarroll
      // Note that this removes lessons with all chunks suppressed, but doesn't unsuppress the chunks. It would probably  ///
      // be both correct and safest to do so. Currently this unsuppressing gets done in Command_DoIKnowThis, so everything 'works', but given that
      // this method's purpose is to _ensure_ state integrity ...
      for each (var info:SortableLessonVersionInfo in _currentLessons) {
         if (doesLessonVersionContainAnyUnsuppressedChunks(info.lessonVersionVO))
            newCurrentLessonsData.addItem(info.lessonVersionVO);
      }
      removeAll(true, true);
      addAll(newCurrentLessonsData, true);
      if (!isAnySelectedLessonVersionsHaveUnsuppressedChunks()) {
         newCurrentLessonIndex = -1;
      } else if (!previousCurrentLessonVO) {
         newCurrentLessonIndex = 0;
      } else {
         // We have selected lesson versions, and we have a previousCurrentLesson (though
         // it may not be selected). In all these cases, we can determine what the
         // newCurrentLessonIndex should be based on the previousCurrentLesson.
         // First, we see if we can simply use the previousCurrentLesson.
         if (contains(previousCurrentLessonVO)) {
            newCurrentLessonIndex = getLessonIndex(previousCurrentLessonVO);
         } else {
            // We have a previousCurrentLessonVO, but it isn't selecteded.
            // We also have one or more lesson versions that are selected.
            // What we do here is to find out which lesson version would be next in the list after
            // the previousCurrentLessonVO, if it were in the list.
            var tempSortableLessonVersionInfoInstancesList:ArrayCollection = new ArrayCollection();
            sortArrayCollectionOfSortableLessonVersionInfoInstances(tempSortableLessonVersionInfoInstancesList);
            for each (lvvo in newCurrentLessonsData) {
               tempSortableLessonVersionInfoInstancesList.addItem(createSortableLessonVersionInfoInstanceBasedOnLessonVersionVO(lvvo));
            }
            var addPreviousCurrentLessonToTempList:Boolean = true;
            for each (info in tempSortableLessonVersionInfoInstancesList) {
               if (info.lessonVersionVO.equals(previousCurrentLessonVO)) {
                  addPreviousCurrentLessonToTempList = false;
                  break;
               }
            }
            if (addPreviousCurrentLessonToTempList) {
               info = createSortableLessonVersionInfoInstanceBasedOnLessonVersionVO(previousCurrentLessonVO);
               tempSortableLessonVersionInfoInstancesList.addItem(info);
            }
            // Next, find next lesson in temp list. First, try to find it after prev current lesson.
            var previousCurrentLessonIndexInTempList:int = tempSortableLessonVersionInfoInstancesList.getItemIndex(info);
            newCurrentLessonIndex = getIndexForNextLessonInSortedLessonInfoList(tempSortableLessonVersionInfoInstancesList, previousCurrentLessonIndexInTempList);
            if ((addPreviousCurrentLessonToTempList) && (newCurrentLessonIndex > previousCurrentLessonIndexInTempList))
               newCurrentLessonIndex--;
            if (newCurrentLessonIndex == -1) {
               // This should never happen
               Log.error("CurrentLessons.ensureStateIntegrity(): Can't find new current lesson in temp list, which should be logically impossible");
               newCurrentLessonIndex = -1;
            }
         }
      }
      // Now we set newCurrentChunkIndex
      if (newCurrentLessonIndex == -1) {
         newCurrentChunkIndex = -1;
      } else {
         // We have a current lesson, so we have at least one lesson and, as all selected lessons have at least one
         // non-suppressed chunk, we should be able to find a current chunk.
         var newCurrentLessonVO:LessonVersionVO = SortableLessonVersionInfo(_currentLessons[newCurrentLessonIndex]).lessonVersionVO;
         if (newCurrentLessonVO.equals(previousCurrentLessonVO)) {
            // We haven't changed lessons, yet...
            if (doesUnsuppressedChunkExistAtOrAfterChunk(newCurrentLessonVO, previousCurrentChunkIndex)) {
               // Theres an unsuppressed chunk available, after the previous chunk index, in the (previous AND new)
               // current lesson, so we can use that lesson
               newCurrentChunkIndex = getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(newCurrentLessonVO, previousCurrentChunkIndex, 1);
            } else {
               // There aren't any unsuppressed chunks available after the previous current chunk in the current lesson, so we either need
               // to move to the next lesson or, if there is no other lesson, look in the current lesson, starting from the first chunk.
               if (length > 1) {
                  // There are other lessons to look in, so we a) change newCurrentLessonIndex, then b) find
                  // its first unsuppressed chunk's index
                  newCurrentLessonIndex = getIndexForNextLessonInSortedLessonInfoList(_currentLessons, newCurrentLessonIndex);
                  newCurrentLessonVO = SortableLessonVersionInfo(_currentLessons[newCurrentLessonIndex]).lessonVersionVO;
                  newCurrentChunkIndex = getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(newCurrentLessonVO, 0, 1);
               } else {
                  // There aren't any other lessons to look in so we look in the current lesson, starting from the first chunk.
                  newCurrentChunkIndex = getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(newCurrentLessonVO, 0, 1);
               }
            }
         } else {
            // We've changed lessons - find first unsuppressed chunk in newCurrentLesson
            newCurrentChunkIndex = getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(newCurrentLessonVO, 0, 1);
         }
         if (newCurrentChunkIndex == -1) {
            Log.error("CurrentLessons.ensureStateIntegrity(): Can't find new current chunk, even though we've identified a current lesson, which should be logically impossible");
         }
      }
      if (areNewCurrentLessonAndChunkIndexesAllowed(newCurrentLessonIndex, newCurrentChunkIndex)) {
         setCurrentLessonAndChunkIndexes(newCurrentLessonIndex, newCurrentChunkIndex);
      } else {
         if (isAnySelectedLessonVersionsHaveUnsuppressedChunks()) {
            setCurrentLessonAndChunkIndexesToFirstPlayableLessonAndChunk();
         } else {
            setCurrentLessonAndChunkIndexes(-1, -1);
         }
      }
      if (length != previousLength)
         dispatchEvent(new Event("lengthChange"));
   }

   public function getChunkNativeDisplayText(chunkVO:ChunkVO):String {
      return chunkVO.textNativeLanguage;
   }

   public function getChunkVOByLessonVersionVOAndChunkLocationInOrder(lvvo:LessonVersionVO, loc:uint):ChunkVO {
      var result:ChunkVO;
      var list:Array = (Utils_ArrayVectorEtc.useVoEqualsFunctionToGetItemFromDictionary(lvvo, _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO, true) as Array);
      if (!(list is Array)) {
         Log.error(["CurrentLessons.getChunkVOByLessonVersionVOAndChunkLocationInOrder(): _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO doesn't contain VO as key value", lvvo, _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO]);
         return null;
      }
      // This _should_ work...
      result = list[loc - 1];
      if (result.locationInOrder != loc) {
         // Something is wrong... let's look at all the ChunkVO instances in the list...
         Log.warn(["CurrentLessons.getChunkVOByLessonVersionVOAndChunkLocationInOrder(): chunk list for VO doesn't contain VO with correct locationInOrder value a 'loc - 1' position in chunk list", lvvo, loc, _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO]);
         for each (var chunkVO:ChunkVO in list) {
            if (chunkVO.locationInOrder == loc) {
               result = chunkVO;
               break;
            }
         }
      }
      if (!result)
         Log.error(["CurrentLessons.getChunkVOByLessonVersionVOAndChunkLocationInOrder(): chunk list for VO doesn't contain VO with correct loc", lvvo, loc, _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO]);
      return result;
   }

   public function getCountOfCurrentSelectedLessonVersionsWithUnsuppressedChunks():uint {
      var result:uint = 0;
      for each (var lv:LessonVersionVO in currentLessons) {
         if (doesLessonVersionContainAnyUnsuppressedChunks(lv))
            result++;
      }
      return result;
   }

   public function getIndexForEarliestUnsuppressedChunkInCurrentLesson():int {
      Log.debug("CurrentLessons.getIndexForEarliestUnsuppressedChunkInCurrentLesson()");
      var index:int = getIndexForEarliestUnsuppressedChunkInLesson(currentLessonVO);
      Log.debug("CurrentLessons.getIndexForEarliestUnsuppressedChunkInCurrentLesson(): returning index of: " + index);
      return index;
   }

   public function getIndexForEarliestUnsuppressedChunkInLesson(lessonVO:LessonVersionVO):int {
      Log.debug("CurrentLessons.getIndexForEarliestUnsuppressedChunkInLesson()");
      var index:int = getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(lessonVO, 0, 1);
      Log.debug("CurrentLessons.getIndexForEarliestUnsuppressedChunkInLesson(): returning index of: " + index);
      return index;
   }

   public function getIndexForEarliestUnsuppressedChunkInLessonWithIndexOf(index:int):int {
      Log.debug("CurrentLessons.getIndexForEarliestUnsuppressedChunkInLessonWithIndexOf()");
      var lessonVO:LessonVersionVO = SortableLessonVersionInfo(_currentLessons[index]).lessonVersionVO;
      var index:int = getIndexForEarliestUnsuppressedChunkInLesson(lessonVO);
      Log.debug("CurrentLessons.getIndexForEarliestUnsuppressedChunkInLessonWithIndexOf(): returning index of: " + index);
      return index;
   }

   public function getIndexForFirstSelectedLessonVersionWithUnsuppressedChunks():uint {
      var result:int = -1;
      for (var index:uint = 0; index < currentLessons.length; index++) {
         var vo:LessonVersionVO = getLessonByIndex(index);
         if (doesLessonVersionContainAnyUnsuppressedChunks(vo)) {
            result = index;
            break;
         }
      }
      return result;
   }

   public function getIndexForLastUnsuppressedChunkInLesson(lessonVO:LessonVersionVO):int {
      Log.debug("CurrentLessons.getIndexForLastUnsuppressedChunkInLesson()");
      var chunkCountInLesson:uint = getChunkCountForLessonVersionVO(lessonVO);
      var index:int = getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(lessonVO, chunkCountInLesson - 1, -1);
      Log.debug("CurrentLessons.getIndexForLastUnsuppressedChunkInLesson(): returning index of: " + index);
      return index;
   }

   public function getIndexForNextOrPreviousSelectedLessonVersion(startIndex:uint, direction:int):uint {
      if (!((direction == -1) || (direction == 1)))
         Log.fatal("CurrentLessons.getIndexForNextOrPreviousSelectedLessonVersion(): direction arg must be -1 or 1");
      if (getSelectedLessonVersionsCount() == 0)
         Log.fatal("CurrentLessons.getIndexForNextOrPreviousSelectedLessonVersion(): no selected lessons");
      var lvCount:uint = length;
      var result:uint;
      if ((direction == 1) && (startIndex == (lvCount - 1))) {
         result = 0;
      } else if ((direction == -1) && (startIndex == 0)) {
         result = lvCount - 1;
      } else {
         result = startIndex + direction;
      }
      return result;
   }

   public function getIndexOfCurrentChunkWithinUnsuppressedChunks():int {
      if (!(currentLessonVO)) {
         Log.error("CurrentLessons.getIndexOfCurrentChunkWithinUnsuppressedChunks(): currentLessonVO is null");
         return -1;
      }
      if (!(currentChunkVO)) {
         Log.error("CurrentLessons.getIndexOfCurrentChunkWithinUnsuppressedChunks(): currentChunkVO is null");
         return -1;
      }
      if (!(currentLessonUnsuppressedChunks)) {
         Log.error("CurrentLessons.getIndexOfCurrentChunkWithinUnsuppressedChunks(): currentLessonUnsuppressedChunks is null");
         return -1;
      }
      var result:int = -1;
      for (var i:uint = 0; i < currentLessonUnsuppressedChunks.length; i++) {
         var chunkVO:ChunkVO = currentLessonUnsuppressedChunks[i];
         if (chunkVO.equals(currentChunkVO)) {
            result = i;
            break;
         }
      }
      if (result == -1)
         Log.error("CurrentLessons.getIndexOfCurrentChunkWithinUnsuppressedChunks(): currentChunkVO not found within currentLessonUnsuppressedChunks");
      return result;
   }

   public static function getInstance():CurrentLessons {
      if (!(_instance))
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function getLessonByIndex(index:uint):LessonVersionVO {
      if (index >= length) {
         Log.error("CurrentLesson.getLessonByIndex(): index >= length; index = " + index + "; length = " + length);
         return null;
      }
      if (index < 0) {
         Log.error("CurrentLesson.getLessonByIndex(): index < 0; index = " + index);
         return null;
      }
      var result:LessonVersionVO = SortableLessonVersionInfo(_currentLessons[index]).lessonVersionVO;
      return result;
   }

   public function getLessonForChunk(vo:ChunkVO):LessonVersionVO {
      var lvvo:LessonVersionVO = LessonVersionVO(Utils_ArrayVectorEtc.useVoEqualsFunctionToGetItemFromDictionary(vo, _index_LessonVersionVOs_by_ChunkVO, true));
      return lvvo;
   }

   public function getLessonIndex(vo:LessonVersionVO):int {
      for (var i:int = 0; i < _currentLessons.length; i++) {
         var info:SortableLessonVersionInfo = _currentLessons[i];
         if (info.lessonVersionVO.equals(vo))
            return i;
      }
      return -1;
   }

   public function getSelectedDualLanguageLessonVersionCount():uint {
      var result:uint = 0;
      for each (var lv:LessonVersionVO in currentLessons) {
         if (lv.isDualLanguage)
            result++;
      }
      return result;
   }

   public function getSelectedDualLanguageLessonVersionWithUnsuppressedChunksCount():uint {
      var result:uint = 0;
      for each (var lv:LessonVersionVO in currentLessons) {
         if ((lv.isDualLanguage) && (doesLessonVersionContainAnyUnsuppressedChunks(lv)))
            result++;
      }
      return result;
   }

   public function getSelectedLessonVersionChunkCount():int {
      return getChunkCountForLessonVersionVO(currentLessonVO);
   }

   public function getSelectedLessonVersionsCount():int {
      return currentLessons.length;
   }

   public function getSelectedSingleLanguageLessonVersionCount():uint {
      var result:uint = 0;
      for each (var lv:LessonVersionVO in currentLessons) {
         if (!lv.isDualLanguage)
            result++;
      }
      return result;
   }

   public function initSingleton():void {
      _appStatePersistenceManager = AppStatePersistenceManager.getInstance();
      _audioController = AudioController.getInstance();
      _model = MainModel.getInstance();
      _audioPlayer = AudioPlayer.getInstance();
      _audioPlayer.addEventListener(Event_Audio.AUDIO__USER_STARTED_AUDIO, onUserStartedAudio);
      _audioPlayer.addEventListener(Event_Audio.AUDIO__USER_STOPPED_AUDIO, onUserStoppedAudio);
      Utils_ANEs_Audio.setAppPauseFunction(pauseCurrentLessonVersionIfPlaying);
   }

   public function isAllSelectedLessonVersionsDualLanguage():Boolean {
      var count1:uint = getSelectedDualLanguageLessonVersionCount();
      var count2:uint = getSelectedLessonVersionsCount();
      return (count1 == count2);
   }

   public function isAllSelectedLessonVersionsSingleLanguage():Boolean {
      var count1:uint = getSelectedSingleLanguageLessonVersionCount();
      var count2:uint = getSelectedLessonVersionsCount();
      return (count1 == count2);
   }

   public function isAnySelectedLessonVersionsDualLanguage():Boolean {
      return (getSelectedDualLanguageLessonVersionCount() > 0);
   }

   public function isAnySelectedLessonVersionsDualLanguageAndHaveUnsuppressedChunks():Boolean {
      return (getSelectedDualLanguageLessonVersionWithUnsuppressedChunksCount() > 0);
   }

   public function isAnySelectedLessonVersionsHaveUnsuppressedChunks():Boolean {
      return (getCountOfCurrentSelectedLessonVersionsWithUnsuppressedChunks() > 0);
   }

   public function isAnySelectedLessonVersionsSingleLanguage():Boolean {
      return (getSelectedSingleLanguageLessonVersionCount() > 0);
   }

   public function isCurrentLessonAlphaReviewVersion():Boolean {
      if (!currentLessonVO)
         return false;
      return (currentLessonVO.releaseType == Constant_ReleaseType.ALPHA);
   }

   public function isCurrentLessonDualLanguage():Boolean {
      if (!currentLessonVO)
         return false;
      return currentLessonVO.isDualLanguage;
   }

   public function iterateChunk(direction:int, isUserInitiated:Boolean):void {
      Log.info("CurrentLessons.iterateChunk(): lesson ID: " + currentLessonVO.publishedLessonVersionId + "; currentChunkIndex: " + currentChunkIndex + "; direction: " + direction);
      if (!isAnySelectedLessonVersionsHaveUnsuppressedChunks()) {
         Log.error("CurrentLessons.iterateChunk(): isAnySelectedLessonVersionsHaveUnsuppressedChunks() returns false");
         return;
      }
      _audioController.pausePlayingAudioIfAny();
      var newChunkIndex:int = -2;
      if (doesUnsuppressedChunkExistBeforeOrAfterChunk(currentLessonVO, currentChunkIndex, direction)) {
         // There's a chunk that we can move to within the current lesson version
         if (!isUserInitiated) {   // We don't want to report 'auto-play' if this was initiated by the user clicking a button
            reportUserActivity_AutoPlay_AdvanceChunk(currentChunkIndex);
         }
         newChunkIndex = getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(currentLessonVO, currentChunkIndex + direction, direction);
         setCurrentLessonAndChunkIndexes(currentLessonIndex, newChunkIndex);
         Log.debug("CurrentLessons.iterateChunk(): new currentChunkIndex: " + currentChunkIndex);
      } else {
         // No unsuppressed chunk in 'direction' in current lesson version
         var newLessonIndex:uint = getIndexForNextOrPreviousSelectedLessonVersion(currentLessonIndex, direction);
         var newLessonVO:LessonVersionVO = getLessonByIndex(newLessonIndex);
         if (direction == -1) {
            // Move to last chunk in previous lesson
            newChunkIndex = getIndexForLastUnsuppressedChunkInLesson(newLessonVO);
            setCurrentLessonAndChunkIndexes(newLessonIndex, newChunkIndex);
            Log.debug("CurrentLessons.iterateChunk(): no unsuppressed chunk before curr chunk; new currentChunkIndex: " + currentChunkIndex);
         } else if (direction == 1) {
            // We want to move to the next lesson, if there is one. Otherwise
            // we'd like to restart the current lesson.
            if (!isUserInitiated) {   // We don't want to report 'finished lesson' or 'auto play' if this was initiated by the user clicking a button
               reportToAnalytics_LessonFinished();
               reportUserActivity_AutoPlay_AdvanceChunk(currentChunkIndex, newLessonVO);
            }
            iterateLessonVersion(1, isUserInitiated);
            var calledIterateLessonVersion:Boolean = true;
            Log.debug("CurrentLessons.iterateChunk(): no unsuppressed chunk after curr chunk; iterated lesson; new lesson ID: " + currentLessonVO.publishedLessonVersionId);
         } else {
            Log.error("CurrentLessons.iterateChunk(): 'direction' param is incorrect");
         }
      }
      if (calledIterateLessonVersion)
         return; // iterateLessonVersion does the stuff below, and we don't want to do it twice
      if ((_isLessonPlaying) && (!_isLessonPaused)) {
         if (isUserInitiated) {
            _audioTimer.requestAudioPlayPermission();
         } else {
            Log.debug("CurrentLessons.iterateChunk(): Not user initiated, calling AudioController.playCurrentLessonVersionAndCurrentChunk()");
            _audioController.playCurrentLessonVersionAndCurrentChunk();
         }
      }
   }

   // Before using this method, call isAnySelectedLessonVersionsHaveUnsuppressedChunks();
   public function iterateLessonVersion(direction:int, isUserInitiated:Boolean):void {
      Log.debug(["CurrentLessons.iterateLessonVersion(): direction=" + direction + " isUserInitiated=" + isUserInitiated]);
      if (!isAnySelectedLessonVersionsHaveUnsuppressedChunks())
         Log.fatal("CurrentLessons.iterateLessonVersion(): client code failed to call isAnySelectedLessonVersionsHaveUnsuppressedChunks() first");
      if (currentLessonIndex == -1)
         Log.fatal("CurrentLessons.getIndexForNextOrPreviousSelectedLessonVersion(): no current lesson version");
      if (!((direction == -1) || (direction == 1)))
         Log.fatal("CurrentLessons.iterateLessonVersion(): direction arg must be -1 or 1");
      _audioController.pausePlayingAudioIfAny();
      if ((direction == 1) || (getIndexOfCurrentChunkWithinUnsuppressedChunks() == 0)) {
         // If direction==1 we go to next lesson; if -1 and we're in the 1st unsuppressed chunk, we go to previous lesson
         var newCurrentLessonIndex:int = getIndexForNextOrPreviousSelectedLessonVersionWithUnsuppressedChunks(direction);
         var newCurrentChunkIndex:int = getIndexForEarliestUnsuppressedChunkInLessonWithIndexOf(newCurrentLessonIndex);
         setCurrentLessonAndChunkIndexes(newCurrentLessonIndex, newCurrentChunkIndex);
      } else {
         setCurrentLessonAndChunkIndexes(currentLessonIndex, getIndexForEarliestUnsuppressedChunkInCurrentLesson());
      }
      if (isCurrentLessonAlphaReviewVersion()) {
         _isLessonPlaying = false;
         _isLessonPaused = false;
      } else {
         if ((_isLessonPlaying) && (!_isLessonPaused)) {
            if (isUserInitiated) {
               _audioTimer.requestAudioPlayPermission();
            } else {
               Log.debug("CurrentLessons.iterateLessonVersion(): Not user initiated, calling AudioController.playCurrentLessonVersionAndCurrentChunk()");
               _audioController.playCurrentLessonVersionAndCurrentChunk();
            }
         }
      }
   }

   public function pauseCurrentLessonVersionIfPlaying():void {
      Log.debug(["CurrentLessons.pauseCurrentLessonVersionIfPlaying()", currentLessonVO]);
      _audioTimer.cancelAllAudioPlayPermissionRequests();
      if (_isLessonPlaying) {
         _audioController.pausePlayingAudioIfAny();
         _isLessonPaused = true;
      }
   }

   public function playCurrentLessonVersionAndCurrentChunk(checkSilenceSwitch:Boolean = false):void {
      Log.debug("CurrentLessons.playCurrentLessonVersionAndCurrentChunk()");
      if (!currentLessonVO) {
         Log.warn("CurrentLessons.playCurrentLessonVersionAndCurrentChunk(): currentLessons.currentLesson is null.");
         return;
      }
      Utils_ANEs.activateSilenceSwitchMonitor(onSilenceSwitchActivatedCallback);   // We do this here because it wasn't working to do it in initSingleton()
      if (checkSilenceSwitch && Utils_ANEs.isSilenceSwitchMuted()) {
         displaySilenceSwitchWarningAlert("This alert triggered in playCurrentLessonVersionAndCurrentChunk()");
         return;
      }
      _isLessonPaused = false;
      Log.info("CurrentLessons.playCurrentLessonVersionAndCurrentChunk(): setting _isLessonPlaying = true");
      _isLessonPlaying = true;
      _audioTimer.requestAudioPlayPermission();
   }

   public function remove(vo:LessonVersionVO, suppressLengthChangeEvent:Boolean = false, suppressPersistingData:Boolean = false):void {
      Log.debug(["CurrentLessons.remove()", vo]);
      if (!vo) {
         Log.warn("CurrentLessons.remove(): passed vo arg is null");
         return;
      }
      if (!contains(vo)) {
         Log.warn("CurrentLessons.remove(): passed vo isn't currently selected: " + vo.publishedLessonVersionId);
         return;
      }
      var originalLessonIndex:int = getLessonIndex(vo);
      _currentLessons.removeItemAt(originalLessonIndex);
      var chunkList:Array = _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO[vo];
      Utils_ArrayVectorEtc.removePropsFromDictionary(chunkList, _index_LessonVersionVOs_by_ChunkVO);
      if (chunkList is Array)
         Utils_Dispose.disposeArray(chunkList, true);
      delete _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO[vo];
      delete _index_ChunkFileLists_by_LessonVersionVO[vo];
      ensureStateIntegrity(vo); // Handles setting new lesson index & chunk index, if needed
      if (!suppressPersistingData)
         persistSelectedLessonVersionData();
      if (!suppressLengthChangeEvent)
         dispatchEvent(new Event("lengthChange"));
   }

   public function removeAll(suppressChangeEvents:Boolean = false, suppressPersistingData:Boolean = false):void {
      Log.debug(["CurrentLessons.removeAll()"]);
      var isLengthChange:Boolean = (length > 0);
      _currentLessons.removeAll();
      Utils_Dispose.disposeDictionary(_index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO, false);
      Utils_Dispose.disposeDictionary(_index_LessonVersionVOs_by_ChunkVO, false);
      Utils_Dispose.disposeDictionary(_index_ChunkFileLists_by_LessonVersionVO, false);
      setCurrentLessonAndChunkIndexes(-1, -1, suppressPersistingData, suppressChangeEvents);
      if (isLengthChange && !suppressPersistingData)
         persistSelectedLessonVersionData();
      if ((isLengthChange) && (!suppressChangeEvents))
         dispatchEvent(new Event("lengthChange"));
   }

   public function setCurrentLesson(vo:LessonVersionVO):void {
      var lessonIndex:int = getLessonIndex(vo);
      if (lessonIndex == -1) {
         Log.debug("CurrentLessons.setCurrentLesson() - Lesson is not currently selected: " + vo.publishedLessonVersionId);
      }
      else {
         setCurrentLessonAndChunkIndexes(getLessonIndex(vo), getIndexForEarliestUnsuppressedChunkInLesson(vo));
      }
   }

   public function setCurrentLessonAndChunkIndexes(newLessonIndex:int, newChunkIndex:int, suppressPersistingData:Boolean = false, suppressChangeEvents:Boolean = false):void {
      Log.debug("CurrentLessons.setCurrentLessonAndChunkIndexes(): lessonIndex=" + newLessonIndex + " chunkIndex=" + newChunkIndex);
      if (!areNewCurrentLessonAndChunkIndexesAllowed(newLessonIndex, newChunkIndex)) {
         Log.error("CurrentLessons.setCurrentLessonAndChunkIndexes(): New values aren't allowed - areNewCurrentLessonAndChunkIndexesAllowed() should be checked before calling this method.");
         if (Utils_System.isInDebugMode()) {
            // For debugging
            var proposedLessonVO:LessonVersionVO = SortableLessonVersionInfo(_currentLessons[newLessonIndex]).lessonVersionVO;
            var proposedLessonChunkVOList:Array = _model.getChunkVOsSortedByLocationInOrderFromLessonVersionVO(proposedLessonVO);
            if (proposedLessonChunkVOList.length > (newChunkIndex + 1))
               var proposedChunkVO:ChunkVO = proposedLessonChunkVOList[newChunkIndex];
            // Step into this and see what caused false to be returned...
            areNewCurrentLessonAndChunkIndexesAllowed(newLessonIndex, newChunkIndex);
         }
         if (isAnySelectedLessonVersionsHaveUnsuppressedChunks()) {
            newLessonIndex = getIndexForFirstSelectedLessonVersionWithUnsuppressedChunks();
            newChunkIndex = getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(getLessonByIndex(newLessonIndex), 0, 1);
         } else {
            Log.error("CurrentLessons.setCurrentLessonAndChunkIndexes(): No selected lesson have unsuppressed chunks - setting indexes to -1");
            newLessonIndex = -1;
            newChunkIndex = -1;
         }
      }
      var isEitherValueChanged:Boolean = false;
      if (newLessonIndex != _currentLessonIndex_OnlySetViaSetCurrentLessonAndChunkIndexes) {
         isEitherValueChanged = true;
         _currentLessonIndex_OnlySetViaSetCurrentLessonAndChunkIndexes = newLessonIndex;
         if (!suppressPersistingData) {
            _appStatePersistenceManager.persistCurrLessonVersion(currentLessonVO);
            _appStatePersistenceManager.iterateLessonVersionEntryCount();
         }
      }
      if (newChunkIndex != _currentChunkIndex_OnlySetViaSetCurrentLessonAndChunkIndexes) {
         isEitherValueChanged = true;
         _currentChunkIndex_OnlySetViaSetCurrentLessonAndChunkIndexes = newChunkIndex;
         if (!suppressPersistingData)
            _appStatePersistenceManager.persistCurrChunkIndex(newChunkIndex);
      }
      if (isEitherValueChanged) {
         var newChunkVO:ChunkVO = null;
         if (newChunkIndex >= 0)
            newChunkVO = currentLessonChunks_SortedByLocationInOrder[newChunkIndex];
         _currentChunkVO_OnlySetViaSetCurrentLessonAndChunkIndexes = newChunkVO;
         if (!suppressChangeEvents)
            dispatchEvent(new Event("currentChunkVOChange"));
      }
   }

   public function setCurrentLessonAndChunkIndexesToFirstPlayableLessonAndChunk(suppressPersistingData:Boolean = false):void {
      Log.debug(["CurrentLessons.setCurrentLessonAndChunkIndexesToFirstPlayableLessonAndChunk()"]);
      if (isAnySelectedLessonVersionsHaveUnsuppressedChunks()) {
         var newLessonIndex:int = getIndexForFirstSelectedLessonVersionWithUnsuppressedChunks();
         var newChunkIndex:int = getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(getLessonByIndex(newLessonIndex), 0, 1);
         setCurrentLessonAndChunkIndexes(newLessonIndex, newChunkIndex, suppressPersistingData);
      } else {
         setCurrentLessonAndChunkIndexes(-1, -1);
      }
   }

   public function setSleepTimer(minutes:int):void {
      if (_sleepTimer) {
         _sleepTimer.stop();
         _sleepTimer.removeEventListener(TimerEvent.TIMER, onSleepTimer);
         _sleepTimer = null;
      }
      var milliseconds:int = minutes * 60000;
      _sleepTimer = new Timer(milliseconds);
      _sleepTimer.addEventListener(TimerEvent.TIMER, onSleepTimer);
      _sleepTimer.start();
      dispatchEvent(new Event("sleepTimerActiveChange"));
   }

   public function stopPlayingCurrentLessonVersionIfPlaying():void {
      Log.debug(["CurrentLessons.stopPlayingCurrentLessonVersionIfPlaying()"]);
      _audioTimer.cancelAllAudioPlayPermissionRequests();
      if (_isLessonPlaying) {
         _audioController.reset();
      }
      _isLessonPlaying = false;
      _isLessonPaused = false;
   }

   public function togglePlayPause():void {
      Log.debug(["CurrentLessons.togglePlayPause()"]);
      if (_isLessonPlaying) {
         _isLessonPaused = !_isLessonPaused;
      } else {
         _isLessonPlaying = true;
         _isLessonPaused = false;
      }
      if (_isLessonPaused) {
         AudioPlayer.getInstance().stop();
         pauseCurrentLessonVersionIfPlaying();
      } else {
         playCurrentLessonVersionAndCurrentChunk(true);
      }
   }

   public function unsuppressAllChunksForVO(lvvo:LessonVersionVO):void {
      var chunkVOList:Array = (Utils_ArrayVectorEtc.useVoEqualsFunctionToGetItemFromDictionary(lvvo, _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO, true) as Array);
      for each (var cvo:ChunkVO in chunkVOList) {
         cvo.suppressed = false;
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function createSortableLessonVersionInfoInstanceBasedOnLessonVersionVO(vo:LessonVersionVO):SortableLessonVersionInfo {
      var sortString:String = _model.getLessonVersionNativeLanguageSortableNameFromLessonVersionVO(vo);
      var info:SortableLessonVersionInfo = new SortableLessonVersionInfo(vo, sortString);
      return info;
   }

   private function displaySilenceSwitchWarningAlert(debugInfo:String):void {
      var alertText:String = Constant_MentorTypeSpecific.APP_NAME__SHORT + " won't play audio through the speaker when the mute switch is turned on.\n\nHeadphones, however, will work.";
      if (Utils_System.isAlphaOrBetaVersion()) {
         alertText += " - " + debugInfo;
      }
      Utils_ANEs.showAlert_OkayButton(alertText, onSilenceSwitchWarningAlertCallback);
   }

   private function doesUnsuppressedChunkExistAtOrAfterChunk(lvvo:LessonVersionVO, chunkIndex:int):Boolean {
      var index:int = getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(lvvo, chunkIndex, 1);
      return (index != -1);
   }

   private function doesUnsuppressedChunkExistBeforeOrAfterChunk(lvvo:LessonVersionVO, chunkIndex:int, direction:int):Boolean {
      Log.debug("CurrentLessons.doesUnsuppressedChunkExistBeforeOrAfterChunk(): lesson ID: " + lvvo.publishedLessonVersionId + "; chunkIndex: " + chunkIndex + "; direction: " + direction);
      if ((direction == 1) && (chunkIndex >= (getChunkCountForLessonVersionVO(lvvo) - 1)))
         return false;
      if ((direction == -1) && (chunkIndex <= 0))
         return false;
      var index:int = getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(lvvo, chunkIndex + direction, direction);
      return (index != -1);
   }

   private function getChunkCountForLessonVersionVO(lvvo:LessonVersionVO):int {
      var list:Array = (Utils_ArrayVectorEtc.useVoEqualsFunctionToGetItemFromDictionary(lvvo, _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO, true) as Array);
      if (!(list is Array)) {
         Log.error(["CurrentLessons.getChunkCountForLessonVersionVO(): _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO doesn't contain VO as key value", lvvo, _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO]);
         return -1;
      }
      return list.length;
   }

   private function getIndexForNextOrPreviousSelectedLessonVersionWithUnsuppressedChunks(direction:int):uint {
      if (!((direction == -1) || (direction == 1)))
         Log.fatal("CurrentLessons.getIndexForNextOrPreviousSelectedLessonVersion(): direction arg must be -1 or 1");
      if (getCountOfCurrentSelectedLessonVersionsWithUnsuppressedChunks() == 0)
         Log.fatal("CurrentLessons.getIndexForNextOrPreviousSelectedLessonVersion(): zero selected lessons with unsuppressed chunks");
      if (currentLessonIndex == -1)
         Log.fatal("CurrentLessons.getIndexForNextOrPreviousSelectedLessonVersion(): no current lesson version");
      var result:uint;
      var lvCount:uint = length;
      var originalIndex:int = currentLessonIndex;
      var candidateIndex:int = currentLessonIndex;
      while (true) {
         candidateIndex = getIndexForNextOrPreviousSelectedLessonVersion(candidateIndex, direction);
         var vo:LessonVersionVO = getLessonByIndex(candidateIndex);
         if (doesLessonVersionContainAnyUnsuppressedChunks(vo)) {
            result = candidateIndex;
            break;
         }
         if (candidateIndex == originalIndex) {
            Log.fatal("CurrentLessons.getIndexForNextOrPreviousSelectedLessonVersion(): all selected lesson versions have been checked and none meet criteria");
         }
      }
      return result;
   }

   private function getIndexForNextLessonInSortedLessonInfoList(list:ArrayCollection, currentIndex:uint):int {
      var result:int = -1;
      if (currentIndex == (list.length - 1))
         result = 0;
      else
         result = currentIndex + 1;
      /*if (currentIndex != (list.length - 1))
       {
       for (var index:int = currentIndex + 1; index < list.length; index++)
       {
       var lvvo:LessonVersionVO = SortableLessonVersionInfo(list[index]).lessonVersionVO;
       if (doesLessonVersionContainAnyUnsuppressedChunks(lvvo))
       {
       result = index;
       break;
       }
       }
       }
       if (result == -1)
       {
       for (index = 0; index < currentIndex; index++)
       {
       lvvo = SortableLessonVersionInfo(list[index]).lessonVersionVO;
       if (doesLessonVersionContainAnyUnsuppressedChunks(lvvo))
       {
       result = index;
       break;
       }
       }
       }*/
      return result;
   }

   private function getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(lvvo:LessonVersionVO, chunkIndex:int, direction:int):int {
      Log.debug("CurrentLessons.getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(): lesson ID: " + lvvo.publishedLessonVersionId + "; chunkIndex: " + chunkIndex + "; direction: " + direction);
      var result:int;
      var chunkVOListForLV:Array = (Utils_ArrayVectorEtc.useVoEqualsFunctionToGetItemFromDictionary(lvvo, _index_ChunkListsSortedByLocationInOrder_by_LessonVersionVO, true) as Array);
      var finalIndexToCheck:int;
      if (direction == -1) {
         finalIndexToCheck = 0;
      } else {
         finalIndexToCheck = chunkVOListForLV.length - 1;
      }
      var currChunkIndex:uint = chunkIndex;
      while (true) {
         if (currChunkIndex >= chunkVOListForLV.length) {
            Log.warn("CurrentLessons.getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(): currChunkIndex >= chunkVOListForLV.length");
         }
         var isChunkSuppressed:Boolean = ChunkVO(chunkVOListForLV[currChunkIndex]).suppressed;
         if (!isChunkSuppressed) {
            result = currChunkIndex;
            break;
         }
         if (currChunkIndex == finalIndexToCheck) {
            result = -1;
            break;
         }
         currChunkIndex += direction;
      }
      Log.debug("CurrentLessons.getIndexForNextUnsuppressedChunkAtOrBeforeOrAfterChunkIndex(): returning result of: " + result);
      return result;
   }

   private function onAudioPlayAllowed(event:Event_CurrentLessonsAudioTimer):void {
      Log.debug("CurrentLessons.onAudioPlayAllowed()  *******************************************");
      // Things may have changed since requests were made to CurrentLessonsAudioTimer, so let's check a few things...
      if (!currentLessonVO)
         return;
      if (!isLessonPlaying)
         return;
      if (isLessonPaused)
         return;
      Log.debug("CurrentLessons.onAudioPlayAllowed(): calling AudioController.playCurrentLessonVersionAndCurrentChunk()");
      _audioController.playCurrentLessonVersionAndCurrentChunk();
   }

   private function onSilenceSwitchActivatedCallback(muted:Boolean):void {
      if (muted && (isLessonPlaying) && (!_isLessonPaused)) {
         displaySilenceSwitchWarningAlert("This alert triggered in onSilenceSwitchActivatedCallback()");
      }
   }

   private function onSilenceSwitchWarningAlertCallback():void {
      playCurrentLessonVersionAndCurrentChunk(false);
   }

   private function onSleepTimer(event:TimerEvent):void {
      if (_sleepTimer) {
         _sleepTimer.stop();
         _sleepTimer.removeEventListener(TimerEvent.TIMER, onSleepTimer);
         _sleepTimer = null;
      }
      if (isLessonPlaying) {
         stopPlayingCurrentLessonVersionIfPlaying();
         dispatchEvent(new Event("sleepTimerActiveChange"));
         var activity:UserAction = new UserAction();
         Utils_Audio_Files.playGongSound();
      }
      activity.actionType = Constant_UserActionTypes.SLEEP_TIMER__FINISH;
      UserActionReportingManager.reportActivityIfUserHasActivatedReporting(activity);
   }

   private function onUserStartedAudio(e:Event_Audio):void {
      playCurrentLessonVersionAndCurrentChunk(true);
   }

   private function onUserStoppedAudio(e:Event_Audio):void {
      stopPlayingCurrentLessonVersionIfPlaying();
   }

   private function persistSelectedLessonVersionData():void {
      if (!_appStatePersistenceManager.isEnabled())
         return;
      var selectedLessonVersionVOsVector:Vector.<LessonVersionVO> = new Vector.<LessonVersionVO>();
      for each (var lvvo:LessonVersionVO in currentLessons) {
         selectedLessonVersionVOsVector.push(lvvo);
      }
      _appStatePersistenceManager.persistSelectedLessonVersions(selectedLessonVersionVOsVector);
   }

   private function reportToAnalytics_LessonFinished():void {
      Log.info("CurrentLessons.reportToAnalytics_LessonFinished()");
      if ((!currentLessonVersionLessonId) || (!currentLessonVersionLessonName_NativeLanguage) || (!currentLessonVersionProviderId) || (!currentLessonVersionVersion)) {
         return;
      }
      Utils_GoogleAnalytics.trackLessonFinished(currentLessonVersionLessonName_NativeLanguage, currentLessonVersionLessonId, currentLessonVersionVersion, currentLessonVersionProviderId);
   }

   private function reportUserActivity_AutoPlay_AdvanceChunk(advancedFromChunkIndex:int, newLessonVO:LessonVersionVO = null):void {
      Log.info("CurrentLessons.reportUserActivity_AutoPlay_AdvanceLesson()");
      if ((!currentLessonVersionLessonId) || (!currentLessonVersionLessonName_NativeLanguage) || (!currentLessonVersionProviderId) || (!currentLessonVersionVersion) || (!_model.getCurrentLearningModeDisplayName())) {
         return;
      }
      var activity:UserAction = new UserAction();
      activity.actionType = Constant_UserActionTypes.AUTO_PLAY__ADVANCE_CHUNK;
      activity.autoPlay_AutoAdvanceLesson = (newLessonVO is LessonVersionVO);
      activity.chunkIndex_Previous = advancedFromChunkIndex;
      activity.learningModeDisplayName = _model.getCurrentLearningModeDisplayName();
      activity.lessonId = currentLessonVersionLessonId;
      activity.lessonName_NativeLanguage = currentLessonVersionLessonName_NativeLanguage;
      activity.lessonProviderId = currentLessonVersionProviderId;
      activity.lessonVersion = currentLessonVersionVersion;
      if (newLessonVO) {
         activity.lessonId_New = newLessonVO.publishedLessonVersionId;
         activity.lessonName_NativeLanguage_New = _model.getLessonVersionNativeLanguageNameFromLessonVersionVO(newLessonVO);
         activity.lessonProviderId_New = newLessonVO.contentProviderId;
         activity.lessonVersion_New = newLessonVO.publishedLessonVersionVersion;
      }
      UserActionReportingManager.reportActivityIfUserHasActivatedReporting(activity);
   }

   private function sortArrayCollectionOfSortableLessonVersionInfoInstances(ac:ArrayCollection):void {
      var sort:Sort = new Sort();
      sort.fields = [];
      sort.fields.push(new SortField("sortString"));
      ac.sort = sort;
      ac.refresh();

   }

}
}


import com.langcollab.languagementor.vo.LessonVersionVO;

class SortableLessonVersionInfo extends LessonVersionVO {
   private var _lessonVersionVO:LessonVersionVO;

   public function get lessonVersionVO():LessonVersionVO {
      return _lessonVersionVO;
   }

   private var _sortString:String;

   public function get sortString():String {
      return _sortString;
   }

   public function SortableLessonVersionInfo(lessonVersionVO:LessonVersionVO, sortString:String) {
      _lessonVersionVO = lessonVersionVO;
      _sortString = sortString;
   }

}

