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
package com.langcollab.languagementor.controller.audio {
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;

import mx.collections.ArrayCollection;

public class SequenceStrategy_RepeatTargetWithPlayback extends SequenceStrategy_Chunk implements ISequenceStrategy {
   public function SequenceStrategy_RepeatTargetWithPlayback():void {
      orderSpecList = new ArrayCollection();
      orderSpecList.addItem(Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_INITIAL);
      orderSpecList.addItem(Constant_LangMentor_Misc.LEAF_TYPE__AUDIO_TARGET);
      orderSpecList.addItem(Constant_LangMentor_Misc.LEAF_TYPE__RECORD_REPEAT);
      orderSpecList.addItem(Constant_LangMentor_Misc.LEAF_TYPE__PLAYBACK);
   }

   public function clone():ISequenceStrategy {
      var instance:SequenceStrategy_RepeatTargetWithPlayback = new SequenceStrategy_RepeatTargetWithPlayback();
      instance.orderSpecList = this.orderSpecList;
      return instance;
   }
}
}
