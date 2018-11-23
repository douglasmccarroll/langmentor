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
package com.langcollab.languagementor.vo {
import com.brightworks.vo.IVO;

import flash.events.Event;
import flash.utils.Dictionary;

[Bindable(event="valueChange")]
[RemoteClass(alias="com.langcollab.languagementor.db.ChunkFileVO")]
public class ChunkFileVO extends ChunkReferencingVO implements IVO {

   private static var _associatedTableName:String;
   private static var _propInfoList:Dictionary;

   public var fileNameBody:String;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private var _duration:int;

   public function get duration():int {
      return _duration;
   }

   public function set duration(value:int):void {
      setPropList.push("duration");
      if (_duration != value) {
         _duration = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function ChunkFileVO() {
      super();
   }

   public function equals(v:IVO):Boolean {
      if (!(v is ChunkFileVO))
         return false;
      return doKeyPropsMatch(v);
   }

   override public function getAssociatedTableName():String {
      if (!_associatedTableName) {
         _associatedTableName = extractAssociatedTableName();
      }
      return _associatedTableName;
   }

   override public function getClass():Class {
      return ChunkFileVO;
   }

   override public function getPropInfoList():Dictionary {
      if (!_propInfoList) {
         _propInfoList = extractPropInfoList();
      }
      return _propInfoList;
   }

   override public function getPropNameList_KeyProps():Array {
      var result:Array = super.getPropNameList_KeyProps();
      result.push("fileNameBody");
      return result;
   }

}
}
