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
package com.langcollab.languagementor.model {
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Dispose;

import flash.utils.Dictionary;

public class LessonDownloadInfo_Libraries implements IDisposable {
   public var index_libraryFolderURL_to_lessonDownloadInfo_library:Dictionary;

   private var _isDisposed:Boolean = false;

   public function LessonDownloadInfo_Libraries() {
      index_libraryFolderURL_to_lessonDownloadInfo_library = new Dictionary();
   }

   public function dispose():void {
      Log.debug("LessonDownloadInfo_Libraries.dispose()");
      if (_isDisposed)
         return;
      if (index_libraryFolderURL_to_lessonDownloadInfo_library) {
         Utils_Dispose.disposeDictionary(index_libraryFolderURL_to_lessonDownloadInfo_library, true);
         index_libraryFolderURL_to_lessonDownloadInfo_library = null;
      }
   }

}
}
