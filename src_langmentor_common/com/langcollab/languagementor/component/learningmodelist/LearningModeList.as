/*
Copyright 2008 - 2013 Brightworks, Inc.

This file is part of Language Mentor.

Language Mentor is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Language Mentor is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Language Mentor.  If not, see <http://www.gnu.org/licenses/>.
*/
package com.langcollab.languagementor.component.learningmodelist {
import com.brightworks.component.list.DisplayAllItemsList;
import com.langcollab.languagementor.event.Event_LearningModeList;

[Event(name="event_LearningModeList_DisplayLearningModeHelp", type="com.langcollab.languagementor.event.Event_LearningModeList")]

public class LearningModeList extends DisplayAllItemsList {
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function LearningModeList() {
      super();
   }

   public function dispatchDisplayHelpEvent(data:Object):void {
      var e:Event_LearningModeList = new Event_LearningModeList(Event_LearningModeList.DISPLAY_LEARNING_MODE_HELP);
      e.learningModeId = data.value;
      dispatchEvent(e);
   }


}
}
