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


    Class Responsibilities:
        - Playing audio - specifically the current selected lesson version and its current selected chunk
        - When a chunk and/or a lesson version ends, changing the current selected lesson version and/or chunk
        - If asked to play a lessonVersion whose files are not downloaded, asks for download and/or informs user

*/
package com.langcollab.languagementor.controller.audio {
import com.brightworks.component.mobilealert.MobileAlert;
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_DateTime;
import com.brightworks.util.Utils_System;
import com.brightworks.util.singleton.SingletonManager;
import com.brightworks.vo.IVO;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.constant.Constant_LearningModeLabels;
import com.langcollab.languagementor.event.Event_AudioProgress;
import com.langcollab.languagementor.model.MainModel;
import com.langcollab.languagementor.model.currentlessons.CurrentLessons;
import com.langcollab.languagementor.util.Utils_LangCollab;
import com.langcollab.languagementor.vo.ChunkFileVO;
import com.langcollab.languagementor.vo.ChunkVO;
import com.langcollab.languagementor.vo.LessonVersionVO;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.utils.Dictionary;
import flash.utils.Timer;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;

public class AudioController extends EventDispatcher implements IManagedSingleton {
   public static const AUDIO_SEQUENCE_LEVEL__CHUNK:String = "audioSequenceLevel_Chunk";
   public static const AUDIO_SEQUENCE_LEVEL__LEAF:String = "audioSequenceLevel_Leaf";
   public static const AUDIO_SEQUENCE_LEVEL__LESSON:String = "audioSequenceLevel_Lesson";

   private static var _audioController:AudioController;
   private static var _instance:AudioController;

   private var _chunksPlayedInCurrentLessonVersionAudioSequence:uint = 0;
   private var _chunkStartTimesList:Array = [];
   private var _currentAudioSequenceLeaf:AudioSequenceLeaf;
   private var _currentLessons:CurrentLessons;
   private var _currentLessonVersionAudioSequence:AudioSequenceBranch;
   private var _currentPrimaryChunkSequenceStrategy:ISequenceStrategy;
   private var _isTempChunkSequenceStrategyActive:Boolean = false;
   private var _model:MainModel;
   private var _tempChunkSequenceStrategyRemainingChunks:int;
   private var _timer_LeafFinishChecker:Timer;
   private var _timer_StartLesson:Timer;
   private var _watcher_CurrentLearningModeID:ChangeWatcher;

   // ****************************************************
   //
   //          Getters / Setters
   //
   // ****************************************************

   private var _currentLeafType:String;

   public function get currentLeafType():String {
      return _currentLeafType;
   }

   private var _isLoopingChunk:Boolean = false;

   public function get isLoopingChunk():Boolean {
      return _isLoopingChunk;
   }

   private var _isRecordMode:Boolean = false;

   [Bindable(event="isRecordModeChange")]
   public function get isRecordMode():Boolean {
      return _isRecordMode;
   }

   private var _mostRecentAutoChunkFinishInitiatedIterateChunk:Number;

   public function get mostRecentAutoChunkFinishInitiatedIterateChunk():Number {
      return _mostRecentAutoChunkFinishInitiatedIterateChunk;
   }

   private var _mostRecentLeafElementStartTime:Date;

   [Bindable(event="mostRecentLeafElementStartTimeChange")]
   public function get mostRecentLeafElementStartTime():Date {
      return _mostRecentLeafElementStartTime;
   }

   private function setIsRecordMode(value:Boolean):void {
      if (value == _isRecordMode)
         return;
      _isRecordMode = value;
      dispatchEvent(new Event("isRecordModeChange"));
   }

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function AudioController(manager:SingletonManager) {
      _instance = this;
      addEventListener(Event.ACTIVATE, onActivate);
      addEventListener(Event.DEACTIVATE, onDeactivate);
   }

   public function decrementTempChunkSequenceStrategyAndClearIfAppropriate():void {
      Log.info("AudioController.decrementTempChunkSequenceStrategyAndClearIfAppropriate(): _isTempChunkSequenceStrategyActive = " + _isTempChunkSequenceStrategyActive);
      if (_isTempChunkSequenceStrategyActive) {
         _tempChunkSequenceStrategyRemainingChunks--;
         if (_tempChunkSequenceStrategyRemainingChunks == 0)
            clearTempChunkSequenceStrategy();
      }
   }

   public function doPost_IKnowThis_ChangedLessonVersionStuff():void {
      Log.info(["AudioController.doPost_IKnowThis_ChangedLessonVersionStuff()"]);
      cleanupCurrentLessonVersion();
      /// play a happy tone
      /// if no LVs remain in currentLessons, play an even happier tone
   }

   public static function getInstance():AudioController {
      if (!(_instance))
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function initSingleton():void {
      _currentLessons = CurrentLessons.getInstance();
      _model = MainModel.getInstance();
      _watcher_CurrentLearningModeID = BindingUtils.bindSetter(onCurrentLearningModeIDChange, _model, "currentLearningModeId");
   }

   public function onLearningModeIdChange():void {
      Log.info(["AudioController.onLearningModeIdChange()", _model.currentLearningModeId]);
      if (_currentLessons.isLessonPlaying) {
         stopLeafFinishCheckProcess();
         updateCurrentLessonVersionAudioSequenceSequenceStrategies(true);
      }
   }

   public function onStartLoopMode():void {
      Log.info("AudioController.onStartLoopMode()");
      _isLoopingChunk = true;
   }

   public function onStartRecordMode():void {
      Log.info("AudioController.onStartRecordMode()");
      setIsRecordMode(true);
      if ((_currentLessonVersionAudioSequence) && (_currentPrimaryChunkSequenceStrategy)) {
         stopLeafFinishCheckProcess();
         switchToRecordModeStrategy();
      }
   }

   public function onStopLoopMode():void {
      Log.info("AudioController.onStopLoopMode()");
      _isLoopingChunk = false;
   }

   public function onStopRecordMode():void {
      Log.info("AudioController.onStopRecordMode()");
      setIsRecordMode(false);
      if (_currentLessons.isCurrentLessonAlphaReviewVersion())
         return;
      if (_currentLessonVersionAudioSequence) {
         stopLeafFinishCheckProcess();
         _currentLessonVersionAudioSequence.setSequenceStrategy(_currentPrimaryChunkSequenceStrategy, AUDIO_SEQUENCE_LEVEL__CHUNK);
      }
   }

   public function onTranslate():void {
      Log.info(["AudioController.onTranslate()"]);
      if (!_currentLessonVersionAudioSequence)
         return;
      if (_currentLessons.isCurrentLessonAlphaReviewVersion())
         return;
      stopLeafFinishCheckProcess();
      var strat:SequenceStrategy_Translate = new SequenceStrategy_Translate();
      setTempChangeChunkSequenceStrategyForNChunks(strat);
   }

   public function pausePlayingAudioIfAny():void {
      Log.info(["AudioController.pausePlayingAudioIfAny()"]);
      clearTimer_StartLesson();
      stopLeafFinishCheckProcess();
      if (_currentLessonVersionAudioSequence)
         _currentLessonVersionAudioSequence.pause(AUDIO_SEQUENCE_LEVEL__CHUNK);
   }

   // This method is intended to resume at the specified resumeLevel if that is
   // possible, but it's only possible if:
   //    a) we were previously playing, and
   //    b) currLV and currChunk are the same as what was previously playing.
   // The default behaviors built into AudioSequenceBranch.startFromCurrentElement()
   // should make this fairly simple...   :)
   //
   // If the currLV hasn't changed we use the existing _currentLessonVersionAudioSequence
   // instance, if it has we recreate it.
   public function playCurrentLessonVersionAndCurrentChunk():void {
      Log.info("AudioController.playCurrentLessonVersionAndCurrentChunk()");
      clearTimer_StartLesson();
      stopLeafFinishCheckProcess();
      var isSameLesson:Boolean = false;
      var isSameChunk:Boolean = false;
      if (_currentLessonVersionAudioSequence) {
         var currPlayingLessonVO:IVO = _currentLessonVersionAudioSequence.getCurrentVOForLevel(AUDIO_SEQUENCE_LEVEL__LESSON);
         var currPlayingChunkVO:IVO = _currentLessonVersionAudioSequence.getCurrentVOForLevel(AUDIO_SEQUENCE_LEVEL__CHUNK);
         isSameLesson = (currPlayingLessonVO.equals(_currentLessons.currentLessonVO));
         isSameChunk = (currPlayingChunkVO.equals(_currentLessons.currentChunkVO));
      }
      var sequenceCreationStepNeeded:Boolean = false;
      if ((!(_currentLessonVersionAudioSequence)) || (!isSameLesson))
         sequenceCreationStepNeeded = true;
      if (sequenceCreationStepNeeded) {
         Log.info("AudioController.playCurrentLessonVersionAndCurrentChunk(): sequenceCreationStepNeeded == true, setting timer to call playCurrentLessonVersionAndCurrentChunk_CreateCurrentLessonVersionAudioSequence()");
         cleanupCurrentLessonVersion();
         MobileAlert.open("Loading Lesson", true);
         _timer_StartLesson = new Timer(250, 1);
         _timer_StartLesson.addEventListener(TimerEvent.TIMER, playCurrentLessonVersionAndCurrentChunk_CreateCurrentLessonVersionAudioSequence);
         _timer_StartLesson.start();
      }
      else {
         Log.info("AudioController.playCurrentLessonVersionAndCurrentChunk(): sequenceCreationStepNeeded == false, calling playCurrentLessonVersionAndCurrentChunk_Finish()");
         updateCurrentLessonVersionAudioSequenceSequenceStrategies(true);
         playCurrentLessonVersionAndCurrentChunk_Finish();
      }
   }

   public function reset():void {
      Log.info("AudioController.reset()");
      stopLeafFinishCheckProcess();
      if (_currentLessonVersionAudioSequence)
         _currentLessonVersionAudioSequence.pause(AUDIO_SEQUENCE_LEVEL__CHUNK);
   }

   public function setTempChangeChunkSequenceStrategyForNChunks(chunkStrategy:ISequenceStrategy):void {
      // dmcarroll 20130605
      // If/when we start passing in 'n' again, search for comments with
      // 'setTempChangeChunkSequenceStrategyForNChunks' in them - some of our code may need to change
      var n:int = 1;
      //
      Log.info("AudioController.setTempChangeChunkSequenceStrategyForNChunks(): chunkStrategy = " + chunkStrategy + "; n = " + n);
      stopLeafFinishCheckProcess();
      if (!_currentLessons.isLessonPlaying) {
         Log.fatal("AudioController.setTempChangeChunkSequenceStrategyForNChunks(): Called when audio not playing"); // When/why would this ever happen?
         return;
      }
      _isTempChunkSequenceStrategyActive = true;
      _tempChunkSequenceStrategyRemainingChunks = n;
      if (!_currentLessons.isLessonPaused) {
         if (_currentLessonVersionAudioSequence) {
            _currentLessonVersionAudioSequence.pause(AUDIO_SEQUENCE_LEVEL__CHUNK);
         }
         else {
            Log.fatal("AudioController.setTempChangeChunkSequenceStrategyForNChunks(): Lesson is playing, but _currentLessonVersionAudioSequence is null");
            return;
         }
      }
      _currentLessonVersionAudioSequence.setSequenceStrategy(chunkStrategy, AUDIO_SEQUENCE_LEVEL__CHUNK)
      if (!_currentLessons.isLessonPaused)
         _currentLessonVersionAudioSequence.resume(AUDIO_SEQUENCE_LEVEL__CHUNK);
   }

   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************

   private function cleanupCurrentLessonVersion():void {
      Log.info(["AudioController.cleanupCurrentLessonVersion()", _currentLessons.currentLessonVO]);
      clearTimer_StartLesson();
      stopLeafFinishCheckProcess();
      if (_currentLessonVersionAudioSequence) {
         _currentLessonVersionAudioSequence.stop();
         _currentLessonVersionAudioSequence.dispose();
         _currentLessonVersionAudioSequence = null;
      }
      clearTempChunkSequenceStrategy();
   }

   private function clearTempChunkSequenceStrategy():void {
      Log.info("AudioController.clearTempChunkSequenceStrategy(): _isTempChunkSequenceStrategyActive = " + _isTempChunkSequenceStrategyActive);
      if (_isTempChunkSequenceStrategyActive) {
         _isTempChunkSequenceStrategyActive = false;
         _tempChunkSequenceStrategyRemainingChunks = 0;
         if (_currentLessonVersionAudioSequence) {
            stopLeafFinishCheckProcess();
            _currentLessonVersionAudioSequence.setSequenceStrategy(_currentPrimaryChunkSequenceStrategy, AUDIO_SEQUENCE_LEVEL__CHUNK);
         }
      }
   }

   private function clearTimer_StartLesson():void {
      if (_timer_StartLesson) {
         _timer_StartLesson.stop();
         _timer_StartLesson.removeEventListener(TimerEvent.TIMER, playCurrentLessonVersionAndCurrentChunk_CreateCurrentLessonVersionAudioSequence);
         _timer_StartLesson = null;
      }
   }

   private function createIndex_NativeLanguageFileDuration_by_ChunkVO_ForCurrentLessonVersion():Dictionary {
      var result:Dictionary = new Dictionary();
      var index_ChunkVOs_by_LocationInOrder:Dictionary = new Dictionary();
      for each (var chunkVO:ChunkVO in _currentLessons.currentLessonChunks_SortedByLocationInOrder) {
         index_ChunkVOs_by_LocationInOrder[chunkVO.locationInOrder] = chunkVO;
      }
      var chunkFileVOList_ForLessonVersion:Array = _currentLessons.currentLessonChunkFiles;
      var chunkFileVOList_ForChunk:Array;
      var matchingChunkVO:ChunkVO;
      for each (var chunkFileVO:ChunkFileVO in chunkFileVOList_ForLessonVersion) {
         if (chunkFileVO.iso639_3Code == _model.getNativeLanguageIso639_3Code()) {
            matchingChunkVO = index_ChunkVOs_by_LocationInOrder[chunkFileVO.chunkLocationInOrder];
            result[matchingChunkVO] = chunkFileVO.duration;
         }
      }
      return result;
   }

   private function createIndex_TargetLanguageFileDuration_by_ChunkVO_ForCurrentLessonVersion():Dictionary {
      var result:Dictionary = new Dictionary();
      var index_ChunkVOs_by_LocationInOrder:Dictionary = new Dictionary();
      for each (var chunkVO:ChunkVO in _currentLessons.currentLessonChunks_SortedByLocationInOrder) {
         index_ChunkVOs_by_LocationInOrder[chunkVO.locationInOrder] = chunkVO;
      }
      var chunkFileVOList_ForLessonVersion:Array = _currentLessons.currentLessonChunkFiles;
      var chunkFileVOList_ForChunk:Array;
      var matchingChunkVO:ChunkVO;
      for each (var chunkFileVO:ChunkFileVO in chunkFileVOList_ForLessonVersion) {
         if (chunkFileVO.iso639_3Code == _model.getTargetLanguageIso639_3Code()) {
            matchingChunkVO = index_ChunkVOs_by_LocationInOrder[chunkFileVO.chunkLocationInOrder];
            result[matchingChunkVO] = chunkFileVO.duration;
         }
      }
      return result;
   }

   private function getInitialPauseLeafDuration():Number {
      var standardDuration:Number = 500;
      var result:Number = 500;
      if ((Utils_System.isIPadOrPreGeneration5IPhoneOrIPod) &&
            (AudioRecorder.getInstance().isMicrophoneUsedInSession)) {
         if (_currentLessons.currentChunkIndex == _currentLessons.getIndexForEarliestUnsuppressedChunkInCurrentLesson())
            result = 6000;
         else if (_chunksPlayedInCurrentLessonVersionAudioSequence == 1)
            result = 3000;
         else
            result = 1000;
      }
      Log.info("AudioController.getInitialPauseLeafDuration(): returning " + result);
      return result;
   }

   private function onActivate(event:Event):void {
      stopLeafFinishCheckProcess();
   }

   private function onCurrentLearningModeIDChange(newID:int):void {
      Log.info(["AudioController.onCurrentLearningModeIDChange()", newID]);
      if (!_model.isDataInitialized)
         return;
      if (newID == 0)
         return; // This happens if user selects "clear all data" option - app is about to close
      if (_model.getLearningModeTokenFromID(newID) == Constant_LearningModeLabels.LISTEN_TO_TARGET)
         setIsRecordMode(false);
   }

   private function onDeactivate(event:Event):void {
      stopLeafFinishCheckProcess();
   }

   private function onElementComplete(event:Event_AudioProgress):void {
      Log.info(["AudioController.onElementComplete()", "Element:", event.target]);
      // trace("onElementComplete(): " + event.levelId + " " + event.id);
      stopLeafFinishCheckProcess();
      switch (event.levelId) {
         case AUDIO_SEQUENCE_LEVEL__LEAF:
            break;
         case AUDIO_SEQUENCE_LEVEL__CHUNK: {
            if (_isLoopingChunk) {
               _currentLessonVersionAudioSequence.replayCurrentElement(AUDIO_SEQUENCE_LEVEL__LESSON);
            }
            else {
               _mostRecentAutoChunkFinishInitiatedIterateChunk = Utils_DateTime.getCurrentMS_BasedOnDate();
               _currentLessons.iterateChunk(1, false);
            }
            break;
         }
         case AUDIO_SEQUENCE_LEVEL__LESSON:
            // We don't do much here - the "chunk" case handles changing lessons
            // if the ending chunk is the last chunk.
            break;
         default:
            Log.error("AudioController.onElementComplete(): No match for event.levelId: " + event.levelId);
      }
   }

   private function onElementStart(event:Event_AudioProgress):void {
      Log.info(["AudioController.onElementStart()", "Element:", event.target]);
      // trace("onElementStart(): " + event.levelId + " " + event.id);
      switch (event.levelId) {
         case AUDIO_SEQUENCE_LEVEL__LEAF:
            switch (event.id) {
               case Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_ATTEMPT:
               case Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_REPEAT:
                  _model.mostRecentDownloadProcessStartAllowedEventTime = new Date();
                  break;
               case Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_INITIAL:
                  // We don't set _model.mostRecentDownloadProcessStartAllowedEventTime here because
                  // we don't want download processes to occur during this pause - the process might be a
                  // 'save to DB' process, and saving to the DB right before we play the first audio in a
                  // chunk tends to be problematic, at least on iPhone 4.
                  break;
               case Constant_LangMentor_Misc.LEAF_TYPE__RECORD_ATTEMPT:
               case Constant_LangMentor_Misc.LEAF_TYPE__RECORD_REPEAT:
                  _model.mostRecentDownloadProcessStartAllowedEventTime = new Date();
                  break;
               case Constant_LangMentor_Misc.LEAF_TYPE__AUDIO_NATIVE:
               case Constant_LangMentor_Misc.LEAF_TYPE__AUDIO_TARGET:
               case Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_TINY:
               case Constant_LangMentor_Misc.LEAF_TYPE__PLAYBACK:
               case Constant_LangMentor_Misc.LEAF_TYPE__TEXTONLY_NATIVE:
               case Constant_LangMentor_Misc.LEAF_TYPE__TEXTONLY_TARGET:
                  break;
               default:
                  Log.error("AudioController.onElementStart(): No case for event.id: " + event.id);
            }
            _currentLeafType = String(event.id);
            _mostRecentLeafElementStartTime = new Date();
            dispatchEvent(new Event("mostRecentLeafElementStartTimeChange"));
            startLeafFinishCheckProcess(AudioSequenceLeaf(event.target));
            break;
         case AUDIO_SEQUENCE_LEVEL__CHUNK:
            _chunksPlayedInCurrentLessonVersionAudioSequence++;
            _model.chunksCount_PlayedInSession++;
            _chunkStartTimesList.unshift(Utils_DateTime.getCurrentMS_BasedOnDate());
            break;
         case AUDIO_SEQUENCE_LEVEL__LESSON:
            break;
         default:
            Log.error("AudioController.onElementStart(): No case for event.levelId: " + event.levelId);
      }
   }

   private function onIOErrorReport(event:Event_AudioProgress):void {
      var errorString:String = "AudioController.onIOErrorReport(): levelId:" + event.levelId + " id:" + event.id + " message:" + event.message;
      if (event.target is AudioSequenceLeaf_File)
         errorString += " url:" + AudioSequenceLeaf_File(event.target).url;
      trace("Error: " + errorString);
      Log.fatal(errorString); ///
   }

   private function onTimer_LeafFinishChecker(event:TimerEvent):void {
      // This should never happen if everything is working correctly, and suggests that either a) we've encountered
      // the "audio leaf fails to finish for no apparent reason" bug, or b) there's a problem with this 'check'
      // code that's trying to find the bug. In other words, a bug in the bug hunting code. Let's check
      // for (b) first...
      if (!_currentLessonVersionAudioSequence) {
         Log.warn("AudioController.onTimer_LeafFinishChecker() called, but _currentLessonVersionAudioSequence is null");
         return;
      }
      if (_currentLessonVersionAudioSequence.isPaused) {
         // dmccarroll 20130826
         // Initial testing of this 'check' code shows this condition occurring fairly frequently. This makes no sense, yet it's
         // occurring nonetheless.
         // dmccarroll 20170609
         // This occurs when a) the app is interrupted, e.g. by a phone call, b) control returns to the app (at which point the
         // audio doesn't play, c) the user goes to the phone's home screen, and d) the user returns to this app. But chances
         // are good that I'll have fixed the bug in (b) by the time you read this, so this comment may no longer be true.
         Log.warn("AudioController.onTimer_LeafFinishChecker() called, but _currentLessonVersionAudioSequence.isPaused == true");
         stopLeafFinishCheckProcess();
         return;
      }
      if (!_currentAudioSequenceLeaf) {
         Log.warn("AudioController.onTimer_LeafFinishChecker() called, but _currentAudioSequenceLeaf is null");
         return;
      }
      if (_currentAudioSequenceLeaf.isPaused) {
         Log.warn("AudioController.onTimer_LeafFinishChecker() called, but _currentAudioSequenceLeaf.isPaused == true");
         return;
      }
      if (!_currentLessons) {
         Log.warn("AudioController.onTimer_LeafFinishChecker() called, but _currentLessons is null");
         return;
      }
      if (!_currentLessons.isLessonPlaying) {
         Log.warn("AudioController.onTimer_LeafFinishChecker(): _currentLessons.isLessonPlaying == false");
         return;
      }
      if (_currentLessons.isLessonPaused) {
         Log.warn("AudioController.onTimer_LeafFinishChecker(): _currentLessons.isLessonPaused == true");
         return;
      }
      // All of the above 'if' blocks check for conditions where no leaf should be playing, and all suggest that there's a problem with this 'check' code,
      // rather than the 'leaf fails to finish' bug.
      // Once we get to this point, it seems probable that the problem actually exists in the leaf, i.e. the leaf started and should have completed, but didn't.
      var leaf:AudioSequenceLeaf = _currentAudioSequenceLeaf;
      stopLeafFinishCheckProcess();
      Log.warn("AudioController.onTimer_LeafFinishChecker(): leaf should have finished but didn't. Resuming leaf.");
      _currentLessonVersionAudioSequence.startFromCurrentElement(AUDIO_SEQUENCE_LEVEL__LEAF);
   }

   private function playCurrentLessonVersionAndCurrentChunk_CreateCurrentLessonVersionAudioSequence(event:TimerEvent = null):void {
      Log.info(["AudioController.playCurrentLessonVersionAndCurrentChunk_CreateCurrentLessonVersionAudioSequence()", _currentLessons.currentLessonVO]);
      clearTimer_StartLesson();
      _chunksPlayedInCurrentLessonVersionAudioSequence = 0;
      _currentLessonVersionAudioSequence =
            AudioSequenceBranch.acquireReusable(null, AUDIO_SEQUENCE_LEVEL__LESSON, _currentLessons.currentLessonVO, false);
      _currentLessonVersionAudioSequence.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
      _currentLessonVersionAudioSequence.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
      var index_NativeLanguageFileDuration_by_ChunkVO_ForCurrentLessonVersion:Dictionary = createIndex_NativeLanguageFileDuration_by_ChunkVO_ForCurrentLessonVersion();
      var index_TargetLanguageFileDuration_by_ChunkVO_ForCurrentLessonVersion:Dictionary = createIndex_TargetLanguageFileDuration_by_ChunkVO_ForCurrentLessonVersion();
      var audioVolumeAdjustmentFactor:Number;
      var chunkIndex:int = 0;
      var duration:int;
      var leaf:AudioSequenceLeaf;
      var leafId:Object;
      var url:String;
      for each (var chunkVO:ChunkVO in _currentLessons.currentLessonChunks_SortedByLocationInOrder) {
         var chunkElement:AudioSequenceBranch =
               AudioSequenceBranch.acquireReusable(chunkIndex, AUDIO_SEQUENCE_LEVEL__CHUNK, chunkVO);
         chunkElement.elements = new Dictionary();
         chunkElement.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
         chunkElement.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
         _currentLessonVersionAudioSequence.elements[chunkIndex] = chunkElement;
         if (_currentLessons.isCurrentLessonAlphaReviewVersion()) {
            if (chunkVO.textNativeLanguage) {
               duration = (chunkVO.textNativeLanguage.length * 100) + 3000;
            }
            else {
               Log.error("AudioController.playCurrentLessonVersionAndCurrentChunk_CreateCurrentLessonVersionAudioSequence(): Chunk has no native text in alpha review mode");
               duration = 10000;
            }

            leaf = AudioSequenceLeaf_Silence.acquireReusable(Constant_LangMentor_Misc.LEAF_TYPE__TEXTONLY_NATIVE, duration);
            leaf.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
            leaf.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
            leaf.addEventListener(Event_AudioProgress.IOERROR_REPORT, onIOErrorReport);
            chunkElement.elements[Constant_LangMentor_Misc.LEAF_TYPE__TEXTONLY_NATIVE] = leaf;

            leaf = AudioSequenceLeaf_Silence.acquireReusable(Constant_LangMentor_Misc.LEAF_TYPE__TEXTONLY_TARGET, duration);
            leaf.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
            leaf.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
            leaf.addEventListener(Event_AudioProgress.IOERROR_REPORT, onIOErrorReport);
            chunkElement.elements[Constant_LangMentor_Misc.LEAF_TYPE__TEXTONLY_TARGET] = leaf;

            chunkIndex++;
            continue;
         }
         duration = 500;
         leaf = AudioSequenceLeaf_Silence.acquireReusable(Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_TINY, duration);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
         leaf.addEventListener(Event_AudioProgress.IOERROR_REPORT, onIOErrorReport);
         chunkElement.elements[Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_TINY] = leaf;

         leaf = AudioSequenceLeaf_Silence_Initial.acquireReusable(Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_INITIAL, duration, getInitialPauseLeafDuration);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
         leaf.addEventListener(Event_AudioProgress.IOERROR_REPORT, onIOErrorReport);
         chunkElement.elements[Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_INITIAL] = leaf;


         if (_currentLessons.currentLessonVO.isDualLanguage) {
            duration = index_NativeLanguageFileDuration_by_ChunkVO_ForCurrentLessonVersion[chunkVO];
            audioVolumeAdjustmentFactor = _currentLessons.currentLessonVO.nativeLanguageAudioVolumeAdjustmentFactor;
            url =
                  Utils_LangCollab.downloadedLessonsDirectoryURL +
                  File.separator +
                  _currentLessons.currentLessonVO.contentProviderId +
                  File.separator +
                  _currentLessons.currentLessonVO.publishedLessonVersionId +
                  File.separator +
                  chunkVO.fileNameRoot +
                  "." +
                  _model.getNativeLanguageIso639_3Code() +
                  "." +
                  Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_EXTENSION;
            leaf = AudioSequenceLeaf_File.acquireReusable(Constant_LangMentor_Misc.LEAF_TYPE__AUDIO_NATIVE, url, audioVolumeAdjustmentFactor, duration);
            leaf.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
            leaf.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
            leaf.addEventListener(Event_AudioProgress.IOERROR_REPORT, onIOErrorReport);
            chunkElement.elements[Constant_LangMentor_Misc.LEAF_TYPE__AUDIO_NATIVE] = leaf;
         }

         duration = index_NativeLanguageFileDuration_by_ChunkVO_ForCurrentLessonVersion[chunkVO];
         audioVolumeAdjustmentFactor = _currentLessons.currentLessonVO.targetLanguageAudioVolumeAdjustmentFactor;
         url =
               Utils_LangCollab.downloadedLessonsDirectoryURL +
               File.separator +
               _currentLessons.currentLessonVO.contentProviderId +
               File.separator +
               _currentLessons.currentLessonVO.publishedLessonVersionId +
               File.separator +
               chunkVO.fileNameRoot +
               "." +
               _model.getTargetLanguageIso639_3Code() +
               "." +
               Constant_LangMentor_Misc.FILEPATHINFO__CHUNK_FILE_EXTENSION;
         leaf = AudioSequenceLeaf_File.acquireReusable(Constant_LangMentor_Misc.LEAF_TYPE__AUDIO_TARGET, url, audioVolumeAdjustmentFactor, duration);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
         leaf.addEventListener(Event_AudioProgress.IOERROR_REPORT, onIOErrorReport);
         chunkElement.elements[Constant_LangMentor_Misc.LEAF_TYPE__AUDIO_TARGET] = leaf;

         /// use constants for these values
         duration = (index_TargetLanguageFileDuration_by_ChunkVO_ForCurrentLessonVersion[chunkVO] * 2) + 1200;

         // We could avoid instantiating two out of the next four chunks by combining the 'attempt' and 'repeat' types into one generic
         //   type - as long as all have the same duration this would work fine. For now we're keeping all four so that we can set
         //   different durations for attempt and repeat, if we want.
         leaf = AudioSequenceLeaf_Silence.acquireReusable(Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_ATTEMPT, duration);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
         leaf.addEventListener(Event_AudioProgress.IOERROR_REPORT, onIOErrorReport);
         chunkElement.elements[Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_ATTEMPT] = leaf;

         leaf = AudioSequenceLeaf_Silence.acquireReusable(Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_REPEAT, duration);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
         leaf.addEventListener(Event_AudioProgress.IOERROR_REPORT, onIOErrorReport);
         chunkElement.elements[Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_REPEAT] = leaf;

         // We don't do recording if there's no text displayed, as this probably indicates that we don't have native language audio.
         // This can happen in title chunks, and perhaps in other cases. This is a bit kludgy /// Ideally this would be specified in
         // the XML for the chunk.
         var suppressRecording:Boolean = !_currentLessons.doesChunkHaveDefaultDisplayText(chunkVO);

         // On at least some devices, we need to keep recording longer than the desired recording time in
         // order to actually record for the desired recording time. See AudioRecorder.stopRecording() code.
         var recordingStopDelayDuration:uint = 1000; /// base this on platform & model? this value works for iOS G4 & G5

         var durationNotIncludingRecordingStopDelay:int = duration + AudioRecorder.RECORDING_START_DELAY_DURATION;

         leaf = AudioSequenceLeaf_Recorder.acquireReusable(Constant_LangMentor_Misc.LEAF_TYPE__RECORD_ATTEMPT, duration, recordingStopDelayDuration, suppressRecording);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
         leaf.addEventListener(Event_AudioProgress.IOERROR_REPORT, onIOErrorReport);
         chunkElement.elements[Constant_LangMentor_Misc.LEAF_TYPE__RECORD_ATTEMPT] = leaf;

         leaf = AudioSequenceLeaf_Recorder.acquireReusable(Constant_LangMentor_Misc.LEAF_TYPE__RECORD_REPEAT, duration, recordingStopDelayDuration, suppressRecording);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
         leaf.addEventListener(Event_AudioProgress.IOERROR_REPORT, onIOErrorReport);
         chunkElement.elements[Constant_LangMentor_Misc.LEAF_TYPE__RECORD_REPEAT] = leaf;

         duration = durationNotIncludingRecordingStopDelay + recordingStopDelayDuration;

         leaf = AudioSequenceLeaf_Playback.acquireReusable(Constant_LangMentor_Misc.LEAF_TYPE__PLAYBACK, duration);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, onElementComplete);
         leaf.addEventListener(Event_AudioProgress.ELEMENT_START_REPORT, onElementStart);
         leaf.addEventListener(Event_AudioProgress.IOERROR_REPORT, onIOErrorReport);
         chunkElement.elements[Constant_LangMentor_Misc.LEAF_TYPE__PLAYBACK] = leaf;

         chunkIndex++;
      }
      updateCurrentLessonVersionAudioSequenceSequenceStrategies();
      if (_isRecordMode)
         switchToRecordModeStrategy();
      playCurrentLessonVersionAndCurrentChunk_Finish();
   }

   private function playCurrentLessonVersionAndCurrentChunk_Finish():void {
      var currPlayingLessonVO:LessonVersionVO = LessonVersionVO(_currentLessonVersionAudioSequence.getCurrentVOForLevel(AUDIO_SEQUENCE_LEVEL__LESSON));
      var currPlayingChunkVO:ChunkVO = ChunkVO(_currentLessonVersionAudioSequence.getCurrentVOForLevel(AUDIO_SEQUENCE_LEVEL__CHUNK));
      Log.info([
         "AudioController.playCurrentLessonVersionAndCurrentChunk_Finish()",
         "Previous lesson:",
         ((currPlayingLessonVO) ? currPlayingLessonVO.publishedLessonVersionId : "null"),
         "Previous chunk:",
         ((currPlayingChunkVO) ? currPlayingChunkVO.locationInOrder : "null"),
         "Current lesson:",
         _currentLessons.currentLessonVO.publishedLessonVersionId,
         "Current chunk:",
         _currentLessons.currentChunkVO.locationInOrder]);
      var isSameLesson:Boolean = false;
      var isSameChunk:Boolean = false;
      isSameLesson = (currPlayingLessonVO.equals(_currentLessons.currentLessonVO));
      isSameChunk =
            (currPlayingChunkVO) ?
                  (currPlayingChunkVO.equals(_currentLessons.currentChunkVO)) :
                  null;
      if (isSameLesson && isSameChunk) {
         // startFromCurrentElement will start from current element(s), if
         // set. If they're not set it will start from first elements.
      }
      else if (isSameLesson && (!isSameChunk)) {
         // Next line is questionable - we may actually only want to call
         // decrementTempChunkSequenceStrategyAndClearIfAppropriate() instead...
         // But, because we currently, only call setTempChangeChunkSequenceStrategyForNChunks()
         // with a value of 1, this works okay unless/until we change that.
         clearTempChunkSequenceStrategy();
         _currentLessonVersionAudioSequence.moveToElement(AUDIO_SEQUENCE_LEVEL__LESSON, _currentLessons.currentChunkIndex);
      }
      else {
         // dmccarroll 20130808 - Antiquated code - We're moving to a different lesson - which never happens
         Log.error("AudioController.playCurrentLessonVersionAndCurrentChunk_Finish(): Antiquated code isn't so antiquated - it's being used");
         _currentLessonVersionAudioSequence.moveToElement(AUDIO_SEQUENCE_LEVEL__LESSON, _currentLessons.currentChunkIndex);
      }
      _currentLessonVersionAudioSequence.startFromCurrentElement(AUDIO_SEQUENCE_LEVEL__CHUNK);
   }

   private function startLeafFinishCheckProcess(leaf:AudioSequenceLeaf):void {
      stopLeafFinishCheckProcess();
      _currentAudioSequenceLeaf = leaf;
      _timer_LeafFinishChecker = new Timer(leaf.duration + 2000, 1);
      _timer_LeafFinishChecker.addEventListener(TimerEvent.TIMER, onTimer_LeafFinishChecker);
      _timer_LeafFinishChecker.start();
   }

   private function stopLeafFinishCheckProcess():void {
      _currentAudioSequenceLeaf = null;
      if (_timer_LeafFinishChecker) {
         _timer_LeafFinishChecker.stop();
         _timer_LeafFinishChecker.removeEventListener(TimerEvent.TIMER, onTimer_LeafFinishChecker);
         _timer_LeafFinishChecker = null;
      }
   }

   private function switchToRecordModeStrategy():void {
      Log.info(["AudioController.switchToRecordModeStrategy()"]);
      if (!_currentPrimaryChunkSequenceStrategy)
         Log.warn("AudioController.switchToRecordModeStrategy(): _currentLessonVersionAudioSequence is null");
      if (_currentLessons.isCurrentLessonAlphaReviewVersion())
         return;
      if (_currentPrimaryChunkSequenceStrategy is SequenceStrategy_NativeToTargetLearning) {
         _currentLessonVersionAudioSequence.setSequenceStrategy(new SequenceStrategy_NativeToTargetLearningWithPlayback(), AUDIO_SEQUENCE_LEVEL__CHUNK);
      }
      else if (_currentPrimaryChunkSequenceStrategy is SequenceStrategy_NativeToTargetTranslation) {
         _currentLessonVersionAudioSequence.setSequenceStrategy(new SequenceStrategy_NativeToTargetTranslationWithPlayback(), AUDIO_SEQUENCE_LEVEL__CHUNK);
      }
      else if (_currentPrimaryChunkSequenceStrategy is SequenceStrategy_RepeatTarget) {
         _currentLessonVersionAudioSequence.setSequenceStrategy(new SequenceStrategy_RepeatTargetWithPlayback(), AUDIO_SEQUENCE_LEVEL__CHUNK);
      }
      else {
         Log.warn(["AudioController.switchToRecordModeStrategy(): _currentLessonVersionAudioSequence isn't playback-able:", _currentPrimaryChunkSequenceStrategy]);
      }
   }

   private function updateCurrentLessonVersionAudioSequenceSequenceStrategies(chunksOnly:Boolean = false):void {
      Log.info(["AudioController.updateCurrentLessonVersionAudioSequenceSequenceStrategies()"]);
      if (!chunksOnly) {
         var lessonStrat:ISequenceStrategy = new SequenceStrategy_Lesson();
         _currentLessonVersionAudioSequence.setSequenceStrategy(lessonStrat, AUDIO_SEQUENCE_LEVEL__LESSON)
      }
      var chunkStrategy:ISequenceStrategy;
      if (_currentLessons.isCurrentLessonAlphaReviewVersion()) {
         chunkStrategy = new SequenceStrategy_AlphaReviewVersion();
      }
      else if ((_model.isCurrentLearningModeDualLanguage()) && (!_currentLessons.currentLessonVO.isDualLanguage)) {
         chunkStrategy = new SequenceStrategy_RepeatTarget();
      }
      else {
         var learningModeToken:String = _model.getLearningModeTokenFromID(_model.currentLearningModeId);
         switch (learningModeToken) {
            case Constant_LearningModeLabels.LISTEN_TO_TARGET: {
               chunkStrategy = new SequenceStrategy_ListenToTarget();
               break;
            }
            case Constant_LearningModeLabels.NATIVE_TO_TARGET_LEARNING: {
               chunkStrategy = new SequenceStrategy_NativeToTargetLearning();
               break;
            }
            case Constant_LearningModeLabels.NATIVE_TO_TARGET_TRANSLATION: {
               chunkStrategy = new SequenceStrategy_NativeToTargetTranslation();
               break;
            }
            case Constant_LearningModeLabels.REPEAT_TARGET: {
               chunkStrategy = new SequenceStrategy_RepeatTarget();
               break;
            }
            case Constant_LearningModeLabels.TARGET_TO_NATIVE_TRANSLATION: {
               chunkStrategy = new SequenceStrategy_TargetToNativeTranslation();
               break;
            }
            default: {
               Log.fatal(["AudioController.updateCurrentLessonVersionAudioSequenceSequenceStrategies(): no case for learning mode token in switch statement:", learningModeToken]);
            }
         }
      }
      _currentPrimaryChunkSequenceStrategy = chunkStrategy;
      _currentLessonVersionAudioSequence.setSequenceStrategy(chunkStrategy, AUDIO_SEQUENCE_LEVEL__CHUNK);
      if (isRecordMode)
         switchToRecordModeStrategy();
   }
}
}

