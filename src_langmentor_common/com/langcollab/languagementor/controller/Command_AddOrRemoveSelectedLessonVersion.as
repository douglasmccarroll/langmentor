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
import com.brightworks.util.Log;
import com.langcollab.languagementor.constant.Constant_UserActionTypes;
import com.langcollab.languagementor.controller.useractivityreporting.UserAction;
import com.langcollab.languagementor.controller.useractivityreporting.UserActionReportingManager;
import com.langcollab.languagementor.vo.ChunkVO;
import com.langcollab.languagementor.vo.LessonVersionVO;

public class Command_AddOrRemoveSelectedLessonVersion extends Command_Base__LangMentor {
   private var _isDisposed:Boolean = false;
   private var _lessonVersionVO:LessonVersionVO;

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function Command_AddOrRemoveSelectedLessonVersion(lessonVersionVO:LessonVersionVO) {
      super();
      Log.debug("Command_AddOrRemoveSelectedLessonVersion - Constructor");
      _lessonVersionVO = lessonVersionVO;
   }

   override public function dispose():void {
      Log.debug("Command_AddOrRemoveSelectedLessonVersion.dispose()");
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      model = null;
   }

   public function execute():void {
      Log.debug("Command_AddOrRemoveSelectedLessonVersion.execute()");
      if (currentLessons.isLessonPlaying) {
         Log.fatal("Command_AddOrRemoveSelectedLessonVersion.execute(): currentLessons.isLessonPlaying = true");
         return;
      }
      currentLessons.stopPlayingCurrentLessonVersionIfPlaying();
      // Next line needed because we may have downloaded a new version of the lesson while the user is in Select Lessons, in which case
      // we need to get a LessonVersionVO instance that _matches_ the VO that was passed with the event, rather than simply using the passed VO.
      _lessonVersionVO =
            model.getSingleOrNoLessonVersionVOFromContentProviderIdAndPublishedLessonVersionId(
                  _lessonVersionVO.contentProviderId,
                  _lessonVersionVO.publishedLessonVersionId);
      if (currentLessons.contains(_lessonVersionVO)) {
         // We're removing
         Log.info("Command_AddOrRemoveSelectedLessonVersion.execute(): removing lessonVersionVO at index of: " + currentLessons.getLessonIndex(_lessonVersionVO));
         currentLessons.remove(_lessonVersionVO);
         reportUserActivity_DeselectLesson();
      }
      else {
         // We're adding
         Log.info("Command_AddOrRemoveSelectedLessonVersion.execute(): adding lessonVersionVO");
         currentLessons.add(_lessonVersionVO);
         currentLessons.unsuppressAllChunksForVO(_lessonVersionVO);
         reportUserActivity_SelectLesson();
      }
      var c:Command_Data_UpdateVosOfType = new Command_Data_UpdateVosOfType(ChunkVO);
      c.index_propNames_to_newValues["suppressed"] = false;
      c.index_propNames_to_selectValues["contentProviderId"] = _lessonVersionVO.contentProviderId;
      c.index_propNames_to_selectValues["lessonVersionSignature"] = _lessonVersionVO.lessonVersionSignature;
      var commandReport:Command_Data_UpdateVosOfTypeTechReport = c.execute();
      if (commandReport.isSuccessful) {
         // Do nothing.
      }
      else {
         Log.error(["Command_AddOrRemoveSelectedLessonVersion.execute()", commandReport]);
      }
      commandReport.dispose();
      dispose();
   }

   private function reportUserActivity_DeselectLesson():void {
      var activity:UserAction = new UserAction();
      activity.actionType = Constant_UserActionTypes.SELECT_LESSONS__DESELECT;
      activity.lessonId = _lessonVersionVO.publishedLessonVersionId;
      activity.lessonName_NativeLanguage = model.getLessonVersionNativeLanguageNameFromLessonVersionVO(_lessonVersionVO);
      activity.lessonProviderId = _lessonVersionVO.contentProviderId;
      activity.lessonVersion = _lessonVersionVO.publishedLessonVersionVersion;
      UserActionReportingManager.reportActivityIfUserHasActivatedReporting(activity);
   }

   private function reportUserActivity_SelectLesson():void {
      var activity:UserAction = new UserAction();
      activity.actionType = Constant_UserActionTypes.SELECT_LESSONS__SELECT;
      activity.lessonId = _lessonVersionVO.publishedLessonVersionId;
      activity.lessonName_NativeLanguage = model.getLessonVersionNativeLanguageNameFromLessonVersionVO(_lessonVersionVO);
      activity.lessonProviderId = _lessonVersionVO.contentProviderId;
      activity.lessonVersion = _lessonVersionVO.publishedLessonVersionVersion;
      UserActionReportingManager.reportActivityIfUserHasActivatedReporting(activity);
   }


}
}
