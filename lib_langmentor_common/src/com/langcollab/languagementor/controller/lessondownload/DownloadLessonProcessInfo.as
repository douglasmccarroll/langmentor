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
package com.langcollab.languagementor.controller.lessondownload
{
    import com.brightworks.interfaces.IDisposable;
    import com.brightworks.util.Log;

    import flash.system.System;

    public class DownloadLessonProcessInfo implements IDisposable
    {
        // Some of this info is needed to download and save files.
        // Some is needed to create a LessonVersionVO.
        // Some is needed to report success and failure.
        // So this object is used both to send info into the process, and 
        // to send info back out as well.
        public var chunks:XML;
        public var contentProviderId:String;
        public var credits:XML;
        public var defaultTextDisplayTypeId:int;
        public var description:String;
        public var downloadFileNameBody:String;
        public var downloadFileNameExtension:String;
        public var downloadFolderURL:String;
        public var isAlphaReviewVersion:Boolean;
        public var isDualLanguage:Boolean;
        public var isHasText_DefaultTextDisplayType:Boolean;
        public var isHasText_Native:Boolean;
        public var isHasText_Target:Boolean;
        public var isHasText_TargetPhonetic:Boolean;
        public var iso639_3Code_NativeLanguage:String;
        public var iso639_3Code_TargetLanguage:String;
        public var levelId:uint;
        public var levelLocationInLevelsOrder:int;
        public var libraryId:String;
        public var nativeLanguageAudioVolumeAdjustmentFactor:Number;
        public var nativeLanguageContentProviderName:String;
        public var nativeLanguageLessonName:String;
        public var nativeLanguageLessonSortName:String;
        public var nativeLanguageLibraryName:String;
        public var processSuccessful:Boolean;
        public var publishedLessonVersionId:String;
        public var publishedLessonVersionVersion:String;
        public var saveFolderFilePath:String;
        public var tags:XML;
        public var targetLanguageAudioVolumeAdjustmentFactor:Number;

        private var _isDisposed:Boolean = false;

        public function DownloadLessonProcessInfo()
        {
            Log.debug("DownloadLessonProcessInfo constructor - class has XML props");
        }

        // We store these (for successful downloads) in LessonDownloadController's successfulDownloadInfoList... props 
        // for the duration of the session. They should only be disposed when data is wiped
        public function dispose():void
        {
            if (_isDisposed)
                return;
            _isDisposed = true;
            Log.debug("DownloadLessonProcessInfo.dispose() - class has XML props");
            if (chunks)
            {
                System.disposeXML(chunks);
                chunks = null;
            }
            if (credits)
            {
                System.disposeXML(credits);
                credits = null;
            }
            if (tags)
            {
                System.disposeXML(tags);
                tags = null;
            }
        }
    }
}
