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

import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;

public class AudioSequenceLeaf_Silence extends AudioSequenceLeaf_Timer {
   private static var _availableInstancePool:Array = [];

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function AudioSequenceLeaf_Silence(enforcer:Class) {
      super();
      if (enforcer != InstancePoolEnforcer)
         throw new Error("AudioSequenceLeaf_Silence: create instances with acquireReusable()");
   }

   public static function acquireReusable(id:Object, duration:uint = 0):AudioSequenceLeaf_Silence {
      var result:AudioSequenceLeaf_Silence;
      if (_availableInstancePool.length > 0) {
         result = _availableInstancePool.pop();
         result.isDisposed = false;
      }
      else {
         result = new AudioSequenceLeaf_Silence(InstancePoolEnforcer);
      }
      if (duration == 0 ) {
         switch (id) {
            case Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_200_MS:
               duration = 200;
               break;
            case Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_500_MS:
               duration = 500;
               break;
            case Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_1000_MS:
               duration = 1000;
               break;
            case Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_2000_MS:
               duration = 2000;
               break;
            case Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_3000_MS:
               duration = 3000;
               break;
            default:
               Log.error("AudioSequenceLeaf_Silence.acquireReusable(): No case for id of : " + id);
               duration = 1000;
         }
      }
      result.duration = duration;
      result.id = id;
      return result;
   }

   override public function dispose():void {
      super.dispose();
      AudioSequenceLeaf_Silence.releaseReusable(this);
   }

   public static function releaseReusable(instance:AudioSequenceLeaf_Silence):void {
      if (_availableInstancePool.indexOf(instance) != -1)
         _availableInstancePool.push(instance);
   }

}
}

class InstancePoolEnforcer {
}
