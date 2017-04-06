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
package com.langcollab.languagementor.component.lessonversionlist {
   // This class is a modified version of code written by Nahuel Foronda for this article:
   // http://www.asfusion.com/blog/entry/mobile-itemrenderer-in-actionscript-part-4

   import com.brightworks.component.itemrenderer.ItemRenderer_Mobile_Base;
   import com.brightworks.constant.Constant_Color;
   import com.brightworks.util.Utils_Layout;
   import com.brightworks.util.Utils_Text;
   import com.langcollab.languagementor.vo.LessonVersionVO;

   import flash.display.Bitmap;
   import flash.events.Event;
   import flash.system.Capabilities;
   import flash.text.TextField;

   import spark.effects.Fade;

   public class ItemRenderer_LessonVersionList extends ItemRenderer_Mobile_Base {

      private var _contentField:TextField;
      private var _contentFieldTextHeight:int = 0;
      private var _fadeEffect:Fade;
      private var _singleOrDualLanguageIndicator:Bitmap;
      private var _unscaledHeight:int = 0;
      private var _unscaledWidth:int = 0;

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
      //
      //          Getters / Setters
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      private var _value:Object;

      public function get value():Object {
         return _value;
      }

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
      //
      //          Public Methods
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

      public function ItemRenderer_LessonVersionList() {
         super();
         percentWidth = 100;
         addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
      }

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
      //
      //          Protected Methods
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

      override protected function createChildren():void {
         _contentField  = Utils_Text.createSimpleTextField(Math.round(Utils_Text.getStandardFontSize() * 1.3));
         _contentField.wordWrap = true;
         _contentField.multiline = true;
         addChild(_contentField);
         if (data)
            setValues();
      }

      override protected function measure():void {
         super.measure();
         measuredHeight = Math.round(Capabilities.screenDPI / 2);
      }

      override protected function setValues():void {
         if (data.hasOwnProperty("value"))
            _value = data.value;
         _contentField.htmlText = data.label;
      }

      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
         _unscaledHeight = unscaledHeight;
         _unscaledWidth = unscaledWidth;
         if (_singleOrDualLanguageIndicator) {
            removeChild(_singleOrDualLanguageIndicator);
            _singleOrDualLanguageIndicator = null;
         }
         if ((data.hasOwnProperty("data")) && (data.data) && (data.data.hasOwnProperty("lessonVersionVO"))) {
            var lvvo:LessonVersionVO = LessonVersionVO(data.data.lessonVersionVO);
            var singleOrDualLanguageIndicatorClass:Class;
            // todo
            //lvvo.isDualLanguage ?
            //getStyle("singleorduallanguageindicatordual") :
            //getStyle("singleorduallanguageindicatorsingle");
            if (singleOrDualLanguageIndicatorClass) {
               _singleOrDualLanguageIndicator = new singleOrDualLanguageIndicatorClass();
               _singleOrDualLanguageIndicator.smoothing = true;
               addChild(_singleOrDualLanguageIndicator);
            }
         }
         var consumedWidth:uint = Utils_Layout.getStandardPadding();
         var padding:int = Math.round(unscaledHeight / 20);
         if (_singleOrDualLanguageIndicator) {
            _singleOrDualLanguageIndicator.x = consumedWidth;
            _singleOrDualLanguageIndicator.y = (unscaledHeight - _singleOrDualLanguageIndicator.height) / 2;
            consumedWidth += _singleOrDualLanguageIndicator.width + padding;
         }
         _contentField.width = unscaledWidth - (consumedWidth + padding);
         _contentField.x = consumedWidth + padding;
         drawBackground();
      }

      override protected function updateSkin():void {
         currentCSSState = (selected) ? "selected" : "up";
         drawBackground();
      }

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
      //
      //          Private Methods
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

      private function drawBackground():void {
         if (_unscaledHeight == 0)
            return;
         var c:uint;
         c = 
            selected ? 
            Constant_Color.LIST_ITEM_BACKGROUND__SELECTED : Constant_Color.LIST_ITEM_BACKGROUND;
         graphics.beginFill(c, 1);
         graphics.drawRect(0, 0, _unscaledWidth, _unscaledHeight);
         graphics.endFill();
         graphics.lineStyle(1, 0xC0C0C0);
         graphics.moveTo(0, _unscaledHeight - 1);
         graphics.lineTo(_unscaledWidth, _unscaledHeight - 1);
         graphics.lineStyle(1, 0xFFFFFF);
         graphics.moveTo(0, _unscaledHeight);
         graphics.lineTo(_unscaledWidth, _unscaledHeight);
      }

      private function onEnterFrame(event:Event):void {
         if (_unscaledHeight <= 0)
            return;
         if (_contentField.textHeight == _contentFieldTextHeight)
            return;
         _contentFieldTextHeight = _contentField.textHeight;
         _contentField.y = (_unscaledHeight - _contentField.textHeight) / 2;
      }

   }
}

