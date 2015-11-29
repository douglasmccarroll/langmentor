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
package com.langcollab.languagementor.controller.audio
{
    import com.brightworks.interfaces.IManagedSingleton;
    import com.brightworks.util.Log;
    import com.brightworks.util.singleton.SingletonManager;

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

    [Event(name="complete",       type="flash.events.Event"              )]
    [Event(name="id3",            type="flash.events.Event"              )]
    [Event(name="ioError",        type="flash.events.IOErrorEvent"       )]
    [Event(name="open",           type="flash.events.Event"              )]
    [Event(name="progress",       type="flash.events.ProgressEvent"      )]
    [Event(name="securityError",  type="flash.events.SecurityErrorEvent" )]
    [Event(name="soundComplete",  type="flash.events.Event"              )]

    public class AudioPlayer extends EventDispatcher implements IManagedSingleton
    {
        private static const _BUFFER_TIME:uint = 500;
        private static const _SAMPLE_SIZE:uint = 4096;

        private static var _instance:AudioPlayer;

        private var _isPlaying:Boolean;
        private var _sound:Sound;
        private var _soundChannel:SoundChannel;
        private var _soundChannel_Silent:SoundChannel;
        private var _soundURL:String;
        private var _soundVolumeAdjustmentFactor:Number;
        private var _timer:Timer;

        // ****************************************************
        //
        //          Public Methods
        //
        // ****************************************************

        public function AudioPlayer(manager:SingletonManager)
        {
            Log.info("AudioPlayer constructor");
            _instance = this;
        }

        public static function getInstance():AudioPlayer
        {
            Log.info("AudioPlayer.getInstance()");
            if (_instance == null)
                throw new Error("Singleton not initialized");
            return _instance;
        }

        public function initSingleton():void
        {
            Log.info("AudioPlayer.initSingleton()");
        }

        // A passedSoundVolumeAdjustmentFactor of 1 means that the sound volume will be left as-is
        public function play(soundUrl:String, passedSoundVolumeAdjustmentFactor:Number):void
        {
            Log.info("AudioPlayer.play(): " + soundUrl);
            if (_isPlaying)
            {
                if (soundUrl == _soundURL)
                {
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
                else
                {
                    Log.warn(["AudioPlayer.play(): called while sound is playing", "Old URL: " + _soundURL, "New URL: " + soundUrl]);
                }
            }
            clear();
            _isPlaying = true;
            _soundVolumeAdjustmentFactor = passedSoundVolumeAdjustmentFactor;
            _soundURL = soundUrl;
            var file:File = new File(_soundURL);
            var request:URLRequest = new URLRequest(file.url);
            var transform:SoundTransform = new SoundTransform(_soundVolumeAdjustmentFactor);
            _sound = new Sound();
            _sound.load(request);
            _soundChannel = _sound.play();
            _soundChannel.soundTransform = transform;
            _sound.addEventListener(IOErrorEvent.IO_ERROR, onSoundLoadError);
            _sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSoundLoadError);
            _soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
        }

        public function stop(url:String = null):void
        {
            Log.info("AudioPlayer.stop(): " + _soundURL);
            if ((url) && (_soundURL != "") && (url != _soundURL))
            {
                Log.warn("AudioPlayer.stop(): url != _soundURL: url=" + url + " _soundURL=" + _soundURL);
                return;
            }
            clear();
        }

        // ****************************************************
        //
        //          Private Methods
        //
        // ****************************************************

        private function clear():void
        {
            Log.info("AudioPlayer.clear()");
            _isPlaying = false;
            if (_sound)
            {
                _sound.removeEventListener(IOErrorEvent.IO_ERROR, onSoundLoadError);
                _sound.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSoundLoadError);
                _sound = null;
            }
            if (_soundChannel)
            {
                _soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
                _soundChannel.stop();
                _soundChannel = null;
            }
            if (_soundChannel_Silent)
            {
                _soundChannel_Silent.stop();
                _soundChannel_Silent = null;
            }
            _soundURL = "";
            _soundVolumeAdjustmentFactor = 0;
        }

        private function clearTimer():void
        {
            if (_timer)
            {
                _timer.stop();
                _timer.removeEventListener(TimerEvent.TIMER, play_Continued);
                _timer = null;
            }
        }

        private function createSilentSample():ByteArray
        {
            var result:ByteArray = new ByteArray();
            var desiredLength:uint = 2 * _SAMPLE_SIZE;
            for (var i:uint = 0; i < desiredLength; i++)
            {
                result.writeFloat(0);
            }
            return result;
        }

        private function onSoundComplete(event:Event):void
        {
            Log.info("AudioPlayer.onSoundComplete()");
            clear();
            dispatchEvent(new Event(Event.SOUND_COMPLETE));
        }

        private function onSoundLoadError(event:ErrorEvent):void
        {
            Log.info("AudioPlayer.onSourceSoundLoadError()");
            clear();
            dispatchEvent(event.clone());
        }

        private function play_Continued(event:TimerEvent):void
        {
            clearTimer();
            // We may have paused while timer is running
            if (_sound)
            {
                var transform:SoundTransform = new SoundTransform(_soundVolumeAdjustmentFactor);
                _soundChannel = _sound.play(0, 1, transform);
                _soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
            }
        }

    }
}

