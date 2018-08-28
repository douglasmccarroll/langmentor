package com.langcollab.languagementor.component.uiwidget {
import spark.components.HGroup;
import spark.core.SpriteVisualElement;

public class UIWidget_Viewlet__Bullet_Text extends HGroup implements IUIWidget_Text {
   private static const _INDENT_PERCENT:uint = 8;

   private var _bulletGraphic:SpriteVisualElement;
   private var _textWidget:UIWidget_Viewlet__Text;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Getters / Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private var _text:String;
   private var _textDirty:Boolean = false;

   public function get text():String {
      return _text;
   }

   public function set text(value:String):void {
      _text = value;
      _textDirty = true;
      invalidateProperties();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function UIWidget_Viewlet__Bullet_Text() {
      percentWidth = 100;
   }

   public function dispose():void {

   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   override protected function commitProperties():void {
      super.commitProperties();
      if (_textDirty) {
         _textDirty = false;
         _textWidget.text = _text;
      }
   }

   override protected function createChildren():void {
      super.createChildren();
      _bulletGraphic = new SpriteVisualElement();
      _bulletGraphic.percentHeight = 100;
      _bulletGraphic.percentWidth = _INDENT_PERCENT;
      addElement(_bulletGraphic);
      _textWidget = new UIWidget_Viewlet__Text();
      _textWidget.percentWidth = 100 - _INDENT_PERCENT;
      _textWidget.text = _text;
      addElement(_textWidget);
   }

   override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
      super.updateDisplayList(unscaledWidth, unscaledHeight);
      var indentWidth:Number = width * (_INDENT_PERCENT / 100);
      var dotX:int = Math.round(indentWidth * .5);
      var dotY:int = Math.round(_textWidget.firstLineCenterYPosition);
      var dotRadius:int = Math.round(_textWidget.firstLineHeight / 4);
      _bulletGraphic.graphics.clear();
      _bulletGraphic.graphics.beginFill(0x000000);
      _bulletGraphic.graphics.drawCircle(dotX, dotY, dotRadius);
      _bulletGraphic.graphics.endFill();
   }

}
}
