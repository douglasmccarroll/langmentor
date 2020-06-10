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
package com.langcollab.languagementor.model {
import com.brightworks.db.SQLiteQueryData_Select;
import com.brightworks.db.SQLiteTransaction;
import com.brightworks.db.SQLiteTransactionReport;
import com.brightworks.util.Log;

import flash.events.EventDispatcher;
import flash.filesystem.File;

public class Data extends EventDispatcher {
   public var dbAccessReportCallback:Function;

   private var _dbFile:File;
   private var _isDisposed:Boolean;

   // --------------------------------------------
   //
   //           Public Methods
   //
   // --------------------------------------------

   public function Data(dbFileURL:String) {
      _dbFile = new File(dbFileURL);
   }


   public function deleteData(queryDataList:Array):SQLiteTransactionReport {
      if (dbAccessReportCallback is Function)
         dbAccessReportCallback();
      Log.info("Data.deleteData()");
      var op:SQLiteTransaction = new SQLiteTransaction(queryDataList);
      var result:SQLiteTransactionReport = op.execute(_dbFile);
      return result;
   }

   public function dispose():void {
      if (_isDisposed)
         return;
   }

   public function insertData(queryDataList:Array, diagnosticInfoString:String = null):SQLiteTransactionReport {
      if (dbAccessReportCallback is Function)
         dbAccessReportCallback();
      Log.info("Data.insertData()");
      var op:SQLiteTransaction = new SQLiteTransaction(queryDataList, diagnosticInfoString);
      var result:SQLiteTransactionReport = op.execute(_dbFile);
      return result;
   }

   public function selectData(queryData:SQLiteQueryData_Select):SQLiteTransactionReport {
      if (dbAccessReportCallback is Function)
         dbAccessReportCallback();
      //var startTime:Number = Utils_DateTime.getCurrentMS_BasedOnDate();
      Log.debug("Data.selectData()");
      var op:SQLiteTransaction = new SQLiteTransaction([queryData]);
      var result:SQLiteTransactionReport = op.execute(_dbFile);
      //var duration:Number = Utils_DateTime.getCurrentMS_BasedOnDate() - startTime;
      //trace("*** " + duration);
      return result;
   }

   public function updateData(queryDataList:Array):SQLiteTransactionReport {
      if (dbAccessReportCallback is Function)
         dbAccessReportCallback();
      Log.info("Data.updateData()");
      var op:SQLiteTransaction = new SQLiteTransaction(queryDataList);
      var result:SQLiteTransactionReport = op.execute(_dbFile);
      return result;
   }

}
}
























