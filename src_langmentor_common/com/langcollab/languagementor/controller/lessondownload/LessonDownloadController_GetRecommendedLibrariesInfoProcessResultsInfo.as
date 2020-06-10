/*
Copyright 2020 Brightworks, Inc.

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
package com.langcollab.languagementor.controller.lessondownload {
import com.brightworks.util.Utils_Dispose;
import com.langcollab.languagementor.controller.Command_GetRecommendedLibariesInfoTechReport;

public class LessonDownloadController_GetRecommendedLibrariesInfoProcessResultsInfo {
   public var checkedLibraryCount:uint = 0;
   public var command_GetRecommendedLibrariesInfoTechReport:Command_GetRecommendedLibariesInfoTechReport;
   public var problematicLibraryCount:uint = 0;
   public var problematicLibraryNameList:Array;

   public function dispose():void {
      if (command_GetRecommendedLibrariesInfoTechReport) {
         command_GetRecommendedLibrariesInfoTechReport.dispose();
         command_GetRecommendedLibrariesInfoTechReport = null;
      }
      if (problematicLibraryNameList) {
         Utils_Dispose.disposeArray(problematicLibraryNameList, true);
         problematicLibraryNameList = null;
      }
   }
}
}
