/*
    Copyright 2021 Brightworks, Inc.

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

import flash.events.Event;

public class AudioSequenceLeaf_Playback extends AudioSequenceLeaf {
   private static var _availableInstancePool:Array = [];

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function AudioSequenceLeaf_Playback(enforcer:Class) {
      super();
      if (enforcer != InstancePoolEnforcer)
         throw new Error("AudioSequenceLeaf_Playback: create instances with acquireReusable()");
   }

   public static function acquireReusable(id:Object, duration:int):AudioSequenceLeaf_Playback {
      var result:AudioSequenceLeaf_Playback;
      if (_availableInstancePool.length > 0) {
         result = _availableInstancePool.pop();
         result.isDisposed = false;
      }
      else {
         result = new AudioSequenceLeaf_Playback(InstancePoolEnforcer);
      }
      result.id = id;
      result.duration = duration;
      return result;
   }

   override public function dispose():void {
      if (AudioRecorder.getInstance()) {
         AudioRecorder.getInstance().stopPlayback();
         AudioRecorder.getInstance().removeEventListener(Event.SOUND_COMPLETE, onElementComplete);
      }
      super.dispose();
      AudioSequenceLeaf_Playback.releaseReusable(this);
   }

   public static function releaseReusable(instance:AudioSequenceLeaf_Playback):void {
      if (_availableInstancePool.indexOf(instance) != -1)
         _availableInstancePool.push(instance);
   }

   public override function startFromBeginning():void {
      Log.debug("AudioSequenceLeaf_Playback.startFromBeginning()");
      super.startFromBeginning();
      AudioRecorder.getInstance().addEventListener(Event.SOUND_COMPLETE, onElementComplete);
      AudioRecorder.getInstance().startPlayback();
   }

   public override function stop():void {
      Log.debug("AudioSequenceLeaf_Playback.stop()");
      super.stop();
      AudioRecorder.getInstance().stopPlayback();
      AudioRecorder.getInstance().removeEventListener(Event.SOUND_COMPLETE, onElementComplete);
   }

   // ****************************************************
   //
   //          Protected Methods
   //
   // ****************************************************

   protected override function onElementComplete(event:Event):void {
      Log.debug("AudioSequenceLeaf_Playback.onElementComplete()");
      AudioRecorder.getInstance().stopPlayback();
      AudioRecorder.getInstance().removeEventListener(Event.SOUND_COMPLETE, onElementComplete);
      super.onElementComplete(event);
   }
}
}

class InstancePoolEnforcer {
}
