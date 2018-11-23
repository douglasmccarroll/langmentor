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

public class SequenceStrategy_RepeatTarget extends SequenceStrategy_Chunk implements ISequenceStrategy {
   public function SequenceStrategy_RepeatTarget():void {
      orderSpecList_Default = new ArrayCollection();
      orderSpecList_Default.addItem(Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_500_MS);
      orderSpecList_Default.addItem(Constant_LangMentor_Misc.LEAF_TYPE__AUDIO_TARGET);
      orderSpecList_Default.addItem(Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_REPEAT);
   }

   public function clone():ISequenceStrategy {
      var instance:SequenceStrategy_RepeatTarget = new SequenceStrategy_RepeatTarget();
      instance.orderSpecList_Default = this.orderSpecList_Default;
      return instance;
   }
}
}