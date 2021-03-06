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
package com.langcollab.languagementor.vo {
import flash.events.Event;

[Bindable(event="valueChange")]

public class ChunkReferencingVO extends LessonVersionReferencingVO {
   private var _chunkLocationInOrder:int;

   public function get chunkLocationInOrder():int {
      return _chunkLocationInOrder;
   }

   public function set chunkLocationInOrder(value:int):void {
      setPropList.push("chunkLocationInOrder");
      if (_chunkLocationInOrder != value) {
         _chunkLocationInOrder = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   public function ChunkReferencingVO() {
      super();
   }

   override public function getPropNameList_KeyProps():Array {
      var result:Array = super.getPropNameList_KeyProps();
      result.push("chunkLocationInOrder");
      return result;
   }

}
}
