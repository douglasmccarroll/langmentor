/*
    Copyright 2008 - 2013 Brightworks, Inc.

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
package com.langcollab.languagementor.controller
{

import com.brightworks.base.Callbacks;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_AIR;
import com.brightworks.util.Utils_File;
import com.brightworks.util.Utils_System;
import com.langcollab.languagementor.constant.Constant_AppConfiguration;
import com.langcollab.languagementor.util.Utils_Database;
import com.langcollab.languagementor.util.Utils_LangCollab;

import flash.filesystem.File;

import mx.controls.ToolTip;

public class Command_InitApplication extends Command_Base__LangMentor
    {
        private var _isDisposed:Boolean = false;

        // ****************************************************
        //
        //          Public Methods
        //
        // ****************************************************

        public function Command_InitApplication(callbacks:Callbacks)
        {
            super();
            Log.debug("Command_InitApplication - Constructor");
            this.callbacks = callbacks;
        }

        override public function dispose():void
        {
            Log.debug("Command_InitApplication.dispose()");
            super.dispose();
            if (_isDisposed)
                return;
            _isDisposed = true;
            model = null;
        }

        public function execute():void
        {
            Log.info("Command_InitApplication.execute()");
            ToolTip.maxWidth = 150;
            // Next lines are for cases where we're init'ing after data wipe
            appStatePersistenceManager.isDataWipeActivityBlockActive = false;
            if (!appStatePersistenceManager.retrieveIsAutoDownloadLessonsSaved())
                model.autoDownloadLessons = false;
            if (!appStatePersistenceManager.retrieveIsUseRecommendedLibrariesSaved())
                model.useRecommendedLibraries = false;
            if (!Utils_System.isRunningOnDesktop())
            {
                // This may be needed on iOS, and may be needed on Android at some point. 
                // It breaks when set while running in the AIR simulator on the desktop.
                File.documentsDirectory.preventBackup = true;
            }
            if (!appStatePersistenceManager.retrieveIsCurrAppVersionSaved())
            {
                // Either this app has never been installed, or it has been uninstalled. In the latter case,
                // there may still be data on the SD card. We want to start from a clean slate in this case,
                // so we delete all app data.
                Utils_File.deleteDirectory(Utils_AIR.documentStorageDirectoryURL);
                Utils_File.ensureDirectoryExists(Utils_LangCollab.sqLiteDatabaseFileDirectoryURL);
                Utils_Database.ensureDBFileExists(Utils_LangCollab.sqLiteDatabaseFileURL, appStatePersistenceManager);
                model.init();
            }
            else if ((!(appStatePersistenceManager.retrieveIsDataSchemaAppVersionSaved())) || 
                (appStatePersistenceManager.retrieveDataSchemaAppVersion() < Constant_AppConfiguration.APP_VERSION__MINIMUM__SUPPORTED_DATA_SCHEMA))
            {
                // Our data schema's app version is lower than our current minimum supported data schema app version.
                // In this situation we delete all data. (The More|Upgrade option warns the user that this will happen.) In the 
                // future we should update the data schema in most or all of these cases, but at this 
                // point we don't have enough resources to do this.
                Utils_LangCollab.wipeData(model, appStatePersistenceManager, lessonDownloadController);
                model.init();
            }
            else
            {
                Utils_Database.ensureDBFileExists(Utils_LangCollab.sqLiteDatabaseFileURL, appStatePersistenceManager);
                model.init();
            }
            appStatePersistenceManager.persistCurrAppVersion(Utils_AIR.appVersionNumber);
            lessonDownloadController.init();
            model.retrievePersistedAppStateData();
            appUseAnalytics.appStartup(Utils_LangCollab.appVersion);
            result();
            dispose();
        }

    }
}








