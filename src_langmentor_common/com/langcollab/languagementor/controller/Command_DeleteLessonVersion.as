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
package com.langcollab.languagementor.controller {
import com.brightworks.util.Log;
import com.brightworks.util.Utils_File;
import com.langcollab.languagementor.model.MainModelDBOperationReport;
import com.langcollab.languagementor.util.Utils_LangCollab;
import com.langcollab.languagementor.vo.LessonVersionVO;

import flash.filesystem.File;

public class Command_DeleteLessonVersion extends Command_Base__LangMentor {

   private var _isDisposed:Boolean = false;
   private var _lessonVersionVO:LessonVersionVO;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function Command_DeleteLessonVersion(lessonVersionVO:LessonVersionVO) {
      super();
      Log.debug("Command_DeleteLessonVersion - Constructor");
      _lessonVersionVO = lessonVersionVO;
   }

   override public function dispose():void {
      Log.debug("Command_DeleteLessonVersion.dispose()");
      super.dispose();
      if (_isDisposed)
         _isDisposed = true;
      return;
      model = null;
   }

   public function execute():Command_DeleteLessonVersionTechReport {
      Log.info("Command_DeleteLessonVersion.execute()");
      var resultReport:Command_DeleteLessonVersionTechReport = new Command_DeleteLessonVersionTechReport();
      var modelReport:MainModelDBOperationReport = model.deleteLessonVersion(_lessonVersionVO);
      if (modelReport.isAnyProblems) {
         resultReport.isSuccess = false;
         resultReport.errorType = Command_DeleteLessonVersionTechReport.ERROR_TYPE__DELETE_DATA_FAILURE;
         resultReport.mainModelDBOperationReport = modelReport;
      }
      else {
         Log.info("Command_DeleteLessonVersion.execute(): lesson deleted in Data - start files delete");
         modelReport.dispose();
         var folderPath:String =
               Utils_LangCollab.downloadedLessonsDirectoryURL +
               File.separator +
               _lessonVersionVO.contentProviderId +
               File.separator +
               _lessonVersionVO.publishedLessonVersionId
         var isDeleteSuccessful:Boolean = Utils_File.deleteDirectory(folderPath);
         if (isDeleteSuccessful) {
            Log.debug("Command_DeleteLessonVersion.execute(): files delete successful");
            resultReport.isSuccess = true;
         }
         else {
            Log.info("Command_DeleteLessonVersion.execute(): files delete failed");
            resultReport.isSuccess = false;
            resultReport.errorType = Command_DeleteLessonVersionTechReport.ERROR_TYPE__DELETE_FILES_FAILURE;
            resultReport.miscInfoList.push(folderPath);
         }
      }
      dispose();
      return resultReport;
   }


}
}


















