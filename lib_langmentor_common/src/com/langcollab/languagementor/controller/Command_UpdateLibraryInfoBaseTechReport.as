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
    import com.brightworks.interfaces.IDisposable;
    import com.brightworks.techreport.ITechReport;
    import com.brightworks.techreport.TechReport;
    import com.brightworks.util.Log;
    import com.brightworks.util.Utils_Dispose;
    import com.langcollab.languagementor.model.ConfigFileInfoTechReport;

    import flash.utils.Dictionary;

    public class Command_UpdateLibraryInfoBaseTechReport extends TechReport implements ITechReport, IDisposable
    {
        public var index_languageSpecificFileName_to_fileDownloaderErrorReport:Dictionary;
        public var isAppVersionIsLowerThanMinimumClientVersion_LibraryListAccess:Boolean = false;
        public var isLanguageSpecificInfoFileDownloadFailure_DualLanguage:Boolean = false;
        public var isLanguageSpecificInfoFileDownloadFailure_SingleLanguage:Boolean = false;
        public var isLanguageSpecificInfoFileXMLParsingFailure_DualLanguage:Boolean = false;
        public var isLanguageSpecificInfoFileXMLParsingFailure_SingleLanguage:Boolean = false;
        public var isLoadConfigFileInfoFailure:Boolean = false;
        public var isProcessTimedOut:Boolean = false;
        public var configFileInfoTechReport:ConfigFileInfoTechReport;
        public var list_LibraryURLs_UnfinishedLibraryInfoDownloadsAtTimeout:Array;
        public var list_TechReports_AllLibraryInfoDownloads:Array = [];
        public var list_TechReports_ProblematicLibraryInfoDownloads:Array = [];
        public var problemDescriptionList:Vector.<String> = new Vector.<String>();

        private var _isDisposed:Boolean = false;

        public function Command_UpdateLibraryInfoBaseTechReport()
        {
            Log.debug("Command_UpdateLibraryInfoBaseTechReport - Constructor");
        }

        override public function dispose():void
        {
            super.dispose();
            if (_isDisposed)
                return;
            _isDisposed = true
            Log.debug("Command_UpdateLibraryInfoBaseTechReport.dispose()");
            if (index_languageSpecificFileName_to_fileDownloaderErrorReport)
            {
                Utils_Dispose.disposeDictionary(index_languageSpecificFileName_to_fileDownloaderErrorReport, true);
                index_languageSpecificFileName_to_fileDownloaderErrorReport = null;
            }
            if (configFileInfoTechReport)
            {
                configFileInfoTechReport = null;
            }
            if (list_LibraryURLs_UnfinishedLibraryInfoDownloadsAtTimeout)
            {
                Utils_Dispose.disposeArray(list_LibraryURLs_UnfinishedLibraryInfoDownloadsAtTimeout, true);
                list_LibraryURLs_UnfinishedLibraryInfoDownloadsAtTimeout = null;
            }
            if (list_TechReports_AllLibraryInfoDownloads)
            {
                Utils_Dispose.disposeArray(list_TechReports_AllLibraryInfoDownloads, true);
                list_TechReports_AllLibraryInfoDownloads = null;
            }
            if (list_TechReports_ProblematicLibraryInfoDownloads)
            {
                Utils_Dispose.disposeArray(list_TechReports_ProblematicLibraryInfoDownloads, true);
                list_TechReports_ProblematicLibraryInfoDownloads = null;
            }
        }
    }
}
