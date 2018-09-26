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
package com.langcollab.languagementor.model {
public class Constant_DataErrorTypes {
   public static const DELETE__REMOVAL_FROM_STORAGE_LISTS_FAILED:String = "delete_removalFromStorageListsFailed";
   public static const DELETE__SOME_VOS_DO_NOT_HAVE_SINGLE_MATCHING_VO_IN_STORAGE_LIST:String = "delete_SomeVOsDoNotHaveSingleMatchingVOInStorageList";
   public static const SQLITE_DB_OPERATION_FAILURE:String = "sqliteDbOperationFailure";
   public static const UPDATE__ANOTHER_SQL_OPERATION_CURRENTLY_IN_PROGRESS:String = "update_AnotherSQLOperationCurrentlyInProgress";

   public function Constant_DataErrorTypes() {
   }
}
}