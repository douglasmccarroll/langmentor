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
import com.brightworks.base.Callbacks;
import com.brightworks.util.Log;
import com.brightworks.vo.IVO;
import com.langcollab.languagementor.model.MainModelDBOperationReport;

import flash.utils.Dictionary;

public class Command_Data_UpdateVosOfType extends Command_Base__LangMentor {
   public var index_propNames_to_newValues:Dictionary = new Dictionary();
   public var index_propNames_to_selectValues:Dictionary = new Dictionary();

   private var _voClass:Class;


   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function Command_Data_UpdateVosOfType(voClass:Class, callbacks:Callbacks = null) {
      super();
      Log.debug("Command_Data_UpdateVosOfType - Constructor");
      _voClass = voClass;
      this.callbacks = callbacks;
   }

   private var _isDisposed:Boolean = false;

   override public function dispose():void {
      Log.debug("Command_Data_UpdateVosOfType.dispose()");
      super.dispose();
      if (_isDisposed)
         _isDisposed = true;
      return;
      model = null;
   }

   public function execute():Command_Data_UpdateVosOfTypeTechReport {
      Log.debug("Command_Data_UpdateVosOfType.execute()");
      var result:Command_Data_UpdateVosOfTypeTechReport = new Command_Data_UpdateVosOfTypeTechReport();
      var vo:IVO = new _voClass();
      var updatedPropNames:Array = [];
      for (var propName:String in index_propNames_to_newValues) {
         if (!Object(vo).hasOwnProperty(propName)) {
            Log.warn("Command_Data_UpdateVosOfType.execute(): specified prop name does not exist in vo class: " + propName);
            return result;
         }
         updatedPropNames.push(propName);
         vo[propName] = index_propNames_to_newValues[propName];
      }
      var modelReport:MainModelDBOperationReport = model.updateVOsOfType_NoKeyPropChangesAllowed("Command_Data_UpdateVosOfType.execute", vo, updatedPropNames, index_propNames_to_selectValues);
      if (modelReport.isAnyProblems) {
         Log.info(["Command_Data_UpdateVosOfType.execute(): Problem updating DB", modelReport]);
         result.isSuccessful = false;
         result.mainModelDBOperationReport = modelReport;
      }
      else {
         Log.debug("Command_Data_UpdateVosOfType.execute(): command has completed successfully");
         modelReport.dispose();
         result.isSuccessful = true;
      }
      dispose();
      return result;
   }

}
}


















