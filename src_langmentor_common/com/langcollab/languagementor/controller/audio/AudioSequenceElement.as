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
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;
import com.langcollab.languagementor.event.Event_AudioProgress;

import flash.events.Event;
import flash.events.EventDispatcher;

[Event(name="elementCompleteReport", type="com.langcollab.languagementor.event.Event_AudioProgress")]
[Event(name="complete", type="com.brightworks.event.BwEvent")]

public class AudioSequenceElement extends EventDispatcher implements IDisposable {
   public var isDisposed:Boolean = false;
   public var isLeaf:Boolean = false;
   public var isPaused:Boolean = false;
   public var levelId:String;

   protected var id:Object;


   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function AudioSequenceElement() {
   }

   public function dispose():void {
      id = null;
      isDisposed = true;
      isLeaf = false;
      isPaused = false;
      levelId = null;
   }

   public function pause(levelIdForLevelToRestartFromBeginning:String):void {
      Log.debug(["AudioSequenceElement.pause()"]);
      //if (!isPlaying) 
      //	Log.fatal(["AudioSequenceElement.pause(): called when not playing. this:", this]);
      isPaused = true;
   }

   public function resume(levelIdForLevelToRestartFromBeginning:String):void {
      Log.debug(["AudioSequenceElement.resume()"]);
      //if (!isPlaying) 
      //	Log.fatal(["AudioSequenceElement.resume(): called when not playing. this:", this]);
      if (!isPaused)
         Log.fatal(["AudioSequenceElement.resume(): called when not paused. this:", this]);
      isPaused = false;
   }

   public function startFromBeginning():void {
      dispatchEvent(new Event_AudioProgress(Event_AudioProgress.ELEMENT_START_REPORT, id, levelId));
   }

   public function stop():void {
      //if (!isPlaying) 
      //	Log.fatal(["AudioSequenceElement.stop(): called when not playing. this:", this]);
      isPaused = false;
      //isPlaying = false;
   }

   // ****************************************************
   //
   //          Protected Methods
   //
   // ****************************************************

   protected function onAllElementsComplete():void {
      Log.debug(["AudioSequenceElement.onAllElementsComplete()"]);
      // ELEMENT_COMPLETE_REPORT is typically handled by the client that created the entire audio sequence tree.
      // COMPLETE is typically handled (only) by parent elements.
      // Be aware - if you do stuff in the client in response to ELEMENT_COMPLETE_REPORT - that stuff
      // that happens on COMPLETE - cleanup, auto-advance - hasn't happened yet. For example, if the client is calling a 
      // branch's moveToElement() method, and that branch also has autoAdvance == true, you may have a problem.  :)
      dispatchEvent(new Event_AudioProgress(Event_AudioProgress.ELEMENT_COMPLETE_REPORT, id, levelId));
      dispatchEvent(new Event(Event.COMPLETE));
   }

   protected function onElementComplete(event:Event):void {
      // Abstract method: Different subclasses need to handle this in different ways.
      Log.fatal("AudioSequenceElement.onElementComplete(), an abstract method, called");
   }
}
}
