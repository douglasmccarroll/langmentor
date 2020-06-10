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
import com.brightworks.interfaces.IDisposable;
import com.langcollab.languagementor.controller.Command_DownloadLessonsTechReport;

public class LessonDownloadController_LessonDownloadProcessResultsInfo implements IDisposable {
   public var command_DownloadLessonsResultsReport:Command_DownloadLessonsTechReport;
   public var lessonCount_DownloadsAttempted:int = -1;
   public var lessonCount_DownloadsFailed:uint = 0;
   public var lessonCount_DownloadsSucceeded:uint = 0;

   private var _isDisposed:Boolean = false;

   public function LessonDownloadController_LessonDownloadProcessResultsInfo() {
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (command_DownloadLessonsResultsReport) {
         command_DownloadLessonsResultsReport.dispose();
         command_DownloadLessonsResultsReport = null;
      }
   }
}
}
