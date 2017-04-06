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
    import com.brightworks.db.SQLiteTransactionReport;
    import com.brightworks.interfaces.IDisposable;
    import com.brightworks.techreport.ITechReport;
    import com.brightworks.util.Utils_Dispose;
    import com.brightworks.util.audio.FileSetMP3SaverTechReport;
    import com.brightworks.util.download.FileDownloaderErrorReport;
    import com.langcollab.languagementor.controller.Command_DeleteLessonVersionTechReport;
    import com.langcollab.languagementor.model.MainModelDBOperationReport;

    public class DownloadLessonProcessTechReport implements ITechReport, IDisposable
    {
        public static const ERROR__AUDIO_FILE_NAMING:String = "error_AudioFileNaming";
        public static const ERROR__AUDIO_FILE_NAME_AND_XML_CHUNK_CONSISTENCY:String = "error_AudioFileNameAndXMLChunkConsistency";
        public static const ERROR__AUDIO_FILE_NAME_CONSISTENCY:String = "error_AudioFileNameConsistency";
        public static const ERROR__DELETE_EXISTING_VERSION_0F_LESSON_FAILED:String = "error_DeleteExistingVersionOfLessonFailed";
        public static const ERROR__DOWNLOAD_FAILED:String = "error_DownloadFailed";
        public static const ERROR__GETALLVOS_FAILED:String = "error_GetAllVOsFailed";
        public static const ERROR__NEITHER_AUTO_DOWNLOAD_OR_USER_INITIATED_TRUE:String = "error_NeitherAutoDownloadOrUserInitiatedTrue";
        public static const ERROR__SAVE_DATA_TO_DB:String = "error_SaveDataToDB";
        public static const ERROR__SAVE_DATA_TO_DB__MODEL_DATA_NOT_INITIALIZED:String = "error_SaveDataToDB_ModelDataNotInitialized";
        public static const ERROR__SAVE_FILES_TO_DISK:String = "error_SaveFilesToDisk";
        public static const ERROR__UNALLOWED_LANGUAGE_FILE_INCLUDED:String = "error_UnallowedLanguageFileIncluded";
        public static const ERROR__UNZIP_FAILED:String = "error_UnzipFailed";
        public static const ERROR__USER_SELECTED_LESSON_WHILE_DOWNLOAD_IN_PROGRESS:String = "error_UserSelectedLessonWhileDownloadInProgress";

        public var contentProviderId:String;
        public var downloadFileExtension:String;
        public var downloadLessonProcessInfo:DownloadLessonProcessInfo;
        public var downloadURLRoot:String;
        public var duration_DeleteExistingVersionOfLesson:Number;
        public var duration_EntireProcess:Number;
        public var duration_ExtractMP3FileData:Number;
        public var duration_FileDownload:Number;
        public var duration_SaveDataToDB:Number;
        public var duration_SaveMP3Files:Number;
        public var duration_UnzipFile:Number;
        public var errorData_DeleteExistingLessonVersionTechReport:Command_DeleteLessonVersionTechReport;
        public var errorData_FileDownloaderErrorReport:FileDownloaderErrorReport;
        public var errorData_FileSetMP3SaverTechReport:FileSetMP3SaverTechReport;
        public var errorData_Inconsistencies_ChunkFileNameAndXML:Object;
        public var errorData_Inconsistencies_NativeAndTargetChunkFileNames:Object;
        public var errorData_IncorrectFileNameList:Array = [];
        public var errorData_InsufficientlyLongFileNameList:Vector.<String> = new Vector.<String>();
        public var errorData_MainModelDBOperationReport:MainModelDBOperationReport;
        public var errorData_UnallowedLanguageFileFileNameList:Array = [];
        public var errorData_UnzipFailedErrorText:String;
        public var errorData_UnzipFailedErrorType:String;
        public var errorTypeList:Array = [];
        public var isErrorReported:Boolean = false;
        public var isAlphaReviewVersion:Boolean = false;
        public var isUpdateOfPreviouslyDownloadedLesson:Boolean;
        public var publishedLessonVersionId:String;
        public var publishedLessonVersionVersion:String;
        public var time_StartDeleteExistingVersionOfLesson:Number;
        public var time_StartEntireProcess:Number;
        public var time_StartExtractMP3FileData:Number;
        public var time_StartFileDownload:Number;
        public var time_StartSaveDataToDB:Number;
        public var time_StartSaveMP3Files:Number;
        public var time_StartUnzipFile:Number;
        public var zipFileSizeInBytes:Number;

        private var _isDisposed:Boolean = false;

        public function DownloadLessonProcessTechReport()
        {
        }

        public function dispose():void
        {
            if (_isDisposed)
                return;
            _isDisposed = true;
            downloadLessonProcessInfo = null;
            if (errorData_DeleteExistingLessonVersionTechReport)
            {
                errorData_DeleteExistingLessonVersionTechReport.dispose();
                errorData_DeleteExistingLessonVersionTechReport = null;
            }
            if (errorData_FileDownloaderErrorReport)
            {
                errorData_FileDownloaderErrorReport.dispose();
                errorData_FileDownloaderErrorReport = null;
            }
            if (errorData_IncorrectFileNameList)
            {
                Utils_Dispose.disposeArray(errorData_IncorrectFileNameList, true);
                errorData_IncorrectFileNameList = null;
            }
            if (errorData_FileSetMP3SaverTechReport)
            {
                errorData_FileSetMP3SaverTechReport.dispose();
                errorData_FileSetMP3SaverTechReport = null;
            }
            if (errorData_MainModelDBOperationReport)
            {
                errorData_MainModelDBOperationReport.dispose();
                errorData_MainModelDBOperationReport = null;
            }
            if (errorData_UnallowedLanguageFileFileNameList)
            {
                Utils_Dispose.disposeArray(errorData_UnallowedLanguageFileFileNameList, true);
                errorData_UnallowedLanguageFileFileNameList = null;
            }
            if (errorTypeList)
            {
                Utils_Dispose.disposeArray(errorTypeList, true);
                errorTypeList = null;
            }

        }
    }
}
