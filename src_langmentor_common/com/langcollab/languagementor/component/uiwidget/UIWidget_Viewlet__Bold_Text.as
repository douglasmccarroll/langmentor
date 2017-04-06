package com.langcollab.languagementor.component.uiwidget
{
    import com.brightworks.util.Utils_Text;

    import flash.text.engine.FontWeight;

    import mx.core.ScrollPolicy;
    import mx.events.FlexEvent;

    public class UIWidget_Viewlet__Bold_Text extends UIWidget_TextArea_NonEditable implements IUIWidget_Text
    {
        private var _isDisposed:Boolean;

        public function UIWidget_Viewlet__Bold_Text()
        {
        }

        override public function dispose():void
        {
            super.dispose();
            if (_isDisposed)
                return;
            _isDisposed = true;
        }

        override protected function onPreinitialize(event:FlexEvent):void
        {
            super.onPreinitialize(event);
            var fontSize:uint = (fontSizeMultiplier > 0) ? Math.round(Utils_Text.getStandardFontSize() * fontSizeMultiplier) : Utils_Text.getStandardFontSize();
            setStyle("fontSize", fontSize);
            setStyle("verticalScrollPolicy", ScrollPolicy.OFF);
            setStyle("fontWeight", FontWeight.BOLD);
        }
    }
}
