package com.langcollab.languagementor.component.itemrenderer {
import com.brightworks.component.itemrenderer.BwLabelItemRenderer;

import flash.system.Capabilities;

public class ItemRenderer_LanguageSelectionList extends BwLabelItemRenderer {
   public function ItemRenderer_LanguageSelectionList() {
      super();
   }

   override protected function measure():void {
      super.measure();
      measuredHeight = measuredMinHeight = Math.round(Capabilities.screenDPI * .4);
   }


}
}
