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
package com.langcollab.languagementor.vo {
import com.brightworks.vo.VO;

import flash.events.Event;

public class LanguageReferencingVO extends VO {
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private var _languageId:int;

   public function get languageId():int {
      return _languageId;
   }

   public function set languageId(value:int):void {
      setPropList.push("languageId");
      if (_languageId != value) {
         _languageId = value;
         dispatchEvent(new Event("valueChange"));
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function LanguageReferencingVO() {
      super();
   }

}
}
