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
package com.langcollab.languagementor.constant {
import com.brightworks.constant.Constant_PlatformName;
import com.brightworks.util.Utils_System;

import flash.filesystem.File;

public class Constant_LangMentor_Misc {

   // Misc
   public static const AUDIO__DEFAULT_NATIVE_LANGUAGE_AUDIO_VOLUME_ADJUSTMENT_FACTOR:Number = .7; // Yes, the 'volume' must be reduced by 30-40% in order to get the rather minor decrease in 'volume' (as heard by the human ear) that we want.
   public static const MAX_ALLOWED_CHUNKS_PER_LESSON_VERSION:int = 333;

   // Effect Values
   public static const EFFECT__CROSSFADE_TRANSITION_DURATION:int = 300;
   public static const EFFECT__SLIDE_TRANSITION_DURATION:int = 300;
   public static const EFFECT__ZOOM_TRANSITION_DURATION:int = 300;

   // File Name And Path Tokens
   public static const FILEPATHINFO__CHUNK_AUDIO_FILE_EXTENSION:String = "mp3";
   public static const FILEPATHINFO__CHUNK_FILE_LANGUAGE_CODE_LENGTH:int = 3;
   public static const FILEPATHINFO__DB_FILE_FILE_NAME:String = "langcollabLocalDB.db";
   public static const FILEPATHINFO__DB_FOLDER_NAME:String = "Database";
   public static const FILEPATHINFO__DB_TEMPLATE_FILE_NAME:String = "langcollabLocalDBTemplate.db";
   public static const FILEPATHINFO__DB_TEMPLATE_FOLDER_NAME:String = "db";
   public static const FILEPATHINFO__DOCUMENT_STORAGE_FOLDER_NAME:String = "LanguageMentor";
   public static const FILEPATHINFO__DOWNLOADED_LESSONS_FOLDER_NAME:String = "Lessons";
   public static const FILEPATHINFO__DOWNLOAD_PERMISSION_FILE_NAME:String = "langcollab_download_permission.xml"; /// Not used? This is used in code (Security.loadPolicyFile() ), but no such files?
   public static const FILEPATHINFO__LANGUAGE_MENTOR_ROOT_CONFIG_FILE_NAME:String = "language_mentor_root_config";
   public static const FILEPATHINFO__LANGUAGE_MENTOR_LIBRARY_FILE_NAME:String = "language_mentor_library";
   public static const FILEPATHINFO__LANGUAGE_RESOURCE_FOLDER_NAME:String = "xml" + File.separator + "languageResource";
   public static const FILEPATHINFO__LESSON_COMPRESSED_FILE_EXTENSION:String = "zip";
   public static const FILEPATHINFO__LESSON_LIST_FILE_NAME:String = "lesson_list";
   public static const FILEPATHINFO__MENTOR_NEWS_UPDATE_FILE_NAME_ROOT:String = "mentor_news_update_";
   public static const FILEPATHINFO__MENTOR_NEWS_UPDATE_DATE_FILE_NAME_ROOT:String = "mentor_news_update_date_";
   public static const FILEPATHINFO__MENTOR_TYPE_FILE_NAME_ROOT:String = "mentor_type__";
   public static const FILEPATHINFO__PERSISTENCE_FILE_FILE_NAME:String = "persistence.dict";
   public static const FILEPATHINFO__PERSISTENCE_FOLDER_NAME:String = "persistence";
   public static const FILEPATHINFO__SILENCE_AUDIO_FILE_NAME:String = "silence.mp3";
   public static const FILEPATHINFO__SILENCE_AUDIO_FOLDER_NAME:String = "assets" + File.separator + "audio";
   public static const FILEPATHINFO__TEMP_AUDIO_FILE_FILE_NAME:String = "temp.wav";
   public static const FILEPATHINFO__TEMP_AUDIO_FOLDER_NAME:String = "TempAudio";

   // Chunk Leaf Type Tokens
   public static const LEAF_TYPE__AUDIO_EXPLANATORY:String = "LEAF_TYPE__AUDIO_EXPLANATORY";
   public static const LEAF_TYPE__AUDIO_NATIVE:String = "LEAF_TYPE__AUDIO_NATIVE";
   public static const LEAF_TYPE__AUDIO_TARGET:String = "LEAF_TYPE__AUDIO_TARGET";
   public static const LEAF_TYPE__PAUSE_200_MS:String = "LEAF_TYPE__PAUSE_200_MS";  // dmccarroll 20181105 - These are used in "with playback" chunk sequence strategies because, for reasons I don't understand, they prevent iOS from deciding that the app, when playing in background mode, is no longer playing and thus should be suspended. No, this doesn't make any sense, but I discovered that it works through trial and error, so I'm using it for this purpose. I also use this leaf in one 'non-playback' strategy for reasons which I have long since forgotten.
   public static const LEAF_TYPE__PAUSE_500_MS:String = "LEAF_TYPE__PAUSE_500_MS";
   public static const LEAF_TYPE__PAUSE_1000_MS:String = "LEAF_TYPE__PAUSE_1000_MS";
   public static const LEAF_TYPE__PAUSE_2000_MS:String = "LEAF_TYPE__PAUSE_2000_MS";
   public static const LEAF_TYPE__PAUSE_3000_MS:String = "LEAF_TYPE__PAUSE_3000_MS";
   public static const LEAF_TYPE__PAUSE_ATTEMPT:String = "LEAF_TYPE__PAUSE_ATTEMPT";
   public static const LEAF_TYPE__PAUSE_REPEAT:String = "LEAF_TYPE__PAUSE_REPEAT";
   public static const LEAF_TYPE__PLAYBACK:String = "LEAF_TYPE__PLAYBACK";
   public static const LEAF_TYPE__RECORD_ATTEMPT:String = "LEAF_TYPE__RECORD_ATTEMPT";
   public static const LEAF_TYPE__RECORD_REPEAT:String = "LEAF_TYPE__RECORD_REPEAT";
   public static const LEAF_TYPE__TEXTONLY_NATIVE:String = "LEAF_TYPE__TEXTONLY_NATIVE";
   public static const LEAF_TYPE__TEXTONLY_TARGET:String = "LEAF_TYPE__TEXTONLY_TARGET";

   // Messages
   public static const MESSAGE__CONTACT_US:String = "contact us via the forums at LanguageCollaborative.com";
   public static const MESSAGE__REPORT_PROBLEM:String = "Please report this problem on the forums at LanguageCollaborative.com";
   public static const MESSAGE__UPGRADE__NEWER_VERSION_OF_APP_AVAILABLE:String = "A newer version of " + Constant_MentorTypeSpecific.APP_NAME__FULL + " is available.\n\nYou can use your device's " + Utils_System.getAppStoreName() + " to upgrade Language Mentor.";
   public static const MESSAGE__UPGRADE__UPDATE_REQUIRED__APP_VERSION_LOWER_THAN_MINIMUM_REQUIRED_VERSION:String = "Please Upgrade\n\nA new version of " + Constant_MentorTypeSpecific.APP_NAME__FULL + " is available, and an upgrade is necessary in order to continue using the app.\n\nPlease use your device's " + Utils_System.getAppStoreName() + " to upgrade Language Mentor.\n\nNote: You'll need to re-download lessons, etc. We apologize for this inconvenience.";

   // Language Tokens
   public static const TOKEN_FONT_SIZE_HEADING:String = "%heading_font_size%";
   public static const TOKEN_FONT_SIZE_TEXT:String = "%text_font_size%";
   public static const TOKEN_NATIVE_LANGUAGE_EXAMPLE:String = "%native_language_example%";
   public static const TOKEN_NATIVE_LANGUAGE_NAME:String = "%native_language_name%";
   public static const TOKEN_TARGET_LANGUAGE_EXAMPLE:String = "%target_language_example%";
   public static const TOKEN_TARGET_LANGUAGE_NAME:String = "%target_language_name%";


   // Misc
   public static const PLATFORM__DESKTOP_MODE_EMULATES_CONFIGURATION_OF:String = Constant_PlatformName.ANDROID;

   public function Constant_LangMentor_Misc() {
   }
}
}

