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
package com.langcollab.languagementor.event {
import com.brightworks.event.BwEvent;
import com.brightworks.techreport.ITechReport;

public class Event_CurrentLessonsAudioTimer extends BwEvent {
   public static const AUDIO_PLAY_ALLOWED:String = "event_CurrentLessonsAudioTimer_AudioPlayAllowed";

   public function Event_CurrentLessonsAudioTimer(type:String, techReport:ITechReport = null, info:Object = null) {
      super(type, techReport, info);
   }
}
}
