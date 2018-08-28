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

public class AudioSequenceLeaf_Silence_Initial extends AudioSequenceLeaf_Timer {
   private var _durationProviderFunction:Function;

   private static var _availableInstancePool:Array = [];

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function AudioSequenceLeaf_Silence_Initial(enforcer:Class) {
      super();
      if (enforcer != InstancePoolEnforcer)
         throw new Error("AudioSequenceLeaf_Silence_Initial: create instances with acquireReusable()");
   }

   public static function acquireReusable(id:Object, duration:uint, durationProviderFunction:Function):AudioSequenceLeaf_Silence_Initial {
      var result:AudioSequenceLeaf_Silence_Initial;
      if (_availableInstancePool.length > 0) {
         result = _availableInstancePool.pop();
         result.isDisposed = false;
      }
      else {
         result = new AudioSequenceLeaf_Silence_Initial(InstancePoolEnforcer);
      }
      result.id = id;
      result.duration = duration;
      result._durationProviderFunction = durationProviderFunction;
      return result;
   }

   override public function dispose():void {
      super.dispose();
      AudioSequenceLeaf_Silence_Initial.releaseReusable(this);
   }

   public static function releaseReusable(instance:AudioSequenceLeaf_Silence_Initial):void {
      if (_availableInstancePool.indexOf(instance) != -1)
         _availableInstancePool.push(instance);
   }

   override public function startFromBeginning():void {
      duration = _durationProviderFunction();
      super.startFromBeginning();
   }

}
}

class InstancePoolEnforcer {
}
