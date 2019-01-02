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

package com.langcollab.languagementor.controller.audio {
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_ANEs;
import com.brightworks.util.Utils_System;
import com.brightworks.util.audio.AudioPlayer;
import com.brightworks.util.singleton.SingletonManager;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.media.Microphone;
import flash.utils.ByteArray;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.setTimeout;

import org.bytearray.micrecorder.MicRecorder;
import org.bytearray.micrecorder.encoder.WaveEncoder;

public class AudioRecorder extends EventDispatcher implements IManagedSingleton {
   public static const START_DELAY__INITIAL:uint = 500;
   public static const START_DELAY__PAUSE_BEFORE_INFORMING_USER_WE_ARE_RECORDING:uint = 350;
   private static var _instance:AudioRecorder;

   private var _isAttemptingPlayback:Boolean;
   private var _isPlaybackActive:Boolean;
   private var _isRecordingActive:Boolean;
   private var _microphone:Microphone;
   private var _playbackTimer:Timer;                                      // We start this timer when we start playback
   private var _recordedSamples:ByteArray;
   private var _recorder:MicRecorder;
   private var _recordingTimer_SetPublicIsCurrentlyRecordingDelay:Timer;  // Once we start recording, we wait a bit before announcing to the world that we're recording - once we announce this the microphone icon appears, prompting the user to start speaking
   private var _recordingTimer_StartDelay:Timer;                          //// Experiment  // We wait a bit before we start recording. At this point I'm not sure why we do this. Years have passed since I wrote this code. I probably had a good reason to do this, but I'm not sure it still applies.
   private var _recordingTimer_StopDelay:Timer;                           // After we stop displaying the microphone icon to the user we continue recording for a bit because we don't want to cut off the ending of what they record.

   // ****************************************************
   //
   //          Getters / Setters
   //
   // ****************************************************

   private var _isCurrentlyRecording:Boolean;

   [Bindable(event="isCurrentlyRecordingChange")]
   public function get isCurrentlyRecording():Boolean {
      return _isCurrentlyRecording;
   }

   private function setPublicIsCurrentlyRecordingFlag(value:Boolean):void {
      if (value == _isCurrentlyRecording)
         return;
      _isCurrentlyRecording = value;
      dispatchEvent(new Event("isCurrentlyRecordingChange"));
   }

   private var _isMicrophoneUsedInSession:Boolean;

   public function get isMicrophoneUsedInSession():Boolean {
      return _isMicrophoneUsedInSession;
   }

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function AudioRecorder(manager:SingletonManager) {
      Log.info("AudioRecorder constructor");
      _instance = this;
      if (Utils_System.isRunningOnDesktop()) {
         initializeMicAndRecorder();
      } else {
         Utils_ANEs.requestMicrophonePermission(onMicrophonePermissionRequestResponse);
      }
   }

   public function clear():void {
      Log.debug("AudioRecorder.clear()");
      if(_recorder)
         _recorder.stop();
      _isAttemptingPlayback = false;
      _isPlaybackActive = false;
      _isRecordingActive = false;
      _recordedSamples = null;
      stopPlaybackTimer();
      stopRecordingTimer_StartDelay();
      stopRecordingTimer_SetPublicIsCurrentlyRecordingDelay();
      stopRecordingTimer_StopDelay()
      setPublicIsCurrentlyRecordingFlag(false);
   }

   public static function getInstance():AudioRecorder {
      Log.debug("AudioRecorder.getInstance()");
      if (_instance == null)
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function initSingleton():void {
      Log.info("AudioRecorder.initSingleton()");
   }

   public function isRecorderAvailable():Boolean {
      Log.debug("AudioRecorder.isRecorderAvailable()");
      return (_recorder != null);
   }

   public function startPlayback(duration:int):void {
      _isAttemptingPlayback = true;
      if (_recordedSamples) {
         Log.info("AudioRecorder.startPlayback() - starting playback");
         _isAttemptingPlayback = false;
         _isPlaybackActive = true;
         AudioPlayer.getInstance().playWavSample(_recordedSamples);
         _recordedSamples = null;
         _playbackTimer = new Timer(duration);
         _playbackTimer.addEventListener(TimerEvent.TIMER, onPlaybackTimer);
         _playbackTimer.start();
      } else if (_isAttemptingPlayback) {
         Log.info("AudioRecorder.startPlayback() - _recordedSamples is null - wait and try again in a bit");
         setTimeout(startPlayback, 200, [duration]);
      }

   }

   public function startRecording():void {
      Log.info("AudioRecorder.startRecording()");
      if (!isRecorderAvailable()) {
         Log.error("AudioRecorder.startRecording: Microphone not available - check isRecorderAvailable() before calling this method")
         return;
      }
      clear();
      _isRecordingActive = true;
      _isMicrophoneUsedInSession = true;
      _recordingTimer_StartDelay = new Timer(START_DELAY__INITIAL);
      _recordingTimer_StartDelay.addEventListener(TimerEvent.TIMER, onRecordingTimer_StartDelay);
      _recordingTimer_StartDelay.start();
      AudioPlayer.getInstance().playSilenceFile();
   }

   public function stopPlayback():void {
      Log.info("AudioRecorder.stopPlayback()");
      _isAttemptingPlayback = false;
      clear();
   }

   public function stopRecording(recordingStopDelayDuration:uint = 0):void {
      Log.info("AudioRecorder.stopRecording()");
      if (!isRecorderAvailable()) {
         // We call this method from at least one of our subclass's dispose() methods, whether or not the microphone is available, so this isn't an error condition
         return;
      }
      if (!_isCurrentlyRecording)
         return;
      _isRecordingActive = false;
      setPublicIsCurrentlyRecordingFlag(false); // This tells the outside world that we're not recording any more
      if (recordingStopDelayDuration > 0) {
         _recordingTimer_StopDelay = new Timer(recordingStopDelayDuration, 1);
         _recordingTimer_StopDelay.addEventListener(TimerEvent.TIMER, onRecordingTimer_StopDelay);
         _recordingTimer_StopDelay.start();
      }
      else {
         actuallyStopRecording();
      }
   }

   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************

   private function actuallyStopRecording(event:TimerEvent = null):void {
      Log.info("AudioRecorder.actuallyStopRecording()");
      _recorder.stop();
      _recordedSamples = _recorder.output;
      AudioPlayer.getInstance().playSilenceFile();
   }

   private function initializeMicAndRecorder():void {
      _microphone = Microphone.getMicrophone();
      if (_microphone) {
         _microphone.rate = 44;
         _microphone.gain = 20; ///// test    // Docs: "A value of 50 acts like a multiplier of one and specifies normal volume." ... But it's recording at much too high a level ...
         _microphone.setSilenceLevel(0, 2000);
         _recorder = new MicRecorder(new WaveEncoder(), _microphone);
      }
   }

   private function onMicrophonePermissionRequestResponse(permissionGranted:Boolean):void {
      if (permissionGranted) {
         initializeMicAndRecorder();
      }
   }

   private function onPlaybackTimer(event:TimerEvent):void {
      Log.info("AudioRecorder.onPlaybackTimer()");
      stopPlaybackTimer()
      dispatchEvent(new Event(Event.SOUND_COMPLETE));
   }

   private function onRecordingTimer_SetPublicIsCurrentlyRecordingDelay(event:TimerEvent):void {
      Log.info("AudioRecorder.onRecordingTimer_SetPublicIsCurrentlyRecordingDelay()");
      stopRecordingTimer_SetPublicIsCurrentlyRecordingDelay();
      setPublicIsCurrentlyRecordingFlag(true);
   }

   private function onRecordingTimer_StartDelay(event:TimerEvent):void {
      Log.info("AudioRecorder.onRecordingTimer_StartDelay()");
      stopRecordingTimer_StartDelay();
      _recorder.record();
      _recordingTimer_SetPublicIsCurrentlyRecordingDelay = new Timer(START_DELAY__PAUSE_BEFORE_INFORMING_USER_WE_ARE_RECORDING, 1);
      _recordingTimer_SetPublicIsCurrentlyRecordingDelay.addEventListener(TimerEvent.TIMER, onRecordingTimer_SetPublicIsCurrentlyRecordingDelay);
      _recordingTimer_SetPublicIsCurrentlyRecordingDelay.start();
   }

   private function onRecordingTimer_StopDelay(event:TimerEvent):void {
      Log.info("AudioRecorder.onRecordingTimer_StopDelay()");
      stopRecordingTimer_StopDelay();
      actuallyStopRecording();
   }

   private function stopPlaybackTimer():void {
      Log.debug("AudioRecorder.stopPlaybackTimer()");
      if (_playbackTimer) {
         _playbackTimer.stop();
         _playbackTimer.removeEventListener(TimerEvent.TIMER, onPlaybackTimer);
         _playbackTimer = null;
      }
   }

   private function stopRecordingTimer_SetPublicIsCurrentlyRecordingDelay():void {
      Log.debug("AudioRecorder.stopRecordingTimer_SetPublicIsCurrentlyRecordingDelay()");
      if (_recordingTimer_SetPublicIsCurrentlyRecordingDelay) {
         _recordingTimer_SetPublicIsCurrentlyRecordingDelay.stop();
         _recordingTimer_SetPublicIsCurrentlyRecordingDelay.removeEventListener(TimerEvent.TIMER, onRecordingTimer_SetPublicIsCurrentlyRecordingDelay);
         _recordingTimer_SetPublicIsCurrentlyRecordingDelay = null;
      }
   }

   private function stopRecordingTimer_StartDelay():void {
      Log.debug("AudioRecorder.stopRecordingTimer_StartDelay()");
      if (_recordingTimer_StartDelay) {
         _recordingTimer_StartDelay.stop();
         _recordingTimer_StartDelay.removeEventListener(TimerEvent.TIMER, onRecordingTimer_StartDelay);
         _recordingTimer_StartDelay = null;
      }
   }

   private function stopRecordingTimer_StopDelay():void {
      Log.debug("AudioRecorder.stopRecordingTimer_StopDelay()");
      if (_recordingTimer_StopDelay) {
         _recordingTimer_StopDelay.stop();
         _recordingTimer_StopDelay.removeEventListener(TimerEvent.TIMER, onRecordingTimer_StopDelay);
         _recordingTimer_StopDelay = null;
      }
   }

}
}

