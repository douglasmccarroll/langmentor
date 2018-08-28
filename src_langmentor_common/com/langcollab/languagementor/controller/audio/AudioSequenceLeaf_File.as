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
package com.langcollab.languagementor.controller.audio {
import com.brightworks.util.Log;
import com.langcollab.languagementor.event.Event_AudioProgress;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

[Event(name="ioErrorReport", type="com.langcollab.languagementor.event.Event_AudioProgress")]
public class AudioSequenceLeaf_File extends AudioSequenceLeaf {

   private static var _availableInstancePool:Array = [];

   public var url:String;

   internal var audioVolumeAdjustmentFactor:Number;

   private var _audioPlayer:AudioPlayer = AudioPlayer.getInstance();


   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function AudioSequenceLeaf_File(enforcer:Class) {
      super();
      if (enforcer != InstancePoolEnforcer)
         throw new Error("AudioSequenceLeaf_File: create instances with acquireReusable()");
   }

   public static function acquireReusable(id:Object, url:String, audioAdjustmentFactor:Number, duration:int):AudioSequenceLeaf_File {
      var result:AudioSequenceLeaf_File;
      if (_availableInstancePool.length > 0) {
         result = _availableInstancePool.pop();
         result.isDisposed = false;
      }
      else {
         result = new AudioSequenceLeaf_File(InstancePoolEnforcer);
      }
      result.audioVolumeAdjustmentFactor = audioAdjustmentFactor;
      result.id = id;
      result.url = url;
      result.duration = duration;
      return result;
   }

   override public function dispose():void {
      removeEventListeners();
      audioVolumeAdjustmentFactor = 0;
      url = null;
      _audioPlayer = null;
      super.dispose();
      AudioSequenceLeaf_File.releaseReusable(this);
   }

   public static function releaseReusable(instance:AudioSequenceLeaf_File):void {
      if (_availableInstancePool.indexOf(instance) != -1)
         _availableInstancePool.push(instance);
   }

   override public function startFromBeginning():void {
      Log.debug(["AudioSequenceLeaf_File.startFromBeginning(): url=" + url, "Calls AudioPlayer.play()"]);
      _audioPlayer.addEventListener(Event.SOUND_COMPLETE, onElementComplete);
      _audioPlayer.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
      _audioPlayer.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onIOError);
      _audioPlayer.play(url, audioVolumeAdjustmentFactor);
      // We don't call super.startFromBeginning() here because all it does is to dispatch the ELEMENT_START_REPORT
      // event, and we want to include the url info when we do this...
      dispatchEvent(new Event_AudioProgress(Event_AudioProgress.ELEMENT_START_REPORT, id, levelId, url));
   }


   override public function stop():void {
      Log.debug(["AudioSequenceLeaf_File.stop(): url=" + url]);
      super.stop();
      removeEventListeners();
      _audioPlayer.stop(url);
   }

   // ****************************************************
   //
   //          Protected Methods
   //
   // ****************************************************

   override protected function onElementComplete(event:Event):void {
      Log.debug(["AudioSequenceLeaf_File.onElementComplete(): url=" + url, event]);
      removeEventListeners();
      super.onElementComplete(event);
   }

   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************

   private function onIOError(event:ErrorEvent):void {
      Log.debug(["AudioSequenceLeaf_File.onIOError(): url=" + url, event]);
      // Dispatch IOERROR_REPORT - AudioController listens for this
      dispatchEvent(new Event_AudioProgress(Event_AudioProgress.IOERROR_REPORT, id, levelId, event.text));
   }

   private function removeEventListeners():void {
      _audioPlayer.removeEventListener(Event.SOUND_COMPLETE, onElementComplete);
      _audioPlayer.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
      _audioPlayer.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onIOError);
   }
}

}

class InstancePoolEnforcer {
}
