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
package com.brightworks.constant {
import com.brightworks.constant.Constant_ReleaseType;
import com.brightworks.util.Log;
import com.langcollab.languagementor.constant.Constant_MentorTypeSpecific;

public class Constant_AppConfiguration {

   public static const APP_RELEASE_TYPE:String = Constant_ReleaseType.PRODUCTION;      /////

   public static const BANDWIDTH_LIMITING__MEGABYTES_ALLOWED_PER_TIME_PERIOD__ANDROID:Number = 10;
   public static const BANDWIDTH_LIMITING__MEGABYTES_ALLOWED_PER_TIME_PERIOD__DESKTOP:Number = 100;
   public static const BANDWIDTH_LIMITING__MEGABYTES_ALLOWED_PER_TIME_PERIOD__IOS:Number = 10;
   public static const BANDWIDTH_LIMITING__TIME_PERIOD_IN_MINUTES:uint = 5;
   public static const BRIGHTWORKS_BLURB:String = Constant_MentorTypeSpecific.APP_NAME__SHORT + "'s technology is lovingly crafted by the dwarves and elves of Brightworks, deep in the primal forests of Massachusetts. We specialize in cross-platform development of mobile learning apps. Our technology is available under various licenses from open source (GPL) to white-label apps custom branded for our clients\n\nHow may we be of service?\nhttp://www.brightworks.com";
   // Default config info is used a) when config info has not yet been loaded from 'mentor type' file, and b) ? If there is a problem loading this data?
   public static const DEFAULT_CONFIG_INFO__LOG_LEVEL__INTERNAL_LOGGING:uint = Log.LOG_LEVEL__INFO;
   public static const DEFAULT_CONFIG_INFO__LOG_LEVEL__LOG_TO_SERVER:uint = Log.LOG_LEVEL__WARN;
   public static const DEFAULT_CONFIG_INFO__LOG_TO_SERVER_MAX_STRING_LENGTH:uint = 8000;
   public static const EXPLANATORY_AUDIO_FILE_BODY_STRING:String = "xply";
   public static const I_KNOW_THIS_REQUIRED_WAIT_INTERVAL:Number = 1000;
   public static const INSUFFICIENT_STORAGE_SPACE_MESSAGE:String = "We're sorry, this device has insufficient space available in its file system to store new lessons.";
   public static const REQUIRED_SCREEN_RESOLUTION__X:uint = 320;
   public static const REQUIRED_SCREEN_RESOLUTION__Y:uint = 480;
   public static const USER_ACTION_REQUIRED_WAIT_INTERVAL:Number = 400;

}
}
