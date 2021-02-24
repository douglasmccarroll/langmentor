/*
Copyright 2021 Brightworks, Inc.

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
import com.brightworks.interfaces.IDisposable;
import com.brightworks.techreport.ITechReport;
import com.brightworks.techreport.TechReport;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Dispose;
import com.brightworks.util.download.FileDownloaderErrorReport;
import com.brightworks.util.download.FileSetDownloaderErrorReport;

import flash.utils.Dictionary;

public class Command_DownloadLibraryInfoTechReport extends TechReport implements ITechReport, IDisposable {
   /// check which of these descriptions are used, i.e. which problems are checked for
   public static const PROB_DESC__LESSON_LIST_XML__DOWNLOAD_FAILURE:String = "Unable to download lesson_list.xml.";
   public static const PROB_DESC__LESSON_LIST_XML__LESSON_VERSION_IS_NOT_A_NUMBER:String = "Lesson list XML lesson node has version that isn't a number";
   public static const PROB_DESC__LESSON_LIST_XML__LEVEL_IS_NOT_A_STANDARD_LEVEL:String = "Lesson list XML lesson node has no level or level isn't a standard level";
   public static const PROB_DESC__LESSON_LIST_XML__MALFORMED_XML:String = "lesson_list.xml's XML contains problems which make it impossible to parse.";
   public static const PROB_DESC__LESSON_LIST_XML__RELEASETYPE_IS_NOT_A_STANDARD_RELEASETYPE:String = "Lesson list XML lesson node has no releaseType or releaseType isn't a standard releaseType";
   public static const PROB_DESC__LESSON_XML__CHUNK_CONSISTENCY_PROBLEM:String = "One or more chunk text types exist in some but not all chunk nodes";
   public static const PROB_DESC__LESSON_XML__DOWNLOAD_FAILURE:String = "Unable to download lesson XML file.";
   public static const PROB_DESC__LESSON_XML__INDICATES_DUAL_LANG_BUT_LESSON_IS_IN_SINGLE_LANG_DOWNLOAD_FOLDER:String = "Lesson XML indicates dual language, but lesson is in single language download folder";
   public static const PROB_DESC__LESSON_XML__INDICATES_SINGLE_LANG_BUT_LESSON_IS_IN_DUAL_LANG_DOWNLOAD_FOLDER:String = "Lesson XML indicates single language, but lesson is in dual language download folder";
   public static const PROB_DESC__LESSON_XML__MALFORMED_XML:String = "Lesson XML contains problems which make it impossible to parse.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_CHUNKS_NODES:String = "Lesson XML has more than one 'chunks' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_CREDITS_NODES:String = "Lesson XML has more than one 'credits' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_DEFAULT_TEXT_DISPLAY_TYPE_NODES:String = "Lesson XML has more than one 'defaultTextDisplayType' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_DESCRIPTION_NODES:String = "Lesson XML has more than one 'description' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_FILE_NAME_ROOT_NODES:String = "Lesson XML's chunk node has more than one 'fileNameRoot' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_IS_ALPHA_REVIEW_VERSION_NODES:String = "Lesson XML has more than one 'isAlphaReviewVersion' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_IS_DUAL_LANGUAGE_NODES:String = "Lesson XML has more than one 'isDualLanguage' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_LESSON_NAME_NODES:String = "Lesson XML has more than one 'lessonName' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_LESSON_SORT_NAME_NODES:String = "Lesson XML has more than one 'lessonSortName' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_NATIVE_LANGUAGE_AUDIO_VOLUME_ADJUSTMENT_FACTOR_NODES:String = "Lesson XML has more than one 'nativeLanguageAudioVolumeAdjustmentFactor' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_NATIVE_LANGUAGE_ISO6393_CODE_NODES:String = "Lesson XML has more than one 'nativeLanguageISO639_3Code' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_TAGS_NODES:String = "Lesson XML has more than one 'tags' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_TARGET_LANGUAGE_AUDIO_VOLUME_ADJUSTMENT_FACTOR_NODES:String = "Lesson XML has more than one 'targetLanguageAudioVolumeAdjustmentFactor' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_TARGET_LANGUAGE_ISO6393_CODE_NODES:String = "Lesson XML has more than one 'targetLanguageISO639_3Code' node.";
   public static const PROB_DESC__LESSON_XML__MULTIPLE_TEXT_NODES_OF_SAME_TYPE_IN_CHUNK_NODES:String = "One or more chunk nodes have more than one node for one or more chunk text types";
   public static const PROB_DESC__LESSON_XML__NO_CHUNK_NODES:String = "Lesson XML's chunks node doesn't have any 'chunk' nodes.";
   public static const PROB_DESC__LESSON_XML__NO_DEFAULT_TEXT_DISPLAY_TYPE_NODE:String = "Lesson XML doesn't have a 'defaultTextDisplayType' node.";
   public static const PROB_DESC__LESSON_XML__NO_FILE_NAME_ROOT_NODE:String = "Lesson XML's chunk node doesn't have a 'fileNameRoot' node.";
   public static const PROB_DESC__LESSON_XML__NO_LESSON_NAME_NODE:String = "Lesson XML doesn't have a 'lessonName' node.";
   public static const PROB_DESC__LESSON_XML__NO_NATIVE_LANGUAGE_ISO6393_CODE_NODE_AND_IS_DUAL_LANGUAGE:String = "Lesson XML doesn't have a 'nativeLanguageISO639_3Code' node, and lesson is dual-language.";
   public static const PROB_DESC__LESSON_XML__NO_TARGET_LANGUAGE_ISO6393_CODE_NODE:String = "Lesson XML doesn't have a 'targetLanguageISO639_3Code' node.";
   public static const PROB_DESC__LESSON_XML__NONSTANDARD_DEFAULT_TEXT_DISPLAY_TYPE:String = "Lesson info file specifies a defaultTextDisplayType that isn't a standard text display type.";
   public static const PROB_DESC__LESSON_XML__TYPE_ERROR__NATIVE_LANGUAGE_AUDIO_VOLUME_ADJUSTMENT_FACTOR_NODE:String = "Lesson XML's 'nativeLanguageAudioVolumeAdjustmentFactor' node doesn't contain correct type of data.";
   public static const PROB_DESC__LESSON_XML__TYPE_ERROR__TARGET_LANGUAGE_AUDIO_VOLUME_ADJUSTMENT_FACTOR_NODE:String = "Lesson XML's 'targetLanguageAudioVolumeAdjustmentFactor' node doesn't contain correct type of data.";
   public static const PROB_DESC__REPOS_XML__CONTENTPROVIDERID_TOO_SHORT:String = "language_mentor_library.xml's 'contentProviderId' is too short. Please create an ID using 'reverse domain' format, e.g. 'com.mydomain'.";
   public static const PROB_DESC__REPOS_XML__DOWNLOAD_FAILURE:String = "Unable to download language_mentor_library.xml.";
   public static const PROB_DESC__REPOS_XML__MALFORMED_XML:String = "language_mentor_library.xml's XML contains problems which make it impossible to parse.";
   public static const PROB_DESC__REPOS_XML__MISSING_CONTENT_PROVIDER_NAME_NODE:String = "language_mentor_library.xml has one or more language nodes that don't have a 'contentProviderName' node.";
   public static const PROB_DESC__REPOS_XML__MISSING_ISO6393_CODE:String = "language_mentor_library.xml has one or more language nodes that don't have an 'iso639_3Code' node.";
   public static const PROB_DESC__REPOS_XML__MISSING_LIBRARY_NAME_NODE:String = "language_mentor_library.xml has one or more language nodes that don't have a 'libraryName' node.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_CONTENT_PROVIDER_ID_NODES:String = "language_mentor_library.xml has multiple 'contentProviderId' nodes.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_CONTENT_PROVIDER_NAME_NODES:String = "language_mentor_library.xml has one or more language nodes that have more than one 'contentProviderName' node.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_DUAL_LANGUAGE_LESSON_INFO_NODES:String = "language_mentor_library.xml has more than one 'dualLanguageLessonInfo' node in libraryContentInfo node.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_ISO6393_CODE_NODES:String = "language_mentor_library.xml has one or more language nodes that have more than one 'iso639_3Code' node.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_LANGUAGE_PAIRS_NODES_IN_DUAL_LANGUAGE_LESSON_INFO_NODE:String = "language_mentor_library.xml includes more than one 'languagePairs' nodes in dualLanguageLessonInfo node.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_LANGUAGES_NODES:String = "language_mentor_library.xml includes more than one 'languages' nodes.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_LANGUAGES_NODES_IN_SINGLE_LANGUAGE_LESSON_INFO_NODE:String = "language_mentor_library.xml includes more than one 'languages' nodes in singleLanguageLessonInfo node.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_LANGUAGE_PAIRS_NODES:String = "language_mentor_library.xml includes more than one 'languagePairs' nodes.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_LIBRARY_CONTENT_INFO_NODES:String = "language_mentor_library.xml includes more than one 'libraryContentInfo' nodes.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_LIBRARY_NAME_NODES:String = "language_mentor_library.xml has one or more language nodes that have more than one 'libraryName' node.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_LIBRARY_ID_NODES:String = "language_mentor_library.xml has multiple 'libraryId' nodes.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_SINGLE_LANGUAGE_LESSON_INFO_NODES:String = "language_mentor_library.xml has more than one 'singleLanguageLessonInfo' node in libraryContentInfo node.";
   public static const PROB_DESC__REPOS_XML__NO_CONTENTPROVIDERID_NODE:String = "language_mentor_library.xml has no 'contentProviderId' node.";
   public static const PROB_DESC__REPOS_XML__NO_INDICATION_OF_CONTENT_FOR_CURR_TARGET_LANGUAGE:String = "language_mentor_library.xml's doesn't indicate content for current target language.";
   public static const PROB_DESC__REPOS_XML__NO_LANGUAGE_NODES:String = "language_mentor_library.xml doesn't include any language nodes.";
   public static const PROB_DESC__REPOS_XML__NO_LANGUAGES_NODE:String = "language_mentor_library.xml doesn't include a 'languages' node.";
   public static const PROB_DESC__REPOS_XML__NO_NATIVE_LANGUAGE_NODE_IS_CURR_NATIVE_LANGUAGE_OR_ENGLISH:String = "language_mentor_library.xml doesn't include a language node that either a) matches the current native language, or b) is English.";
   public static const PROB_DESC__REPOS_XML__NO_LIBRARY_CONTENT_INFO_NODE:String = "language_mentor_library.xml doesn't include a 'libraryContentInfo' node.";
   public static const PROB_DESC__REPOS_XML__NO_LIBRARYID_NODE:String = "language_mentor_library.xml has no 'libraryId' node.";
   public static const PROB_DESC__REPOS_XML__LIBRARYID_TOO_SHORT:String = "language_mentor_library.xml's 'libraryId' is too short. Please create an ID using 'reverse domain' format, e.g. 'com.mydomain.mylibrary'.";
   public static const PROB_DESC__REPOS_XML__LIBRARYNAME_NODE_TOO_SHORT:String = "language_mentor_library.xml has one or more 'libraryName' values that are too short.";

   public static const PROB_DESC__REPOS_XML__MISSING_NATIVE_LANGUAGE_NODE:String = "language_mentor_library.xml has one or more languagePair nodes that don't have a 'nativeLanguage' node.";
   public static const PROB_DESC__REPOS_XML__MISSING_TARGET_LANGUAGE_NODE:String = "language_mentor_library.xml has one or more languagePair nodes that don't have a 'targetLanguage' node.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_NATIVE_LANGUAGE_NODES:String = "language_mentor_library.xml has one or more languagePair nodes that have more than one 'nativeLanguage' node.";
   public static const PROB_DESC__REPOS_XML__MULTIPLE_TARGET_LANGUAGE_NODES:String = "language_mentor_library.xml has one or more languagePair nodes that have more than one 'targetLanguage' node.";

   public var count_LessonUpdatesNotDownloadedBecauseInSelectedLessons:uint = 0;
   public var fileDownloadErrorReportList:Array = [];
   public var index_lessonFileId_to_fileDownloaderErrorReport:Dictionary = new Dictionary();
   public var index_lessonId_to_lessonXmlFileProblemDescriptionList:Dictionary = new Dictionary(); // probDescLists are string vectors
   public var index_lessonListFileId_to_fileDownloaderErrorReport:Dictionary = new Dictionary();
   // dmccarroll 20120425
   // We don't have an isFatalProblem prop here because there is no such thing as a "fatal problem" when downloading
   // library info. There are many circumstances where we'll create and pass out this error report, but this will
   // be info that will be of interest to publishers only, or, perhaps, at some point, we'll tell the user that
   // a user-entered library that they entered has problems and suggest that they report the problem to the
   // library...  But in any case, it isn't, i.e. can't be, fatal to the process because the user may be
   // downloading from other libraries and may have partial success.
   //public var isFatalProblem:Boolean = false;
   public var isLessonListXMLPopulationAndValidationFailed_DualLanguage:Boolean;
   public var isLessonListXMLPopulationAndValidationFailed_SingleLanguage:Boolean;
   public var isLessonListDownloadAttempted_DualLanguage:Boolean;
   public var isLessonListDownloadAttempted_SingleLanguage:Boolean;
   public var isLibraryFileDoesNotIndicateLibraryHasContentForTargetLanguage:Boolean;
   public var isProblemValidatingLibraryXML:Boolean;
   public var isProcessTimedOut:Boolean = false;
   public var isSuccess:Boolean = false;
   public var lessonListFileDownloadCount_Attempted:int = -1;
   public var lessonListFileDownloadCount_Successful:int = 0;
   public var lessonXMLFileDownloadCount_Attempted:int = -1;
   public var lessonXMLFileDownloadCount_Successful:int = 0;
   public var lessonListFileSetDownloaderErrorReport:FileSetDownloaderErrorReport;
   public var lessonXMLFileSetDownloaderErrorReport:FileSetDownloaderErrorReport;
   public var libraryDownloaderErrorReport:FileDownloaderErrorReport;
   public var libraryFolderUrl:String;
   public var libraryName:String;
   public var problemDescriptionList:Array = [];
   public var statusAtTimeOfFaultReport:String;

   private var _isDisposed:Boolean = false;

   public function Command_DownloadLibraryInfoTechReport() {
      super();
      Log.debug("Command_DownloadLibraryInfoTechReport - Constructor");
   }

   override public function dispose():void {
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      Log.debug("Command_DownloadLibraryInfoTechReport.dispose()");
      if (fileDownloadErrorReportList) {
         Utils_Dispose.disposeArray(fileDownloadErrorReportList, true);
         fileDownloadErrorReportList = null;
      }
      if (index_lessonFileId_to_fileDownloaderErrorReport) {
         Utils_Dispose.disposeDictionary(index_lessonFileId_to_fileDownloaderErrorReport, true);
         index_lessonFileId_to_fileDownloaderErrorReport = null;
      }
      if (index_lessonId_to_lessonXmlFileProblemDescriptionList) {
         Utils_Dispose.disposeDictionary(index_lessonId_to_lessonXmlFileProblemDescriptionList, true);
         index_lessonId_to_lessonXmlFileProblemDescriptionList = null;
      }
      if (index_lessonListFileId_to_fileDownloaderErrorReport) {
         Utils_Dispose.disposeDictionary(index_lessonListFileId_to_fileDownloaderErrorReport, true);
         index_lessonListFileId_to_fileDownloaderErrorReport = null;
      }
      if (problemDescriptionList) {
         Utils_Dispose.disposeArray(problemDescriptionList, true);
         problemDescriptionList = null;
      }
   }

}
}
