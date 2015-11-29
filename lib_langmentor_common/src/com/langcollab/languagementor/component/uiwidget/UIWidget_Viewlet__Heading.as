package com.langcollab.languagementor.component.uiwidget
{
    import com.brightworks.util.Utils_Text;

    import mx.core.ScrollPolicy;
    import mx.events.FlexEvent;

    public class UIWidget_Viewlet__Heading extends UIWidget_TextArea_NonEditable implements IUIWidget_Text
    {
        private static const _HEADING_MULTIPLIER:Number = 1.8;

        private var _isDisposed:Boolean;

        public function UIWidget_Viewlet__Heading()
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
            var fontSize:uint = 
                (fontSizeMultiplier > 0) ? 
                Math.round(Utils_Text.getStandardFontSize() * fontSizeMultiplier * _HEADING_MULTIPLIER) : 
                Utils_Text.getStandardFontSize() * _HEADING_MULTIPLIER;
            setStyle("fontSize", fontSize);
            setStyle("verticalScrollPolicy", ScrollPolicy.OFF);
        }
    }
}
