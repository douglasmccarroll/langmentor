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
import com.brightworks.constant.Constant_ReleaseType;
import com.brightworks.vo.IVO;
import com.brightworks.vo.VO;

import flash.events.Event;
import flash.utils.Dictionary;

[Bindable(event="valueChange")]
[RemoteClass(alias="com.langcollab.languagementor.db.LessonVersionVO")]

public class LessonVersionVO extends VO implements IVO {

   private static var _associatedTableName:String;
   private static var _propInfoList:Dictionary;

   public var contentProviderId:String;
   public var lessonVersionSignature:String;
   public var libraryId:String;
   public var publishedLessonVersionId:String;
   public var publishedLessonVersionVersion:String;
   public var releaseType:String;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private var _assetsFileSize:int;

   public function get assetsFileSize():int {
      return _assetsFileSize;
   }

   public function set assetsFileSize(value:int):void {
      setPropList.push("assetsFileSize");
      if (_assetsFileSize != value) {
         _assetsFileSize = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   private var _defaultTextDisplayTypeId:int;

   public function get defaultTextDisplayTypeId():int {
      return _defaultTextDisplayTypeId;
   }

   public function set defaultTextDisplayTypeId(value:int):void {
      setPropList.push("defaultTextDisplayTypeId");
      if (_defaultTextDisplayTypeId != value) {
         _defaultTextDisplayTypeId = value;
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

   private var _levelId:int;

   public function get levelId():int {
      return _levelId;
   }

   public function set levelId(value:int):void {
      setPropList.push("levelId");
      if (_levelId != value) {
         _levelId = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   private var _nativeLanguageAudioVolumeAdjustmentFactor:Number;

   public function get nativeLanguageAudioVolumeAdjustmentFactor():Number {
      return _nativeLanguageAudioVolumeAdjustmentFactor;
   }

   public function set nativeLanguageAudioVolumeAdjustmentFactor(value:Number):void {
      setPropList.push("nativeLanguageAudioVolumeAdjustmentFactor");
      if (_nativeLanguageAudioVolumeAdjustmentFactor != value) {
         _nativeLanguageAudioVolumeAdjustmentFactor = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   private var _paidContent:Boolean;

   public function get paidContent():Boolean {
      return _paidContent;
   }

   public function set paidContent(value:Boolean):void {
      setPropList.push("paidContent");
      if (_paidContent != value) {
         _paidContent = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   private var _targetLanguageAudioVolumeAdjustmentFactor:Number;

   public function get targetLanguageAudioVolumeAdjustmentFactor():Number {
      return _targetLanguageAudioVolumeAdjustmentFactor;
   }

   public function set targetLanguageAudioVolumeAdjustmentFactor(value:Number):void {
      setPropList.push("targetLanguageAudioVolumeAdjustmentFactor");
      if (_targetLanguageAudioVolumeAdjustmentFactor != value) {
         _targetLanguageAudioVolumeAdjustmentFactor = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   private var _uploaded:Boolean;

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

   private var _xmlFileSize:int;

   public function get xmlFileSize():int {
      return _xmlFileSize;
   }

   public function set xmlFileSize(value:int):void {
      setPropList.push("xmlFileSize");
      if (_xmlFileSize != value) {
         _xmlFileSize = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function LessonVersionVO() {
      super();
   }

   public function equals(v:IVO):Boolean {
      if (!(v is LessonVersionVO))
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
      return LessonVersionVO;
   }

   override public function getPropInfoList():Dictionary {
      if (!_propInfoList) {
         _propInfoList = extractPropInfoList();
      }
      return _propInfoList;
   }

   public function getPropNameList_KeyProps():Array {
      var result:Array = [];
      result.push("contentProviderId");
      result.push("lessonVersionSignature");
      return result;
   }

   override public function isReferencingInstance(vo:VO):Boolean {
      var lessonVersionReferencingVO:LessonVersionReferencingVO = LessonVersionReferencingVO(vo);
      if (lessonVersionReferencingVO.contentProviderId != contentProviderId)
         return false;
      if (lessonVersionReferencingVO.lessonVersionSignature != lessonVersionSignature)
         return false;
      return true;
   }
}
}
