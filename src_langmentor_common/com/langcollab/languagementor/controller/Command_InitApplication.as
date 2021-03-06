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

import com.brightworks.base.Callbacks;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_AIR;
import com.brightworks.util.Utils_File;
import com.brightworks.util.Utils_System;
import com.langcollab.languagementor.constant.Constant_MentorTypeSpecific;
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
      appStatePersistenceManager.isDataWipeActivityBlockActive = false;
      if (!Utils_System.isRunningOnDesktop()) {
         // This may be needed on iOS, and may be needed on Android at some point.
         // It breaks when set while running in the AIR simulator on the desktop.
         File.documentsDirectory.preventBackup = true;
      }
      if ((!appStatePersistenceManager.retrieveIsCurrAppVersionSaved()) || (!Utils_Database.doesDBFileExist(Utils_LangCollab.sqLiteDatabaseFileDirectoryURL))) {
         // Either this app has never been installed, or it has been uninstalled. In the latter case,
         // there may still be data on the SD card. We want to start from a clean slate in this case,
         // so we delete all app data.
         Utils_LangCollab.wipeData(model, appStatePersistenceManager, lessonDownloadController, audioController);
         appStatePersistenceManager.isDataWipeActivityBlockActive = false;
         Utils_File.deleteDirectory(Utils_AIR.applicationStorageDirectory);
         Utils_File.ensureDirectoryExists(Utils_LangCollab.sqLiteDatabaseFileDirectoryURL);
         Utils_Database.ensureDBFileExists(Utils_LangCollab.sqLiteDatabaseFileURL, appStatePersistenceManager);
         model.init();
      }
      else if ((!(appStatePersistenceManager.retrieveIsDataSchemaAppVersionSaved())) ||
            (appStatePersistenceManager.retrieveDataSchemaAppVersion() < Constant_MentorTypeSpecific.MINIMUM_SUPPORTED_DATA_SCHEMA_APP_VERSION)) {
         // Our data schema's version is lower than our current minimum supported data schema version.
         // In this situation we delete all data.
         // This will only happen if/when a user upgrades to a new version. Hopefully it won't be too irritating or disconcerting.
         // In the future we should find ways to support previous data schemas, if possible, but at this
         // point we don't have enough resources to do this.
         //// The message in the Upgrade screen that encourages users to upgrade to a new version doesn't warn them if their data will get wiped here.
         //// To accomplish this we'd need to add a "mostRecentVersionMinimumSupportedDataSchema" value to mentor type files, and it would need
         //// to be set to the same value as MINIMUM_SUPPORTED_DATA_SCHEMA_APP_VERSION.
         Utils_LangCollab.wipeData(model, appStatePersistenceManager, lessonDownloadController, audioController);
         model.init();
      }
      else {
         Utils_Database.ensureDBFileExists(Utils_LangCollab.sqLiteDatabaseFileURL, appStatePersistenceManager);
         model.init();
      }
      appStatePersistenceManager.isDataWipeActivityBlockActive = false;
      appStatePersistenceManager.persistCurrAppVersion(Utils_AIR.appVersionNumber);
      lessonDownloadController.init();
      //Utils_ANEs.googleAnalyticsTrackAppStartup(Utils_LangCollab.appVersion);
      result();
      dispose();
   }

}
}








