package com.langcollab.languagementor.component.button {
import com.brightworks.component.text.CenteredMobileText;
import com.brightworks.resource.Resources_Audio;
import com.brightworks.util.Utils_Text;

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class HomeScreenBackgroundButton extends CenteredMobileText {
   private var _isDisposed:Boolean;
   private var _timer:Timer;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function HomeScreenBackgroundButton() {
      super();
      percentHeight = 100;
      percentWidth = 100;
      addEventListener(MouseEvent.CLICK, onClick);
   }

   override public function dispose():void {
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      removeEventListener(MouseEvent.CLICK, onClick);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   override protected function doInitTextField():void {
      super.doInitTextField();
      textField.setStyle("color", 0x444499);
      textField.setStyle("fontSize", Math.round(Utils_Text.getStandardFontSize() * 1));
   }

   override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
      super.updateDisplayList(unscaledWidth, unscaledHeight);
      drawButtonShape(0xFFBBFF, 0x996699);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function drawButtonShape(borderColor:Number, fillColor:Number):void {
      spriteVisualElement.graphics.lineStyle(1, borderColor, 1, true);
      spriteVisualElement.graphics.beginFill(fillColor, 1);
      spriteVisualElement.graphics.drawRoundRect(
            0,
            0,
            spriteVisualElement.width,
            spriteVisualElement.height,
            12,
            12);
      spriteVisualElement.graphics.endFill();
   }

   private function onClick(event:MouseEvent):void {
      if (event.target == this) {
         // This is the click that onTimer generates - and we only want to respond to user clicks here
         return;
      }
      event.stopImmediatePropagation();
      event.preventDefault();
      Resources_Audio.CLICK.play();
      spriteVisualElement.alpha = .2
      _timer = new Timer(200);
      _timer.addEventListener(TimerEvent.TIMER, onTimer);
      _timer.start();
   }

   private function onTimer(event:TimerEvent):void {
      _timer.stop();
      _timer.addEventListener(TimerEvent.TIMER, onTimer);
      _timer = null;
      spriteVisualElement.alpha = 0;
      dispatchEvent(new MouseEvent(MouseEvent.CLICK));
   }

}
}























