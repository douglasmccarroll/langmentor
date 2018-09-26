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

public class Command_UpdateAvailableLessonDownloadsInfoTechReport extends Command_UpdateLibraryInfoBaseTechReport implements ITechReport, IDisposable {
   private var _isDisposed:Boolean = false;

   public function Command_UpdateAvailableLessonDownloadsInfoTechReport() {
      Log.debug("Command_UpdateAvailableLessonDownloadsInfoTechReport - Constructor");
   }

   override public function dispose():void {
      Log.debug("Command_UpdateAvailableLessonDownloadsInfoTechReport.dispose()");
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true
   }
}
}
