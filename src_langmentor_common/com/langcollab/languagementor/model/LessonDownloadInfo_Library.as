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
	import com.brightworks.util.Utils_Dispose;

	import flash.utils.Dictionary;

	public class LessonDownloadInfo_Library implements IDisposable
	{
		public var contentProviderId:String;
		public var contentProviderName:String;
		public var index_LessonIds_To_LessonDownloadInfo_Lessons:Dictionary = new Dictionary();
		public var libraryName:String;
		public var libraryId:String;
		public var libraryFolderUrl:String;

		private var _isDisposed:Boolean = false;

		public function LessonDownloadInfo_Library()
		{
		}

		public function dispose():void
		{
			if (_isDisposed)
				return;
			if (index_LessonIds_To_LessonDownloadInfo_Lessons)
			{
				Utils_Dispose.disposeDictionary(index_LessonIds_To_LessonDownloadInfo_Lessons, true);
				index_LessonIds_To_LessonDownloadInfo_Lessons = null;
			}
		}
	}
}
