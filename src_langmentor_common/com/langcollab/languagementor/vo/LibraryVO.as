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
import com.brightworks.vo.IVO;
import com.brightworks.vo.VO;

import flash.events.Event;
import flash.utils.Dictionary;

[Bindable(event="valueChange")]
[RemoteClass(alias="com.langcollab.languagementor.db.LibraryVO")]

public class LibraryVO extends VO implements IVO {
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private var _enabled:Boolean;

   public function get enabled():Boolean {
      return _enabled;
   }

   public function set enabled(value:Boolean):void {
      setPropList.push("enabled");
      if (_enabled != value) {
         _enabled = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   public var libraryFolderURL:String;

   private static var _associatedTableName:String;
   private static var _propInfoList:Dictionary;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function LibraryVO() {
      super();
   }

   public function equals(v:IVO):Boolean {
      if (!(v is LibraryVO))
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
      return LibraryVO;
   }

   override public function getPropInfoList():Dictionary {
      if (!_propInfoList) {
         _propInfoList = extractPropInfoList();
      }
      return _propInfoList;
   }

   public function getPropNameList_KeyProps():Array {
      var result:Array = [];
      result.push("id");
      return result;
   }

}
}
