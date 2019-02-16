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
import com.brightworks.techreport.ITechReport;
import com.brightworks.techreport.TechReport;
import com.langcollab.languagementor.model.MainModelDBOperationReport;

public class Command_DeleteLessonVersionTechReport extends TechReport implements ITechReport {
   public static const ERROR_TYPE__DELETE_DATA_FAILURE:String = "errorType_DeleteDataFailure";
   public static const ERROR_TYPE__DELETE_FILES_FAILURE:String = "errorType_DeleteFilesFailure";

   public var isSuccess:Boolean;
   public var mainModelDBOperationReport:MainModelDBOperationReport;

   private var _isDisposed:Boolean;

   public function Command_DeleteLessonVersionTechReport() {
      super();
   }

   override public function dispose():void {
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (mainModelDBOperationReport) {
         mainModelDBOperationReport.dispose();
         mainModelDBOperationReport = null;
      }
   }
}
}
