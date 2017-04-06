package com.langcollab.languagementor.component.button {

import com.brightworks.resource.Resources_Audio;
import com.brightworks.util.Utils_Button;
import com.brightworks.util.Utils_Graphic;
import com.brightworks.util.Utils_Text;

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.ColorTransform;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;

import mx.core.UIComponent;
import mx.events.FlexEvent;
import mx.utils.ColorUtil;

import spark.components.supportClasses.StyleableTextField;

import spark.core.SpriteVisualElement;

public class Button_Standard extends UIComponent{

   public var color:uint;

   private var _isClickActive:Boolean;
   private var _isDisposed:Boolean;
   private var _spriteVisualElement:SpriteVisualElement;
   private var _textField:StyleableTextField;
   private var _timer:Timer;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private var _fontSize:int;
   private var _fontSizeChanged:Boolean;

   public function set fontSize(value:int):void
   {
      _fontSize = value;
      _fontSizeChanged = true;
   }

   private var _text:String;
   private var _textChanged:Boolean;

   public function get text():String
   {
      return _text;
   }

   public function set text(value:String):void
   {
      _text = value;
      _textChanged = true;
      invalidateProperties();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function Button_Standard(color:uint) {
      super();
      this.color = color;
      percentHeight = 100;
      percentWidth = 100;
      _spriteVisualElement = new SpriteVisualElement();
      //_spriteVisualElement.alpha = 0;
      addChild(_spriteVisualElement);
      _textField = new StyleableTextField();
      _textField.autoSize = TextFieldAutoSize.CENTER;
      _textField.editable = false;
      _textField.multiline = true;
      _textField.selectable = false;
      _textField.wordWrap = true;
      _textField.setStyle("fontFamily", Utils_Text.getDefaultFont());
      // StyleableTextField breaks if the next 2 lines aren't here
      _textField.setStyle("fontAntiAliasType", AntiAliasType.NORMAL);
      _textField.setStyle("fontGridFitType", GridFitType.PIXEL);
      _textField.setStyle("textAlign", "center");
      _textField.setStyle("color", 0xFFFFFF);
      _textField.setStyle("fontSize", Math.round(Utils_Text.getStandardFontSize() * 1.6));
      _textField.commitStyles();
      addChild(_textField);
      addEventListener(MouseEvent.CLICK, onClick);
      addEventListener(FlexEvent.PREINITIALIZE, onPreinitialize);
   }

   public function dispose():void
   {
      if (_isDisposed)
         return;
      _isDisposed = true;
      _spriteVisualElement = null;
      _textField = null;
      removeEventListener(MouseEvent.CLICK, onClick);
      removeEventListener(FlexEvent.PREINITIALIZE, onPreinitialize);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   override protected function commitProperties():void
   {
      super.commitProperties();
      doCommitProperties();
   }

   protected function doCommitProperties():void
   {
      if (_fontSizeChanged)
      {
         _textField.setStyle("fontSize", _fontSize);
         _textField.commitStyles();
         _fontSizeChanged = false;
         invalidateDisplayList();
      }
      if (_textChanged)
      {
         _textField.text = _text;
         _textChanged = false;
         invalidateDisplayList();
      }
   }

   override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
   {
      super.updateDisplayList(unscaledWidth, unscaledHeight);
      _spriteVisualElement.height = height;
      _spriteVisualElement.width = width;
      _spriteVisualElement.x = 0;
      _spriteVisualElement.y = 0;
      var brightnessMultiplier:Number = _isClickActive ? 1.3 : 1;
      Utils_Graphic.drawBevelledSurface(
            _spriteVisualElement,
            color,
            brightnessMultiplier,
            Utils_Button.computeBevelButtonStandardBevelThickness(_spriteVisualElement),
            Utils_Button.computeBevelButtonStandardBevelThickness(_spriteVisualElement));
      _textField.width = width;
      _textField.x = 0;
      _textField.y = (height - _textField.height) / 2;

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

   private function onPreinitialize(event:FlexEvent):void
   {
      doCommitProperties();
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
