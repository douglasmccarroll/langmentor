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
package com.langcollab.languagementor.constant {
import com.brightworks.constant.Constant_ReleaseType;

public class Constant_AppConfiguration {
   // Constants that we may modify when configuring a release
   //// Some of these constants should be in a "project-specific" or "app-specific" constants file

   public static const APP_NAME:String = "Language Mentor";
   public static const APP_VERSION__MINIMUM__SUPPORTED_DATA_SCHEMA:Number = 1.38;

   public static const CURRENT_MENTOR_TYPE__CODE:String = Constant_MentorTypes.MENTOR_TYPE_CODE__GLOBAL;
   public static const CURRENT_MENTOR_TYPE__DISPLAY_NAME:String = Constant_MentorTypes.MENTOR_TYPE_DISPLAY_NAME__GLOBAL;

   public static const BANDWIDTH_LIMITING__MEGABYTES_ALLOWED_PER_TIME_PERIOD__ANDROID:Number = 10;
   public static const BANDWIDTH_LIMITING__MEGABYTES_ALLOWED_PER_TIME_PERIOD__DESKTOP:Number = 100;
   public static const BANDWIDTH_LIMITING__MEGABYTES_ALLOWED_PER_TIME_PERIOD__IOS:Number = 10;
   public static const BANDWIDTH_LIMITING__TIME_PERIOD_IN_MINUTES:uint = 5;

   public static const LANGUAGE__DEFAULT__NATIVE__ISO639_3_CODE:String = "eng";
   public static const LANGUAGE__DEFAULT__TARGET__ISO639_3_CODE:String = "eng";

   public static const RELEASE_TYPE:String = Constant_ReleaseType.BETA;      /////


   // Constants that we don't usually modify for a new release

   public static const BRIGHTWORKS_BLURB:String = "Language Mentor technology is lovingly crafted by the dwarves and elves of Brightworks, deep in the primal forests of Massachusetts. We specialize in cross-platform development of mobile learning apps. Our technology is available under various licenses from open source (GPL) to white-label apps custom branded for our clients\n\nHow may we be of service?\nhttp://www.brightworks.com";
   public static const EXPLANATORY_AUDIO_FILE_BODY_STRING:String = "xply";
   public static const I_KNOW_THIS_REQUIRED_WAIT_INTERVAL:Number = 1000;
   public static const INSUFFICIENT_STORAGE_SPACE_MESSAGE:String = "We're sorry, this device has insufficient space available in its file system to store new lessons.";
   public static const LESSON_ENTRY_COUNT_REQUIRED_BEFORE_DISPLAYING_RATE_APP_PROMPT:int = 25;
   public static const REQUIRED_SCREEN_RESOLUTION__X:uint = 320;
   public static const REQUIRED_SCREEN_RESOLUTION__Y:uint = 480;
   public static const USER_ACTION_REQUIRED_WAIT_INTERVAL:Number = 400;

   public static const SHARING__FACEBOOK_SHARE_TEXT:String = "Check out Language Mentor! - A free and open language learning platform";
   // public static const SHARING__FACEBOOK_SHARE_TEXT:String = "Give the Chinese Language Mentor app a try!";
   public static const SHARING__FACEBOOK_SHARE_URL:String = "http://languagecollaborative.com";

}
}
