/*
Copyright 2021 Brightworks, Inc.

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
import com.brightworks.interfaces.IDisposable;
import com.brightworks.techreport.ITechReport;
import com.brightworks.techreport.TechReport;
import com.brightworks.util.Log;
import com.langcollab.languagementor.model.MainModelDBOperationReport;

public class Command_AddLibraryErrorReport extends TechReport implements ITechReport, IDisposable {
   public static const ERROR_TYPE__CANNOT_FIND_LIBRARY:String = "errorType_CannotFindLibrary";
   public static const ERROR_TYPE__SAVE_TO_DB_FAILED:String = "errorType_SaveToDBFailed";
   public static const ERROR_TYPE__LIBRARY_ALREADY_IN_DB:String = "errorType_LibraryAlreadyInDB";
   public static const ERROR_TYPE__TIMEOUT:String = "errorType_Timeout";
   public static const ERROR_TYPE__UNABLE_TO_ACCESS_INTERNET:String = "errorType_UnableToAccessInternet";

   public var commandStatusAtTimeOfFailure:String;
   public var mainModelDBOperationReport:MainModelDBOperationReport;


   private var _isDisposed:Boolean = false;

   public function Command_AddLibraryErrorReport() {
      Log.debug("Command_AddLibraryErrorReport - Constructor");
   }

   override public function dispose():void {
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      Log.debug("Command_AddLibraryErrorReport.dispose()");
      if (mainModelDBOperationReport) {
         mainModelDBOperationReport.dispose();
         mainModelDBOperationReport = null;
      }
   }
}
}
