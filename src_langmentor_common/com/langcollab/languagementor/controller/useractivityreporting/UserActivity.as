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

public class UserActivity {

   // See Constant_UserActivityTypes - Many of the properties in this object are used by some types and not used by others.
   //
   // "New" and "Previous" - In some cases we only need to report a "thing", i.e. a chunk, a lesson, etc.
   //                        For example, when the user suppresses a chunk, we only need to know which chunk.
   //                        In other cases we want to know the previous thing and the new thing.
   //                        For example, when the app auto-advances from one lesson to another.
   //                        Note that "previous" and "new" as used here shouldn't be confused with the Play Lessons screen's Previous & Next buttons.
   //                        For example, if the user clicks the Previous Lesson button while in the middle of a lesson, both lessonId_Previous and
   //                        lessonId_New would be the current lesson, as the result of the user's click would be to go to the first chunk in that lesson.

   public var actionType:String;
   public var autoPlay_AutoAdvanceLesson:Boolean;
   public var chunkIndex:int;
   public var chunkIndex_New:int;
   public var chunkIndex_Previous:int;
   public var iKnowThis_AllChunksInLessonSuppressed:Boolean;
   public var learningModeDisplayName:String;
   public var learningModeDisplayName_New:String;
   public var learningModeDisplayName_Previous:String;
   public var lessonId:String;
   public var lessonId_New:String;
   public var lessonId_Previous:String;
   public var lessonName_NativeLanguage:String;
   public var lessonName_NativeLanguage_New:String;
   public var lessonName_NativeLanguage_Previous:String;
   public var lessonProviderId:String;
   public var lessonProviderId_New:String;
   public var lessonProviderId_Previous:String;
   public var lessonVersion:String;       // We get this from LessonVersionVO.publishedLessonVersionVersion
   public var lessonVersion_New:String;
   public var lessonVersion_Previous:String;


}
}
