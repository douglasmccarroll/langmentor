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
import com.brightworks.base.Callbacks;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_AIR;

public class Command_UpdateAvailableLessonDownloadsInfo extends Command_UpdateLibraryInfoBase {
   private var _isDisposed:Boolean = false;

   // --------------------------------------------
   //
   //           Public Methods
   //
   // --------------------------------------------

   public function Command_UpdateAvailableLessonDownloadsInfo(callbacks:Callbacks) {
      super();
      Log.debug("Command_UpdateAvailableLessonDownloadsInfo constructor");
      this.callbacks = callbacks;
      techReport = new Command_UpdateAvailableLessonDownloadsInfoTechReport();
   }

   override public function dispose():void {
      Log.debug("Command_UpdateAvailableLessonDownloadsInfo.dispose()");
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (techReport) {
         // techReport is disposed by view
         techReport = null;
      }
   }

   override public function execute():void {
      Log.info("Command_UpdateAvailableLessonDownloadsInfo.execute()");
      if (_isDisposed)
         return;
      includeUserAddedLibraries = true;
      includeLessonInfo = true;
      includeRecommendedLibraries = model.useRecommendedLibraries;
      super.execute();
   }

   // --------------------------------------------
   //
   //           Protected Methods
   //
   // --------------------------------------------

   override protected function startLanguageSpecificInfoFileDownloads():void {
      Log.info("Command_UpdateAvailableLessonDownloadsInfo.startLanguageSpecificInfoFileDownloads()");
      if (_isDisposed)
         return;
      Log.debug("Command_UpdateAvailableLessonDownloadsInfo.startLanguageSpecificInfoFileDownloads() - not disposed yet");
      var appVersion:Number = Utils_AIR.appVersionNumber;
      if (appVersion < model.configFileInfo.mostRecentVersionRequiredDataSchemaVersion) {
         Log.info("Command_UpdateAvailableLessonDownloadsInfo.startLanguageSpecificInfoFileDownloads(): appVersion < mostRecentVersionRequiredDataSchemaVersion");
         Log.info("     mostRecentVersionRequiredDataSchemaVersion: " + model.configFileInfo.mostRecentVersionRequiredDataSchemaVersion);
         Log.info("     appVersion: " + appVersion);
         Command_UpdateAvailableLessonDownloadsInfoTechReport(techReport).isAppVersionLowerThanRequiredDataSchemaVersion = true;
         reportResultsAndDispose();
         return;
      }
      super.startLanguageSpecificInfoFileDownloads();
   }

}
}


