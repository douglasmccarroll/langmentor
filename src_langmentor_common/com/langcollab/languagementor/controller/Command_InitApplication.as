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
import com.brightworks.util.Utils_AIR;
import com.brightworks.util.Utils_ANEs;
import com.brightworks.util.Utils_File;
import com.brightworks.util.Utils_System;
import com.langcollab.languagementor.constant.Constant_AppConfiguration;
import com.langcollab.languagementor.util.Utils_Database;
import com.langcollab.languagementor.util.Utils_LangCollab;

import flash.filesystem.File;

import mx.controls.ToolTip;

public class Command_InitApplication extends Command_Base__LangMentor {
   private var _isDisposed:Boolean = false;

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function Command_InitApplication(callbacks:Callbacks) {
      super();
      Log.debug("Command_InitApplication - Constructor");
      this.callbacks = callbacks;
   }

   override public function dispose():void {
      Log.debug("Command_InitApplication.dispose()");
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      model = null;
   }

   public function execute():void {
      Log.info("Command_InitApplication.execute()");
      ToolTip.maxWidth = 150;
      // Next lines are for cases where we're init'ing after data wipe
      // Update: I'm not sure that the above comment is accurate, i.e. I think that these lines are for both a) a first-time use scenario, and b) an after-data-wipe scenario. But I'm not sure, and am not going to take time to research this thoroughly right now.
      appStatePersistenceManager.isDataWipeActivityBlockActive = false;
      if (!appStatePersistenceManager.retrieveIsAutoDownloadLessonsSaved())
         model.autoDownloadLessons = true;
      if (!appStatePersistenceManager.retrieveIsUseRecommendedLibrariesSaved())
         model.useRecommendedLibraries = false;
      if (!Utils_System.isRunningOnDesktop()) {
         // This may be needed on iOS, and may be needed on Android at some point.
         // It breaks when set while running in the AIR simulator on the desktop.
         File.documentsDirectory.preventBackup = true;
      }
      if ((!appStatePersistenceManager.retrieveIsCurrAppVersionSaved()) || (!Utils_Database.doesDBFileExist(Utils_LangCollab.sqLiteDatabaseFileDirectoryURL))) {
         // Either this app has never been installed, or it has been uninstalled. In the latter case,
         // there may still be data on the SD card. We want to start from a clean slate in this case,
         // so we delete all app data.
         Utils_LangCollab.wipeData(model, appStatePersistenceManager, lessonDownloadController);
         Utils_File.deleteDirectory(Utils_AIR.documentStorageDirectoryURL);
         Utils_File.ensureDirectoryExists(Utils_LangCollab.sqLiteDatabaseFileDirectoryURL);
         Utils_Database.ensureDBFileExists(Utils_LangCollab.sqLiteDatabaseFileURL, appStatePersistenceManager);
         model.init();
      }
      else if ((!(appStatePersistenceManager.retrieveIsDataSchemaAppVersionSaved())) ||
            (appStatePersistenceManager.retrieveDataSchemaAppVersion() < Constant_AppConfiguration.APP_VERSION__MINIMUM__SUPPORTED_DATA_SCHEMA)) {
         // Our data schema's app version is lower than our current minimum supported data schema app version.
         // In this situation we delete all data.
         // Messages in the app that encourage users to upgrade to a new version warn them if this will happen.
         // It's possible that users may upgrade without getting such a message, in which case they will not have been warned. ///
         // In the future we should update the data schema in most or all of these cases, but at this
         // point we don't have enough resources to do this.
         Utils_LangCollab.wipeData(model, appStatePersistenceManager, lessonDownloadController);
         model.init();
      }
      else {
         Utils_Database.ensureDBFileExists(Utils_LangCollab.sqLiteDatabaseFileURL, appStatePersistenceManager);
         model.init();
      }
      appStatePersistenceManager.isDataWipeActivityBlockActive = false;
      appStatePersistenceManager.persistCurrAppVersion(Utils_AIR.appVersionNumber);
      lessonDownloadController.init();
      model.retrievePersistedAppStateData();
      //Utils_ANEs.googleAnalyticsTrackAppStartup(Utils_LangCollab.appVersion);
      result();
      dispose();
   }

}
}








