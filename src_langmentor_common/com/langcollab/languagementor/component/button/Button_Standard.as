package com.langcollab.languagementor.component.button {

import com.brightworks.resource.Resources_Audio;
import com.brightworks.skins.button.ButtonSkin_Simple1;

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import spark.components.Button;

public class Button_Standard extends Button{

   public var color:uint;

   private var _isClickActive:Boolean;
   private var _isDisposed:Boolean;
   private var _timer:Timer;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function Button_Standard(color:uint = 0x000099) {
      super();
      this.color = color;
      percentHeight = 100;
      percentWidth = 100;
      setStyle("skinClass", ButtonSkin_Simple1);
      addEventListener(MouseEvent.CLICK, onClick);
   }

   public function dispose():void
   {
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
      Resources_Audio.CLICK.play();
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
