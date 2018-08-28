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
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;

import flash.events.Event;

public class AudioSequenceLeaf extends AudioSequenceElement implements IDisposable {
   public var duration:int;

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function AudioSequenceLeaf() {
      super();
      Log.debug("AudioSequenceLeaf constructor");
      isLeaf = true;
      levelId = AudioController.AUDIO_SEQUENCE_LEVEL__LEAF;
   }

   override public function dispose():void {
      Log.debug("AudioSequenceLeaf.dispose()");
      super.dispose();
   }

   public override function pause(levelIdForLevelToRestartFromBeginning:String):void {
      // Leafs aren't paused in the sense of "stop in middle, and resume from that point on resume".
      // Instead we just stop leaves, and resume by playing from the beginning.
      stop();
   }

   public override function resume(levelIdForLevelToRestartFromBeginning:String):void {
      if (levelIdForLevelToRestartFromBeginning != levelId) {
         // As this is a leaf, we can't go down any more levels... So, this is a problem.  :)
         Log.fatal("AudioSequenceLeaf.resume(): Passed levelIdForLevelToRestartFromBeginning doesn't match instance's levelId");
      }
      // Leafs are never paused in the middle, so when we resume we simply re-start
      startFromBeginning();
   }

   public function setSequenceStrategy(strategy:ISequenceStrategy, levelId:String):void {
      Log.fatal("AudioSequenceLeaf.setSequenceStrategy(): these calls should pass in through branches, but not into leafs");
   }

   // ****************************************************
   //
   //          Protected Methods
   //
   // ****************************************************

   protected override function onElementComplete(event:Event):void {
      // A leaf, by definition, only has one element, so...
      onAllElementsComplete();
   }
}
}
