/*
    Copyright 2020 Brightworks, Inc.

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
[RemoteClass(alias="com.langcollab.languagementor.db.LearningModeVO")]

public class LearningModeVO extends VO implements IVO {
   private static var _associatedTableName:String;
   private static var _propInfoList:Dictionary;

   public var labelToken:String; // e.g. "NativeToTargetLearning"

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private var _hasRecordPlayback:Boolean;

   public function get hasRecordPlayback():Boolean {
      return _hasRecordPlayback;
   }

   public function set hasRecordPlayback(value:Boolean):void {
      setPropList.push("hasRecordPlayback");
      if (_hasRecordPlayback != value) {
         _hasRecordPlayback = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

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

   private var _isDualLanguage:Boolean;

   public function get isDualLanguage():Boolean {
      return _isDualLanguage;
   }

   public function set isDualLanguage(value:Boolean):void {
      setPropList.push("isDualLanguage");
      if (_isDualLanguage != value) {
         _isDualLanguage = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   private var _locationInOrder:int;

   public function get locationInOrder():int {
      return _locationInOrder;
   }

   public function set locationInOrder(value:int):void {
      setPropList.push("locationInOrder");
      if (_locationInOrder != value) {
         _locationInOrder = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function LearningModeVO() {
      super();
   }

   public function equals(v:IVO):Boolean {
      if (!(v is LearningModeVO))
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
      return LearningModeVO;
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









