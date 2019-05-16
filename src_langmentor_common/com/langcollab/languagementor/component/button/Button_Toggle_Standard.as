package com.langcollab.languagementor.component.button {

import com.brightworks.skins.button.ButtonSkin_Flat_Blue;
import com.brightworks.util.audio.Utils_Audio_Files;

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import spark.components.ToggleButton;

public class Button_Toggle_Standard extends ToggleButton {

   public var color:uint;

   private var _isClickActive:Boolean;
   private var _isDisposed:Boolean;
   private var _timer:Timer;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function Button_Toggle_Standard() {
      super();
      percentHeight = 100;
      percentWidth = 100;
      addEventListener(MouseEvent.CLICK, onClick);
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      removeEventListener(MouseEvent.CLICK, onClick);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function onClick(event:MouseEvent):void {
      if (_isClickActive)
         return;
      event.stopImmediatePropagation();
      event.preventDefault();
      Utils_Audio_Files.playClick();
      _isClickActive = true;
      _timer = new Timer(200);
      _timer.addEventListener(TimerEvent.TIMER, onTimer);
      _timer.start();
      invalidateDisplayList();
   }

   private function onTimer(event:TimerEvent):void {
      _timer.stop();
      _timer.removeEventListener(TimerEvent.TIMER, onTimer);
      _timer = null;
      dispatchEvent(new MouseEvent(MouseEvent.CLICK));
      _isClickActive = false;
      invalidateDisplayList();
   }

}
}
