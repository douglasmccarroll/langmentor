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
package com.langcollab.languagementor.util {
import com.brightworks.util.Log;
import com.brightworks.util.Utils_AIR;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.model.appstatepersistence.AppStatePersistenceManager;

import flash.filesystem.File;

public class Utils_Database {

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function Utils_Database() {
   }

   public static function createNewDBFileFromTemplate(sqLiteDatabaseFileURL:String, appStatePersistenceManager:AppStatePersistenceManager):void {
      Log.debug("Utils_Database.createNewDBFileFromTemplate()");
      var dbFile:File = new File(sqLiteDatabaseFileURL);
      var dbTemplateFile:File = File.applicationDirectory.resolvePath(
            Constant_LangMentor_Misc.FILEPATHINFO__DB_TEMPLATE_FOLDER_NAME +
            File.separator +
            Constant_LangMentor_Misc.FILEPATHINFO__DB_TEMPLATE_FILE_NAME);
      if (!dbTemplateFile.exists) {
         Log.fatal("Utils_Database.createNewDBFileFromTemplate(): DB template file not found at: " + dbTemplateFile.nativePath);
      }
      try {
         dbTemplateFile.copyTo(dbFile, true);
      } catch (e:Error) {
         Log.fatal("Utils_Database.createNewDBFileFromTemplate() - Copy DB template file failure - Template: " + dbTemplateFile.nativePath + " New file: " + dbFile.nativePath);
      }
      appStatePersistenceManager.persistDataSchemaAppVersion(Utils_AIR.appVersionNumber);
   }

   public static function doesDBFileExist(sqLiteDatabaseFileURL:String):Boolean {
      var dbFile:File = new File(sqLiteDatabaseFileURL);
      return dbFile.exists;
   }

   public static function ensureDBFileExists(sqLiteDatabaseFileURL:String, appStatePersistenceManager:AppStatePersistenceManager):void {
      Log.debug("Utils_Database.ensureDBFileExists()");
      if (!doesDBFileExist(sqLiteDatabaseFileURL)) {
         createNewDBFileFromTemplate(sqLiteDatabaseFileURL, appStatePersistenceManager);
      }
   }
}
}

