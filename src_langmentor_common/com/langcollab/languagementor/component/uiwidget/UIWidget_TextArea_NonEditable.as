package com.langcollab.languagementor.component.uiwidget {
import flash.text.TextLineMetrics;

import mx.events.FlexEvent;

import spark.components.TextArea;
import spark.components.supportClasses.StyleableTextField;

public class UIWidget_TextArea_NonEditable extends TextArea implements IUIWidget {
   public var fontSizeMultiplier:Number = 0;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function get firstLineCenterYPosition():Number {
      var metrics:TextLineMetrics = StyleableTextField(textDisplay).getLineMetrics(0);
      // 'ascent' is distance from baseline of text to top of ascenders.
      // Adding +2 because http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextLineMetrics.html
      // says that we have a 2 pixel gutter - and experimentation indicates...
      return metrics.ascent * .7;
   }

   public function get firstLineHeight():Number {
      var metrics:TextLineMetrics = StyleableTextField(textDisplay).getLineMetrics(0);
      // 'ascent' is distance from baseline of text to top of ascenders.
      return metrics.ascent;
   }

   /*
    dmccarroll 20121101
    While the htmltext code below works to an extent (i.e. it throws no errors) the text isn't displayed. I suspect that this is due to the
    fact that the skin doesn't size the component correctly, i.e. it's height is zero, but haven't looked into it. In any case,
    we may want to have a separate 'html' widget.

    private var _htmlText:String;
    [Inspectable(category = "Common")]
    public function get htmlText():String
    {
    return _htmlText;
    }
    public function set htmlText(value:String):void
    {
    _htmlText = value;
    var tf:TextFlow = TextConverter.importToFlow(value, TextConverter.TEXT_FIELD_HTML_FORMAT);
    textFlow = tf;
    invalidateSize();
    }*/

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function UIWidget_TextArea_NonEditable() {
      super();
      // Preinitialize event is used by subclasses, so keep this whether or not this class's onPreinitialize() does anything.
      addEventListener(FlexEvent.PREINITIALIZE, onPreinitialize);
   }

   public function dispose():void {
      removeEventListener(FlexEvent.PREINITIALIZE, onPreinitialize);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   protected function onPreinitialize(event:FlexEvent):void {
      // The next two styles aren't supported for the mobile theme :)
      //setStyle("horizontalScrollPolicy", ScrollPolicy.OFF);
      //setStyle("verticalScrollPolicy", ScrollPolicy.OFF);
   }
}
}

