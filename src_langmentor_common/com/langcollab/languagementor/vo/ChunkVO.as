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
[RemoteClass(alias="com.langcollab.languagementor.db.ChunkVO")]

public class ChunkVO extends LessonVersionReferencingVO implements IVO {

   public static const CHUNK_TYPE__DEFAULT:String = "Default";  // What's the default chunk type? It's contents vary, depending on whether we're in alpha mode, whether the lesson is single or dual-language, etc. But, essentially, it's a chunk that contains language content, and is used for drilling the user.
   public static const CHUNK_TYPE__EXPLANATORY:String = "Explanatory";

   private static var _associatedTableName:String;
   private static var _propInfoList:Dictionary;

   public var chunkType:String;
   public var fileNameRoot:String;
   public var textAudio:String;
   public var textDisplay:String;
   public var textNativeLanguage:String;
   public var textTargetLanguage:String;
   public var textTargetLanguagePhonetic:String;

   private var _uploaded:Boolean;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

   private var _suppressed:Boolean;

   public function get suppressed():Boolean {
      return _suppressed;
   }

   public function set suppressed(value:Boolean):void {
      setPropList.push("suppressed");
      if (_suppressed != value) {
         _suppressed = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   public function get uploaded():Boolean {
      return _uploaded;
   }

   public function set uploaded(value:Boolean):void {
      setPropList.push("uploaded");
      if (_uploaded != value) {
         _uploaded = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function ChunkVO() {
      super();
   }

   public function equals(v:IVO):Boolean {
      if (!(v is ChunkVO))
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
      return ChunkVO;
   }

   override public function getPropInfoList():Dictionary {
      if (!_propInfoList) {
         _propInfoList = extractPropInfoList();
      }
      return _propInfoList;
   }

   override public function getPropNameList_KeyProps():Array {
      var result:Array = super.getPropNameList_KeyProps();
      result.push("locationInOrder");
      return result;
   }

   override public function isReferencingInstance(vo:VO):Boolean {
      var chunkReferencingVO:ChunkReferencingVO = ChunkReferencingVO(vo);
      if (chunkReferencingVO.contentProviderId != contentProviderId)
         return false;
      if (chunkReferencingVO.lessonVersionSignature != lessonVersionSignature)
         return false;
      if (chunkReferencingVO.chunkLocationInOrder != locationInOrder)
         return false;
      return true;
   }
}
}
