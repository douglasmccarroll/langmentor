package com.langcollab.languagementor.component.itemrenderer
{
    import com.brightworks.component.itemrenderer.BwLabelItemRenderer;
    import com.brightworks.util.Utils_Text;

    public class ItemRenderer_LevelSelectionList extends BwLabelItemRenderer
    {
        public function ItemRenderer_LevelSelectionList()
        {
            super();
        }

        override protected function createLabelDisplay():void
        {
            super.createLabelDisplay();
            labelDisplay.setStyle("fontSize", Math.round(Utils_Text.getStandardFontSize() * 1.7));
        }

    }
}
