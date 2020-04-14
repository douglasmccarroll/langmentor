/*
    Copyright 2018 Brightworks, Inc.

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
package com.langcollab.languagementor.controller {

import com.brightworks.util.Log;
import com.langcollab.languagementor.constant.Constant_UserActionTypes;
import com.langcollab.languagementor.controller.useractionreporting.UserAction;
import com.langcollab.languagementor.controller.useractionreporting.UserActionReportingManager;

public class Command_ChangeCurrentLearningMode extends Command_Base__LangMentor {
   private var _isDisposed:Boolean = false;
   private var _newLearningModeId:uint;

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function Command_ChangeCurrentLearningMode(newLearningModeId:uint) {
      super();
      Log.debug("Command_ChangeCurrentLearningMode - Constructor");
      _newLearningModeId = newLearningModeId;
   }

   override public function dispose():void {
      Log.debug("Command_ChangeCurrentLearningMode.dispose()");
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      model = null;
   }

   public function execute():void {
      Log.info("Command_ChangeCurrentLearningMode.execute()");
      model.currentLearningModeId = _newLearningModeId;
      appStatePersistenceManager.persistSelectedLearningModeId(_newLearningModeId);
      audioController.onLearningModeIdChange();
      reportUserActivity();
      dispose();
   }

   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************

   private function reportUserActivity():void {
      var activity:UserAction = new UserAction();
      activity.actionType = Constant_UserActionTypes.LEARNING_MODES__SELECT_NEW;
      activity.learningModeDisplayName_New = model.getLearningModeDisplayNameFromId(_newLearningModeId);
      UserActionReportingManager.reportActivityIfUserHasActivatedReporting(activity);
   }




}
}
