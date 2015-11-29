package com.langcollab.languagementor.component.text
{
    import com.brightworks.component.text.CenteredMobileText;

    public class WhiteCenteredText extends CenteredMobileText
    {
        public function WhiteCenteredText()
        {
            super();
        }

        override protected function doInitTextField():void
        {
            super.doInitTextField();
            textField.setStyle("color", 0xFFFFFF);
        }

    }
}
