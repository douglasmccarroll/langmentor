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
    import com.brightworks.interfaces.IDisposable;
    import com.brightworks.util.Log;

    import flash.system.System;

    public class LessonDownloadInfo_Lesson implements IDisposable
    {
        public var lessonChunks:XML;
        public var lessonCredits:XML;
        public var lessonDefaultTextDisplayTypeId:int;
        public var lessonDescription:String;
        public var lessonDownloadFolderURL:String;
        public var lessonId:String;
        public var lessonIsAlphaReviewVersion:Boolean;
        public var lessonIsDualLanguage:Boolean;
        public var lessonIsHasText_DefaultTextDisplayType:Boolean;
        public var lessonIsHasText_Native:Boolean;
        public var lessonIsHasText_Target:Boolean;
        public var lessonIsHasText_TargetPhonetic:Boolean;
        public var lessonLevelToken:String;
        public var lessonName:String;
        public var lessonNativeLanguageAudioVolumeAdjustmentFactor:Number;
        public var lessonPublishedLessonVersionVersion:String;
        public var lessonSortName:String;
        public var lessonTags:XML;
        public var lessonTargetLanguageAudioVolumeAdjustmentFactor:Number;

        private var _isDisposed:Boolean = false;

        public function LessonDownloadInfo_Lesson()
        {
            Log.debug("LessonDownloadInfo_Lesson constructor - class has XML props");
        }

        public function dispose():void
        {
            if (_isDisposed)
                return;
            Log.debug("LessonDownloadInfo_Lesson.dispose() - class has XML props");
            _isDisposed = true;
            if (lessonChunks)
            {
                System.disposeXML(lessonChunks);
                lessonChunks = null;
            }
            if (lessonCredits)
            {
                System.disposeXML(lessonCredits);
                lessonCredits = null;
            }
            if (lessonTags)
            {
                System.disposeXML(lessonTags);
                lessonTags = null;
            }
        }
    }
}
