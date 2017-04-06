package com.langcollab.languagementor.component.learningmodelist {
   import com.brightworks.component.button.NormalButton;
import com.brightworks.util.Utils_Text;

public class LearningModeListHelpButton extends NormalButton {
      public function LearningModeListHelpButton() {
         super();
         label = "?";
         setStyle("fontSize", Utils_Text.getStandardFontSize() * 2);
      }
   }
}
