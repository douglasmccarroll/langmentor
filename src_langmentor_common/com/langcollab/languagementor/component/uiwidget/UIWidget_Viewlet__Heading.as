/*
 *  Copyright 2018 Brightworks, Inc.
 *
 *  This file is part of Language Mentor.
 *
 *  Language Mentor is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Language Mentor is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Language Mentor.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

package com.langcollab.languagementor.component.uiwidget {
import com.brightworks.util.Utils_Text;

import mx.core.ScrollPolicy;
import mx.events.FlexEvent;

public class UIWidget_Viewlet__Heading extends UIWidget_TextArea_NonEditable implements IUIWidget_Text {
   
   private static const _HEADING_MULTIPLIER:Number = 2;

   private var _isDisposed:Boolean;

   public function UIWidget_Viewlet__Heading() {
   }

   override public function dispose():void {
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
   }

   override protected function onPreinitialize(event:FlexEvent):void {
      super.onPreinitialize(event);
      var fontSize:uint =
            (fontSizeMultiplier > 0) ?
                  Math.round(Utils_Text.getStandardFontSize() * fontSizeMultiplier * _HEADING_MULTIPLIER) :
                  Utils_Text.getStandardFontSize() * _HEADING_MULTIPLIER;
      setStyle("fontSize", fontSize);
      setStyle("verticalScrollPolicy", ScrollPolicy.OFF);
   }
}
}
