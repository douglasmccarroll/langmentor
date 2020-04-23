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

package com.langcollab.languagementor.controller.useractionreporting {

import com.brightworks.constant.Constant_Private;
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.interfaces.IUserDataReportingConfigProvider;
import com.brightworks.util.Utils_AWS;
import com.brightworks.util.Utils_System;
import com.brightworks.util.singleton.SingletonManager;
import com.langcollab.languagementor.model.MainModel;

public class UserActionReportingManager implements IManagedSingleton{

   private static var _configProvider:IUserDataReportingConfigProvider;
   private static var _instance:UserActionReportingManager;
   private static var _model:MainModel;

   public function UserActionReportingManager(manager:SingletonManager) {
      _instance = this;
   }

   public static function getInstance():UserActionReportingManager {
      if (!(_instance))
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function initSingleton():void {
      _model = MainModel.getInstance();
   }

   public static function reportActivityIfUserHasActivatedReporting(activity:UserAction):void {
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


      var mainObject:Object = new Object();
      var detailsObject:Object = new Object();
      mainObject["details"] = detailsObject;

      if (activity.actionType) {
         detailsObject["actionType"] = activity.actionType;
      }
      else {
         return;
      }



      ///// Dummy User code
      var userIdList:Array = [
         "fa88801a-e52b-4ec3-b24a-e8fb3f9af880",
         "19d6319f-4745-4176-8bb4-0cfb1c0ff395",
         "c4c4ace4-17c6-4945-bf5e-cabd9b9a9d9b",
         "48b96be4-8569-48e9-9e80-70ff00aa2935",
         "39ae3ee8-728a-4d10-834e-576f4c59caa6",
         "bc0c3054-1434-405a-b841-e10c3c0513d3",
         "21941f50-d51b-4abf-9832-a2f089c12cd8",
         "4a4e0099-1f0f-4184-9f09-1ba2b32fdcb8",
         "cbb626ea-988e-47de-892c-ac530f7cf4ae",
         "9f9cd96d-3279-4927-9d83-b0b529cf919d",
         "c1127160-21d8-4841-bd37-3c1e487dabff"
      ]
      var d:Date = new Date();
      var m:Number = d.time;
      var days:Number = m/86400000;
      var listIndex:int = Math.floor(days % 11);
      var userId:String = userIdList[listIndex];


      mainObject["userID"] = userId;





      if (activity.autoPlay_AutoAdvanceLesson) {
         detailsObject["autoPlay_AutoAdvanceLesson"] = "true";
      }
      if (activity.chunkIndex) {
         detailsObject["chunkIndex"] = activity.chunkIndex;
      }
      if (activity.chunkIndex_New) {
         detailsObject["chunkIndex_New"] = activity.chunkIndex_New;
      }
      if (activity.chunkIndex_Previous) {
         detailsObject["chunkIndex_Previous"] = activity.chunkIndex_Previous;
      }
      if (activity.iKnowThis_AllChunksInLessonSuppressed) {
         detailsObject["iKnowThis_AllChunksInLessonSuppressed"] = "true";
      }
      if (activity.learningModeDisplayName) {
         detailsObject["learningModeDisplayName"] = activity.learningModeDisplayName;
      }
      if (activity.learningModeDisplayName_New) {
         detailsObject["learningModeDisplayName_New"] = activity.learningModeDisplayName_New;
      }
      if (activity.learningModeDisplayName_Previous) {
         detailsObject["learningModeDisplayName_Previous"] = activity.learningModeDisplayName_Previous;
      }
      if (activity.lessonId) {
         detailsObject["lessonId"] = activity.lessonId;
      }
      if (activity.lessonId_New) {
         detailsObject["lessonId_New"] = activity.lessonId_New;
      }
      if (activity.lessonId_Previous) {
         detailsObject["lessonId_Previous"] = activity.lessonId_Previous;
      }
      if (activity.lessonName_NativeLanguage) {
         detailsObject["lessonName_NativeLanguage"] = activity.lessonName_NativeLanguage;
      }
      if (activity.lessonName_NativeLanguage_New) {
         detailsObject["lessonName_NativeLanguage_New"] = activity.lessonName_NativeLanguage_New;
      }
      if (activity.lessonName_NativeLanguage_Previous) {
         detailsObject["lessonName_NativeLanguage_Previous"] = activity.lessonName_NativeLanguage_Previous;
      }
      if (activity.lessonProviderId) {
         detailsObject["lessonProviderId"] = activity.lessonProviderId;
      }
      if (activity.lessonProviderId_New) {
         detailsObject["lessonProviderId_New"] = activity.lessonProviderId_New;
      }
      if (activity.lessonProviderId_Previous) {
         detailsObject["lessonProviderId_Previous"] = activity.lessonProviderId_Previous;
      }
      if (activity.lessonVersion) {
         detailsObject["lessonVersion"] = activity.lessonVersion;
      }
      if (activity.lessonVersion_New) {
         detailsObject["lessonVersion_New"] = activity.lessonVersion_New;
      }
      if (activity.lessonVersion_Previous) {
         detailsObject["lessonVersion_Previous"] = activity.lessonVersion_Previous;
      }
      var jsonText:String = JSON.stringify(mainObject);


      trace(jsonText); /////

      /*
      trace("-");
      trace("-");
      for (var s:String in o) {
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
