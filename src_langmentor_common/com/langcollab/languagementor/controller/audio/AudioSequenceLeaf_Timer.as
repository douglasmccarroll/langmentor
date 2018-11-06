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
import com.brightworks.util.Log;
import com.brightworks.util.Utils_System;
import com.brightworks.util.audio.AudioPlayer;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class AudioSequenceLeaf_Timer extends AudioSequenceLeaf {
   private var _timer:Timer;

   public function AudioSequenceLeaf_Timer() {
      super();
   }

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   override public function dispose():void {
      Log.info("AudioSequenceLeaf_Timer.dispose()");
      duration = 0;
      if (_timer) {
         Log.info("AudioSequenceLeaf_Timer.dispose(): Stopping timer");
         _timer.stop();
         _timer.removeEventListener(TimerEvent.TIMER, onElementComplete);
         _timer = null;
      }
      super.dispose();
   }

   override public function startFromBeginning():void {
      Log.info("AudioSequenceLeaf_Timer.startFromBeginning() - creating new Timer with duration = " + duration);
      super.startFromBeginning();
      _timer = new Timer(duration, 0);
      _timer.addEventListener(TimerEvent.TIMER, onElementComplete);
      _timer.start();
      if (Utils_System.isAndroid())  // I'm not sure that this would do any harm in iOS but it doesn't seem to need it in order to keep media controls displayed in the lock screen
            AudioPlayer.getInstance().playSilenceFile();
   }

   override public function stop():void {
      Log.info("AudioSequenceLeaf_Timer.stop()");
      super.stop();
      if (_timer) {
         Log.info("AudioSequenceLeaf_Timer.stop(): Stopping timer");
         _timer.stop();
         _timer.removeEventListener(TimerEvent.TIMER, onElementComplete);
         _timer = null;
      }
   }

   // ****************************************************
   //
   //          Protected Methods
   //
   // ****************************************************

   override protected function onElementComplete(event:Event):void {
      Log.info("AudioSequenceLeaf_Timer.onElementComplete()");
      if (_timer) {
         Log.info("AudioSequenceLeaf_Timer.onElementComplete(): Stopping timer");
         _timer.stop();
         _timer.removeEventListener(TimerEvent.TIMER, onElementComplete);
         _timer = null;
      }
      super.onElementComplete(event);
   }
}
}
