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



This class is responsible for encapsulating the LessonVersions that are currently selected by the user.
We're using this class, rather than simply using an ArrayCollection because we're had bugs that were
caused by code not updating the current selected index after adding or removing LessonVersions. This
class encapsulates/handles that logic.









See notes at top of CurrentLessons class for an explanation of why this class is used.






*/
package com.langcollab.languagementor.model.currentlessons {
import com.langcollab.languagementor.event.Event_CurrentLessonsAudioTimer;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class CurrentLessonsAudioTimer extends EventDispatcher {
   private static const _TIMER_PERIOD__AUDIO_DELAY:uint = 800;

   private var _timer_audioDelay:Timer;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function CurrentLessonsAudioTimer() {
   }

   public function cancelAllAudioPlayPermissionRequests():void {
      if (_timer_audioDelay)
         _timer_audioDelay.stop();
   }

   public function requestAudioPlayPermission():void {
      startOrRestartAudioDelayTimer();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function onTimer_AudioDelay(event:TimerEvent):void {
      if (_timer_audioDelay)
         _timer_audioDelay.stop();
      dispatchEvent(new Event_CurrentLessonsAudioTimer(Event_CurrentLessonsAudioTimer.AUDIO_PLAY_ALLOWED));
   }

   private function startOrRestartAudioDelayTimer():void {
      if (_timer_audioDelay) {
         _timer_audioDelay.stop();
         _timer_audioDelay.removeEventListener(TimerEvent.TIMER, onTimer_AudioDelay);
         _timer_audioDelay = null;
      }
      _timer_audioDelay = new Timer(_TIMER_PERIOD__AUDIO_DELAY, 1);
      _timer_audioDelay.addEventListener(TimerEvent.TIMER, onTimer_AudioDelay);
      _timer_audioDelay.start();
   }


}
}




























