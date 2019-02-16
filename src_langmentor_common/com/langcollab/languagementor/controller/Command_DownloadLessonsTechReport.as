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
import com.brightworks.interfaces.IDisposable;
import com.brightworks.techreport.ITechReport;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Dispose;

public class Command_DownloadLessonsTechReport implements IDisposable, ITechReport {
   public var downloadProcessCount_Failed:int = 0;
   public var downloadProcessCount_Started:int = 0;
   public var downloadProcessCount_Succeeded:int = 0;
   public var isAllDownloadProcessesSucceededOrFailed:Boolean = false;
   public var techReportList_DownloadProcessFailures:Array = [];
   public var techReportList_DownloadProcessSuccesses:Array = [];

   private var _isDisposed:Boolean = false;

   public function Command_DownloadLessonsTechReport() {
      Log.debug("Command_DownloadLessonsTechReport - Constructor");
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      Log.debug("Command_DownloadLessonsTechReport.dispose()");
      if (techReportList_DownloadProcessFailures.length > 0) {
         Utils_Dispose.disposeArray(techReportList_DownloadProcessFailures, true);
         techReportList_DownloadProcessFailures = null;
      }
      if (techReportList_DownloadProcessSuccesses) {
         Utils_Dispose.disposeArray(techReportList_DownloadProcessSuccesses, true);
         techReportList_DownloadProcessSuccesses = null;
      }
   }
}
}
