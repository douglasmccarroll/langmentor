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
[RemoteClass(alias="com.langcollab.languagementor.db.LanguageVO")]

public class LanguageVO extends VO implements IVO {
   private static var _associatedTableName:String;
   private static var _propInfoList:Dictionary;

   public var iso639_3Code:String;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private var _hasRecommendedLibraries:Boolean;

   public function get hasRecommendedLibraries():Boolean {
      return _hasRecommendedLibraries;
   }

   public function set hasRecommendedLibraries(value:Boolean):void {
      setPropList.push("hasRecommendedLibraries");
      if (_hasRecommendedLibraries != value) {
         _hasRecommendedLibraries = value;
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

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function LanguageVO() {
      super();
   }

   public function equals(v:IVO):Boolean {
      if (!(v is LanguageVO))
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
      return LanguageVO;
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

   override public function isReferencingInstance(vo:VO):Boolean {
      var languageReferencingVO:LanguageReferencingVO = LanguageReferencingVO(vo);
      if (languageReferencingVO.languageId != id)
         return false;
      return true;
   }
}
}
