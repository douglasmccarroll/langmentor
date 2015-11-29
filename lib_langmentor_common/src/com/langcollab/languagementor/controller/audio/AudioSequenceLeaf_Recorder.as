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
    import com.brightworks.util.Log;

    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    public class AudioSequenceLeaf_Recorder extends AudioSequenceLeaf_Timer
    {
        private static var _availableInstancePool:Array = [];

        private var _audioRecorder:AudioRecorder = AudioRecorder.getInstance();
        private var _recordingStopDelayDuration:uint;
        private var _suppressRecording:Boolean;
        private var _timer:Timer;

        // ****************************************************
        //
        //          Public Methods
        //
        // ****************************************************

        public function AudioSequenceLeaf_Recorder(enforcer:Class)
        {
            super();
            if (enforcer != InstancePoolEnforcer)
                throw new Error("AudioSequenceLeaf_Recorder: create instances with acquireReusable()");
        }

        public static function acquireReusable(id:Object, duration:uint, recordingStopDelayDuration:uint = 0, suppressRecording:Boolean = false):AudioSequenceLeaf_Recorder
        {
            var result:AudioSequenceLeaf_Recorder;
            if (_availableInstancePool.length > 0)
            {
                result = _availableInstancePool.pop();
                result.isDisposed = false;
            }
            else
            {
                result = new AudioSequenceLeaf_Recorder(InstancePoolEnforcer);
            }
            result.id = id;
            result.duration = duration + recordingStopDelayDuration;
            result._recordingStopDelayDuration = recordingStopDelayDuration;
            result._suppressRecording = suppressRecording;
            return result;
        }

        override public function dispose():void
        {
            stopRecording();
            _audioRecorder = null;
            super.dispose();
            AudioSequenceLeaf_Recorder.releaseReusable(this);
        }

        public static function releaseReusable(instance:AudioSequenceLeaf_Recorder):void
        {
            if (_availableInstancePool.indexOf(instance) != -1)
                _availableInstancePool.push(instance);
        }

        override public function startFromBeginning():void
        {
            Log.info("AudioSequenceLeaf_Recorder.startFromBeginning(): duration:" + duration + "recordingStopDelayDuration:" + _recordingStopDelayDuration);
            super.startFromBeginning();
            if (!_suppressRecording)
            {
                _audioRecorder.startRecording();
                _timer = new Timer(duration - _recordingStopDelayDuration, 1);
                _timer.addEventListener(TimerEvent.TIMER, onTimer);
                _timer.start();
            }
        }

        override public function stop():void
        {
            Log.debug("AudioSequenceLeaf_Recorder.stop()");
            if (!_suppressRecording)
                stopRecording();
            super.stop();
        }

        // ****************************************************
        //
        //          Protected Methods
        //
        // ****************************************************

        override protected function onElementComplete(event:Event):void
        {
            Log.debug("AudioSequenceLeaf_Recorder.onElementComplete()");
            super.onElementComplete(event);
        }

        // ****************************************************
        //
        //          Private Methods
        //
        // ****************************************************

        private function onTimer(event:TimerEvent):void
        {
            stopRecording()
        }

        private function stopRecording():void
        {
            stopTimer();
            if (!_suppressRecording && (_audioRecorder))
                _audioRecorder.stopRecording(_recordingStopDelayDuration);
        }

        private function stopTimer():void
        {
            if (_timer)
            {
                _timer.stop();
                _timer.removeEventListener(TimerEvent.TIMER, onTimer);
                _timer = null;
            }
        }

    }
}

class InstancePoolEnforcer
{
}
