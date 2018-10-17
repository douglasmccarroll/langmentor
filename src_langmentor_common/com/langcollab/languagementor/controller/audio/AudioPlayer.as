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
import com.brightworks.util.Utils_NativeExtensions;
import com.brightworks.util.singleton.SingletonManager;
import com.distriqt.extension.mediaplayer.events.AudioPlayerEvent;
import com.distriqt.extension.mediaplayer.events.MediaErrorEvent;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Timer;

[Event(name="complete", type="flash.events.Event")]
[Event(name="id3", type="flash.events.Event")]
[Event(name="open", type="flash.events.Event")]
[Event(name="progress", type="flash.events.ProgressEvent")]
[Event(name="soundComplete", type="flash.events.Event")]

public class AudioPlayer extends EventDispatcher implements IManagedSingleton {
   private static var _instance:AudioPlayer;

   private var _isPlaying:Boolean;
   private var _soundURL:String;

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function AudioPlayer(manager:SingletonManager) {
      Log.info("AudioPlayer constructor");
      _instance = this;
   }

   public static function getInstance():AudioPlayer {
      Log.info("AudioPlayer.getInstance()");
      if (_instance == null)
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function initSingleton():void {
      Log.info("AudioPlayer.initSingleton()");
   }

   // A passedSoundVolumeAdjustmentFactor of 1 means that the sound volume will be left as-is
   public function play(soundUrl:String, volume:Number):void {
      Log.info("AudioPlayer.play(): " + soundUrl);
      if (_isPlaying) {
         if (soundUrl == _soundURL) {
            // dmccarroll 20130719
            // This can happen when the user is rapidly clicking buttons, especially the Next Lesson and Previous Lesson buttons.
            // Here's an outline of one way that this can happen:
            //    We have two timers:
            //      1. 800 ms  CurrentLessons uses CurrentLessonsAudioTimer
            //      2. 250 ms  AudioController.playCurrentLessonVersionAndCurrentChunk() sets timer to call
            //                 playCurrentLessonVersionAndCurrentChunk_CreateCurrentLessonVersionAudioSequence()
            //                (if new audio sequence creation is needed)
            //    The sequence:
            //      > button click
            //      Timer 1 started
            //      > button click
            //      Timer 1 restarted
            //      Timer 1 finishes
            //      Timer 2 is started
            //      < button click
            //      Timer 1 started
            //      Timer 2 finishes - playCurrentLessonVersionAndCurrentChunk_CreateCurrentLessonVersionAudioSequence() creates
            //                         correct audio sequence (because CurrentLessons's lesson/chunk info gets updated before
            //                         timers) and starts play audio process
            //      Timer 1 finishes
            //      No new audio sequence needed - so AudioController.playCurrentLessonVersionAndCurrentChunk() calls
            //        playCurrentLessonVersionAndCurrentChunk_Finish() immediately (Timer 2 isn't used) - and starts play
            //        audio process
            //  Note that nowhere in this process are we ensuring that the play audio process doesn't get started multiple times without getting
            //  stopped. In fact, I'd argue that we shouldn't do so. What we do instead is to check and see if something needs to be changed and,
            //  if it does, we make the correct thing happen. It looks as though the simplest way to deal with the possibility that our code may
            //  try to do 'the right thing' twice, when it really only needs to be done once, is to watch for that case here, and abort.
            Log.info(["AudioPlayer.play(): called while sound is playing with same URL as currently playing, so we return without playing", "URL: " + _soundURL]);
            return;
         }
         else {
            Log.warn(["AudioPlayer.play(): called while sound is playing", "Old URL: " + _soundURL, "New URL: " + soundUrl]);
         }
      }
      _isPlaying = true;
      _soundURL = soundUrl;
      var file:File = new File(_soundURL);
      Utils_NativeExtensions.audioPlay(file, volume, audioCallback);
   }

   public function stop(url:String = null):void {
      Log.info("AudioPlayer.stop(): " + url);
      if ((url) && (_soundURL != "") && (url != _soundURL)) {
         Log.warn("AudioPlayer.stop(): url != _soundURL: url=" + url + " _soundURL=" + _soundURL);
         return;
      }
      _soundURL = null;
      _isPlaying = false;
      Utils_NativeExtensions.audioStop();
   }

   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************
   
   private function audioCallback(e:Object):void {
      if (e is AudioPlayerEvent) {
         switch (AudioPlayerEvent(e).type) {
            case AudioPlayerEvent.COMPLETE:
               _soundURL = null;
               dispatchEvent(new Event(Event.SOUND_COMPLETE));
               break;
            default:
               Log.warn("AudioPlayer.audioCallback() - Event type not supported: " + AudioPlayerEvent(e).type);
         }
      } else if (e is MediaErrorEvent) {
         Log.error("AudioPlayer.audioCallback() - Passed object is MediaErrorEvent - _soundURL: " + _soundURL);
      } else {
         Log.error("AudioPlayer.audioCallback() - Passed object is neither AudioPlayerEvent or MediaErrorEvent - _soundURL: " + _soundURL);
      }
   }


}
}

