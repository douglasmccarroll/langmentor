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
package com.langcollab.languagementor.event {
import com.brightworks.event.BwEvent;

import flash.events.Event;

public class Event_AudioProgress extends BwEvent {
   public static const ELEMENT_COMPLETE_REPORT:String = "elementCompleteReport";
   public static const ELEMENT_START_REPORT:String = "elementStartReport";
   public static const IOERROR_REPORT:String = "ioErrorReport";

   public var id:Object;
   public var levelId:String;
   public var message:Object;

   public function Event_AudioProgress(type:String, id:Object, levelId:String, message:Object = null) {
      super(type);
      this.id = id;
      this.levelId = levelId;
      this.message = message;
   }

   override public function clone():Event {
      return new Event_AudioProgress(ELEMENT_COMPLETE_REPORT, id, levelId);
   }
}
}
