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
package com.langcollab.languagementor.model
{
    import com.brightworks.db.SQLiteTransactionReport;
    import com.brightworks.techreport.ITechReport;
    import com.brightworks.techreport.TechReport;
    import com.brightworks.util.Utils_Dispose;

    import flash.utils.Dictionary;

    public class MainModelDBOperationReport extends TechReport implements ITechReport
    {
        public var diagnosticInfoString:String;
        public var index_dataProblemTypes_by_problematicQueryDataInstances:Dictionary;
        public var isAnyProblems:Boolean;
        public var resultData:Array;
        public var sqliteTransactionReport:SQLiteTransactionReport;
        public var unallowedFieldNameList:Array;

        private var _isDisposed:Boolean;

        public function MainModelDBOperationReport()
        {
        }

        override public function dispose():void
        {
            super.dispose();
            if (_isDisposed)
                return;
            _isDisposed = true;
            if (index_dataProblemTypes_by_problematicQueryDataInstances)
            {
                Utils_Dispose.disposeDictionary(index_dataProblemTypes_by_problematicQueryDataInstances, true);
                index_dataProblemTypes_by_problematicQueryDataInstances = null;
            }
            if (resultData)
            {
                Utils_Dispose.disposeArray(resultData, false);
                resultData = null;
            }
            if (sqliteTransactionReport)
            {
                sqliteTransactionReport.dispose();
                sqliteTransactionReport = null;
            }
            if (unallowedFieldNameList)
            {
                Utils_Dispose.disposeArray(unallowedFieldNameList, true);
                unallowedFieldNameList = null;
            }
        }
    }
}
