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
package com.langcollab.languagementor.component.learningmodelist {
// This class is a modified version of code written by Nahuel Foronda for this article:
// http://www.asfusion.com/blog/entry/mobile-itemrenderer-in-actionscript-part-4

import com.brightworks.component.itemrenderer.ItemRenderer_Mobile_Base;
import com.brightworks.util.Utils_Text;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.utils.Timer;

import spark.effects.Fade;

public class ItemRenderer_LearningModeList extends ItemRenderer_Mobile_Base {

   private var _background:DisplayObject;
   private var _backgroundClass:Class;
   private var _buttonDisplayTimer:Timer;
   private var _contentField:TextField;
   private var _contentFieldTextHeight:int = 0;
   private var _fadeEffect:Fade;
   private var _helpButton:LearningModeListHelpButton;
   private var _separator:DisplayObject;
   private var _singleOrDualLanguageIndicator:Bitmap;
   private var _unscaledHeight:int = 0;

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

   public function ItemRenderer_LearningModeList() {
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
      setBackground();
      addHelpButton();
      var separatorClass:Class = getStyle("separator");
      if (separatorClass) {
         _separator = new separatorClass();
         addChild(_separator);
      }
      _contentField = Utils_Text.createSimpleTextField(Math.round(Utils_Text.getStandardFontSize() * 1.15));
      _contentField.wordWrap = true;
      _contentField.multiline = true;
      addChild(_contentField);
      if (data)
         setValues();
      _buttonDisplayTimer = new Timer(200, 1);
      _buttonDisplayTimer.addEventListener(TimerEvent.TIMER, displayButton);
      _buttonDisplayTimer.start();
   }

   override protected function setValues():void {
      _value = data.value;
      _contentField.htmlText = data.label;
      _helpButton.clickSoundEnabled = selected; // List provides click for unselected items
   }

   override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
      //trace("******* updateDisplayList() " + selected);
      if (_singleOrDualLanguageIndicator) {
         removeChild(_singleOrDualLanguageIndicator);
         _singleOrDualLanguageIndicator = null;
      }
      var singleOrDualLanguageIndicatorClass:Class;
      if (singleOrDualLanguageIndicatorClass) {
         _singleOrDualLanguageIndicator = new singleOrDualLanguageIndicatorClass();
         _singleOrDualLanguageIndicator.smoothing = true;
         addChild(_singleOrDualLanguageIndicator);
      }
      var consumedWidth:uint = 0;
      _unscaledHeight = unscaledHeight;
      var padding:int = Math.round(unscaledHeight / 20);
      _helpButton.x = padding * 2;
      _helpButton.y = padding * 2;
      _helpButton.width = _helpButton.height = unscaledHeight - (padding * 4);
      consumedWidth = unscaledHeight;
      if (_singleOrDualLanguageIndicator) {
         _singleOrDualLanguageIndicator.x = consumedWidth;
         _singleOrDualLanguageIndicator.y = (unscaledHeight - _singleOrDualLanguageIndicator.height) / 2;
         consumedWidth += _singleOrDualLanguageIndicator.width + padding;
      }
      _contentField.width = (unscaledWidth - (consumedWidth + padding)) - 20;
      _contentField.x = consumedWidth + padding;
      _background.width = unscaledWidth;
      _background.height = layoutHeight;
      _separator.width = unscaledWidth;
      _separator.y = layoutHeight - _separator.height;
   }

   override protected function updateSkin():void {
      //trace("******* updateSkin() " + selected);
      currentCSSState = (selected) ? "selected" : "up";
      setBackground();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private function addHelpButton():void {
      _helpButton = new LearningModeListHelpButton();
      _helpButton.visible = false;
      _helpButton.addEventListener(MouseEvent.CLICK, onHelpButtonClick);
      addChild(_helpButton);
   }

   private function displayButton(event:TimerEvent):void {
      _buttonDisplayTimer.stop();
      _buttonDisplayTimer.removeEventListener(TimerEvent.TIMER, displayButton);
      _buttonDisplayTimer = null;
      _fadeEffect = new Fade();
      _fadeEffect.alphaFrom = 0;
      _fadeEffect.alphaTo = 1;
      _fadeEffect.duration = 1000;
      _fadeEffect.play([_helpButton]);
   }

   private function onEnterFrame(event:Event):void {
      if (_unscaledHeight <= 0)
         return;
      if (_contentField.textHeight == _contentFieldTextHeight)
         return;
      _contentFieldTextHeight = _contentField.textHeight;
      _contentField.y = (_unscaledHeight - _contentField.textHeight) / 2;
      _contentField.height = _contentField.textHeight + 20;
   }

   private function onHelpButtonClick(event:MouseEvent):void {
      _helpButton.enabled = false; // To prevent double clicks - we'll always leave screen once button is clicked, so we don't worry about re-enabling
      LearningModeList(owner).dispatchDisplayHelpEvent(data);
   }

   private function setBackground():void {
      var newBackgroundClass:Class =
            selected ?
                  getStyle("backgroundSelected") :
                  getStyle("background");
      if (newBackgroundClass && (_backgroundClass != newBackgroundClass)) {
         if (_background && contains(_background))
            removeChild(_background);
         _backgroundClass = newBackgroundClass;
         _background = new newBackgroundClass();
         addChildAt(_background, 0);
         invalidateDisplayList();
      }
   }
}
}
