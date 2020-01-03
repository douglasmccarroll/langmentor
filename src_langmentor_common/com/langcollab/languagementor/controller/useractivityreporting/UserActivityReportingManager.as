/*
 *  Copyright 2019 Brightworks, Inc.
 *
 *  This file is part of Language Mentor.
 *
 *  Language Mentor is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Language Mentor is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Language Mentor.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

package com.langcollab.languagementor.controller.useractivityreporting {

import com.brightworks.constant.Constant_Private;
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.interfaces.IUserDataReportingConfigProvider;
import com.brightworks.util.Utils_AWS;
import com.brightworks.util.Utils_System;
import com.brightworks.util.singleton.SingletonManager;
import com.langcollab.languagementor.model.MainModel;

public class UserActivityReportingManager implements IManagedSingleton{

   private static var _configProvider:IUserDataReportingConfigProvider;
   private static var _instance:UserActivityReportingManager;
   private static var _model:MainModel;

   public function UserActivityReportingManager(manager:SingletonManager) {
      _instance = this;
   }

   public static function getInstance():UserActivityReportingManager {
      if (!(_instance))
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function initSingleton():void {
      _model = MainModel.getInstance();
   }

   public static function reportActivityIfUserHasActivatedReporting(activity:UserActivity):void {
      /////  Need "if activated" code instead of "if beta"
      if (!Utils_System.isAlphaOrBetaVersion()) {
         return;
      }


      var serverURL:String;
      if (_configProvider) {
         serverURL = _configProvider.getUserActivityReportingURL();
      }
      else {
         serverURL = Constant_Private.DEFAULT_CONFIG_INFO__USER_ACTIVITY_REPORTING_URL;
      }


      var o:Object = new Object();



      ///// Move this stuff into UserActivity?
      o["userFirstName"] = "Beta";
      o["userLastName"] = "User";
      o["userOrganization"] = "Brightworks";
      o["userDepartment"] = "The Language Collaborative";
      o["userGroup"] = "German Studies";
      o["userSubgroup"] = "Advanced German";
      o["project"] = "User Activity Reporting - QA";

      if (activity.activityType) {
         o["activityType"] = activity.activityType;
      }
      if (activity.autoPlay_AutoAdvanceLesson) {
         o["autoPlay_AutoAdvanceLesson"] = "true";
      }
      if (activity.chunkIndex) {
         o["chunkIndex"] = activity.chunkIndex;
      }
      if (activity.chunkIndex_New) {
         o["chunkIndex_New"] = activity.chunkIndex_New;
      }
      if (activity.chunkIndex_Previous) {
         o["chunkIndex_Previous"] = activity.chunkIndex_Previous;
      }
      if (activity.iKnowThis_AllChunksInLessonSuppressed) {
         o["iKnowThis_AllChunksInLessonSuppressed"] = "true";
      }
      if (activity.learningModeDisplayName) {
         o["learningModeDisplayName"] = activity.learningModeDisplayName;
      }
      if (activity.learningModeDisplayName_New) {
         o["learningModeDisplayName_New"] = activity.learningModeDisplayName_New;
      }
      if (activity.learningModeDisplayName_Previous) {
         o["learningModeDisplayName_Previous"] = activity.learningModeDisplayName_Previous;
      }
      if (activity.lessonId) {
         o["lessonId"] = activity.lessonId;
      }
      if (activity.lessonId_New) {
         o["lessonId_New"] = activity.lessonId_New;
      }
      if (activity.lessonId_Previous) {
         o["lessonId_Previous"] = activity.lessonId_Previous;
      }
      if (activity.lessonName_NativeLanguage) {
         o["lessonName_NativeLanguage"] = activity.lessonName_NativeLanguage;
      }
      if (activity.lessonName_NativeLanguage_New) {
         o["lessonName_NativeLanguage_New"] = activity.lessonName_NativeLanguage_New;
      }
      if (activity.lessonName_NativeLanguage_Previous) {
         o["lessonName_NativeLanguage_Previous"] = activity.lessonName_NativeLanguage_Previous;
      }
      if (activity.lessonProviderId) {
         o["lessonProviderId"] = activity.lessonProviderId;
      }
      if (activity.lessonProviderId_New) {
         o["lessonProviderId_New"] = activity.lessonProviderId_New;
      }
      if (activity.lessonProviderId_Previous) {
         o["lessonProviderId_Previous"] = activity.lessonProviderId_Previous;
      }
      if (activity.lessonVersion) {
         o["lessonVersion"] = activity.lessonVersion;
      }
      if (activity.lessonVersion_New) {
         o["lessonVersion_New"] = activity.lessonVersion_New;
      }
      if (activity.lessonVersion_Previous) {
         o["lessonVersion_Previous"] = activity.lessonVersion_Previous;
      }
      var jsonText:String = JSON.stringify(o);

      /*
      trace("-");
      trace("-");
      for (var s:String in o) {  /////
         trace(s + ": " + o[s] );
      }
      trace("-");
      trace("-");
      */

      Utils_AWS.sendUserActivityReportingToServer(serverURL, jsonText);
   }

   public static function setConfigProvider(cp:IUserDataReportingConfigProvider):void {
      _configProvider = cp;
   }



}
}
