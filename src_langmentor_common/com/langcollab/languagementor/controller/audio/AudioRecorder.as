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
import com.brightworks.util.singleton.SingletonManager;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.SampleDataEvent;
import flash.events.TimerEvent;
import flash.media.Microphone;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.sampler.getSize;
import flash.utils.ByteArray;
import flash.utils.Timer;

[Event(name="soundComplete", type="flash.events.Event")]

public class AudioRecorder extends EventDispatcher implements IManagedSingleton {
   public static const RECORDING_START_DELAY_DURATION:uint = START_DELAY__INITIAL + _START_DELAY__PUBLIC_IS_CURRENTLY_RECORDING_FLAG;
   public static const START_DELAY__INITIAL:uint = 500;

   private static const _START_DELAY__PUBLIC_IS_CURRENTLY_RECORDING_FLAG:uint = 350;
   private static var _instance:AudioRecorder;

   private var _isPlaybackActive:Boolean;
   private var _isRecordingActive:Boolean;
   private var _microphone:Microphone;
   private var _playbackChannel:SoundChannel;
   private var _playbackSound:Sound;
   private var _recordedAudio:ByteArray;
   private var _recordingTimer_SetPublicIsCurrentlyRecordingDelay:Timer;
   private var _recordingTimer_StartDelay:Timer;
   private var _recordingTimer_StopDelay:Timer;

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
      _recordedAudio = new ByteArray();
      attemptToActivateMicrophone();
   }

   public function attemptToActivateMicrophone():void {
      Utils_ANEs.requestMicrophonePermission(attemptToActivateMicrophone_Continued);
   }

   private function attemptToActivateMicrophone_Continued(permissionGranted:Boolean):void {
      if (permissionGranted) {
         _microphone = Microphone.getMicrophone();
         if (_microphone) {
            _microphone.rate = 44;
            _microphone.gain = 50; // Docs: "A value of 50 acts like a multiplier of one and specifies normal volume. ... Values above 50 specify higher than normal volume."
            _microphone.setSilenceLevel(0, 2000);
         }
      }
   }

   public function clear():void {
      Log.info("AudioRecorder.clear()");
      _isPlaybackActive = false;
      _isRecordingActive = false;
      stopRecordingTimer_StartDelay();
      if (_microphone)
         _microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onNewRecordingSampleData);
      setPublicIsCurrentlyRecordingFlag(false);
      if (_playbackSound) {
         _playbackSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, onGetPlaybackSampleData);
         // _playbackSound.close() throws an IOError. I assume that this is because we never call its load() method, and there is nothing to close.
         _playbackSound = null;
      }
      if (_playbackChannel) {
         _playbackChannel.removeEventListener(Event.SOUND_COMPLETE, onPlaybackComplete);
         _playbackChannel.stop();
         _playbackChannel = null;
      }
      _recordedAudio.clear();
   }

   public static function getInstance():AudioRecorder {
      Log.info("AudioRecorder.getInstance()");
      if (_instance == null)
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function initSingleton():void {
      Log.info("AudioRecorder.initSingleton()");
   }

   public function isMicrophoneAvailable():Boolean {
      Log.info("AudioRecorder.isMicrophoneAvailable()");
      return (_microphone != null);
   }

   public function startPlayback():void {
      Log.info("AudioRecorder.startPlayback()");
      _isPlaybackActive = true;
      _recordedAudio.position = 0;
      _playbackSound = new Sound();
      _playbackSound.addEventListener(SampleDataEvent.SAMPLE_DATA, onGetPlaybackSampleData);
      _playbackChannel = _playbackSound.play();
      _playbackChannel.addEventListener(Event.SOUND_COMPLETE, onPlaybackComplete);
   }

   public function startRecording():void {
      Log.info("AudioRecorder.startRecording()");
      if (!isMicrophoneAvailable()) {
         Log.error("AudioRecorder.startRecording: Microphone not available - check isMicrophoneAvailable() before calling this method")
         return;
      }
      clear();
      _isRecordingActive = true;
      _isMicrophoneUsedInSession = true;
      _recordingTimer_StartDelay = new Timer(500);
      _recordingTimer_StartDelay.addEventListener(TimerEvent.TIMER, onRecordingTimer_StartDelay);
      _recordingTimer_StartDelay.start();
   }

   public function stopPlayback():void {
      Log.info("AudioRecorder.stopPlayback()");
      clear();
   }

   public function stopRecording(recordingStopDelayDuration:uint = 0):void {
      Log.info("AudioRecorder.stopRecording(): _recordedAudio's size: " + getSize(_recordedAudio));
      if (!isMicrophoneAvailable()) {
         // We call this method from at least on of our subclass's dispose() methods, whether or not the microphone is available, so this isn't an error condition
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
      _microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onNewRecordingSampleData);
   }

   private function onGetPlaybackSampleData(event:SampleDataEvent):void {
      if (!_isPlaybackActive)
         return;
      if (_recordedAudio.bytesAvailable <= 0)
         return;
      for (var i:int = 0; i < 8192; i++) {
         var sample:Number = 0;
         if (_recordedAudio.bytesAvailable > 0) {
            sample = _recordedAudio.readFloat();
         }
         event.data.writeFloat(sample);
         event.data.writeFloat(sample);
      }
   }

   private function onNewRecordingSampleData(event:SampleDataEvent):void {
      _recordedAudio.writeBytes(event.data);
   }

   private function onPlaybackComplete(event:Event):void {
      Log.info("AudioRecorder.onPlaybackComplete()");
      clear();
      dispatchEvent(new Event(Event.SOUND_COMPLETE));
   }

   private function onRecordingTimer_SetPublicIsCurrentlyRecordingDelay(event:TimerEvent):void {
      Log.debug("AudioRecorder.onRecordingTimer_SetPublicIsCurrentlyRecordingDelay()");
      stopRecordingTimer_SetPublicIsCurrentlyRecordingDelay();
      setPublicIsCurrentlyRecordingFlag(true);
   }

   private function onRecordingTimer_StartDelay(event:TimerEvent):void {
      Log.debug("AudioRecorder.onRecordingTimer_StartDelay()");
      stopRecordingTimer_StartDelay();
      _microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, onNewRecordingSampleData);
      _recordingTimer_SetPublicIsCurrentlyRecordingDelay = new Timer(350, 1);
      _recordingTimer_SetPublicIsCurrentlyRecordingDelay.addEventListener(TimerEvent.TIMER, onRecordingTimer_SetPublicIsCurrentlyRecordingDelay);
      _recordingTimer_SetPublicIsCurrentlyRecordingDelay.start();
   }

   private function onRecordingTimer_StopDelay(event:TimerEvent):void {
      Log.debug("AudioRecorder.onRecordingTimer_StopDelay()");
      stopRecordingTimer_StopDelay();
      actuallyStopRecording();
   }

   private function stopRecordingTimer_SetPublicIsCurrentlyRecordingDelay():void {
      Log.info("AudioRecorder.stopRecordingTimer_SetPublicIsCurrentlyRecordingDelay()");
      if (_recordingTimer_SetPublicIsCurrentlyRecordingDelay) {
         _recordingTimer_SetPublicIsCurrentlyRecordingDelay.stop();
         _recordingTimer_SetPublicIsCurrentlyRecordingDelay.removeEventListener(TimerEvent.TIMER, onRecordingTimer_SetPublicIsCurrentlyRecordingDelay);
         _recordingTimer_SetPublicIsCurrentlyRecordingDelay = null;
      }
   }

   private function stopRecordingTimer_StartDelay():void {
      Log.info("AudioRecorder.stopRecordingTimer_StartDelay()");
      if (_recordingTimer_StartDelay) {
         _recordingTimer_StartDelay.stop();
         _recordingTimer_StartDelay.removeEventListener(TimerEvent.TIMER, onRecordingTimer_StartDelay);
         _recordingTimer_StartDelay = null;
      }
   }

   private function stopRecordingTimer_StopDelay():void {
      Log.info("AudioRecorder.stopRecordingTimer_StopDelay()");
      if (_recordingTimer_StopDelay) {
         _recordingTimer_StopDelay.stop();
         _recordingTimer_StopDelay.removeEventListener(TimerEvent.TIMER, onRecordingTimer_StopDelay);
         _recordingTimer_StopDelay = null;
      }
   }

}
}

