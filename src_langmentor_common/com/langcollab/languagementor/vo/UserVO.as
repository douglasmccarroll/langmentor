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
import com.brightworks.vo.VO;

import flash.events.Event;
import flash.utils.Dictionary;

[Bindable(event="valueChange")]
[RemoteClass(alias="com.langcollab.languagementor.db.UserVO")]

public class UserVO extends VO implements IVO {
   private static var _associatedTableName:String;
   private static var _propInfoList:Dictionary;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private var _id:int;

   public function get id():int {
      return _id;
   }

   public function set id(value:int):void {
      setPropList.push("id");
      if (_id != value) {
         _id = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   private var _nativeLanguageId:int;

   public function get nativeLanguageId():int {
      return _nativeLanguageId;
   }

   public function set nativeLanguageId(value:int):void {
      setPropList.push("nativeLanguageId");
      if (_nativeLanguageId != value) {
         _nativeLanguageId = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   private var _targetLanguageId:int;

   public function get targetLanguageId():int {
      return _targetLanguageId;
   }

   public function set targetLanguageId(value:int):void {
      setPropList.push("targetLanguageId");
      if (_targetLanguageId != value) {
         _targetLanguageId = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function UserVO() {
      super();
   }

   public function equals(v:IVO):Boolean {
      if (!(v is UserVO))
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
      return UserVO;
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
