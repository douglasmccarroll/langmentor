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





dmccarroll 20121031

This class was created by first combining spark.skins.mobile.TextInputSkin and it's super-class,
spark.skins.mobile.supportClasses.TextSkinBase, then adding & subtracting stuff. A fair amount
of code could be removed/simplified because this skin has no border, the text isn't editable, etc.

*/
package com.langcollab.languagementor.component.skin {
import com.brightworks.util.Utils_Layout;

import flash.events.Event;
import flash.text.TextFieldAutoSize;

import mx.core.FlexGlobals;
import mx.core.mx_internal;
import mx.events.ResizeEvent;

import spark.components.TextArea;
import spark.components.supportClasses.StyleableTextField;
import spark.skins.mobile.supportClasses.MobileSkin;

use namespace mx_internal;

public class UIWidget_TextArea_NonEditable_Skin extends MobileSkin {
   public var hostComponent:TextArea;
   public var scrollable:Boolean = false;
   public var textDisplay:StyleableTextField;

   private var _isDisposed:Boolean;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function UIWidget_TextArea_NonEditable_Skin() {
      super();
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (textDisplay) {
         textDisplay.addEventListener(Event.SCROLL, onTextDisplayScroll);
         textDisplay = null;
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   override protected function createChildren():void {
      super.createChildren();
      if (!textDisplay) {
         textDisplay = StyleableTextField(createInFontContext(StyleableTextField));
         textDisplay.styleName = this;
         textDisplay.editable = false;
         textDisplay.selectable = false;
         textDisplay.wordWrap = true;
         textDisplay.autoSize = TextFieldAutoSize.LEFT;
         textDisplay.useTightTextBounds = false;
         textDisplay.addEventListener(Event.SCROLL, onTextDisplayScroll);
         addChild(textDisplay);
      }
      FlexGlobals.topLevelApplication.addEventListener(ResizeEvent.RESIZE, onAppResize);
   }

   override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
      super.layoutContents(unscaledWidth, unscaledHeight);
      var paddingLeft:Number = getStyle("paddingLeft");
      var paddingRight:Number = getStyle("paddingRight");
      var paddingTop:Number = getStyle("paddingTop");
      var paddingBottom:Number = getStyle("paddingBottom");
      var unscaledTextWidth:Number = unscaledWidth - paddingLeft - paddingRight;
      var unscaledTextHeight:Number = unscaledHeight - paddingTop - paddingBottom;
      setElementSize(textDisplay, unscaledTextWidth, unscaledTextHeight);
      setElementPosition(textDisplay, paddingRight, paddingTop);
      invalidateSize();
   }

   override protected function measure():void {
      super.measure();
      var paddingTop:Number = getStyle("paddingTop");
      var paddingBottom:Number = getStyle("paddingBottom");
      var parentPaddingRight:Number = Utils_Layout.getParentPaddingRight(hostComponent);
      var parentPaddingLeft:Number = Utils_Layout.getParentPaddingLeft(hostComponent);
      var textHeight:Number = getStyle("fontSize") as Number;
      if (textDisplay)
         textHeight = textDisplay.measuredTextSize.y;
      measuredHeight = textHeight + paddingTop + paddingBottom;
      measuredMinHeight = textHeight + paddingTop + paddingBottom;
      measuredWidth = Math.max(0, hostComponent.parent.width - (parentPaddingLeft + parentPaddingRight));
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private function onAppResize(event:ResizeEvent):void {
      invalidateDisplayList();
   }

   private function onTextDisplayScroll(event:Event):void {
      if (scrollable)
         return;
      // dmccarroll 20121206 - this is the only way I've found to 'disable' scrolling on a StyleableTextField - there must be a better way (?)
      if (textDisplay.scrollV != 1)
         textDisplay.scrollV = 1;
   }

}
}






























