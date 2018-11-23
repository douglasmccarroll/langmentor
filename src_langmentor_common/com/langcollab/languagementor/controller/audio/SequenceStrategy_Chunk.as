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

import com.brightworks.util.Log;
import com.brightworks.util.Utils_Dispose;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.vo.ChunkVO;

import flash.utils.Dictionary;

import mx.collections.ArrayCollection;

public class SequenceStrategy_Chunk extends SequenceStrategy {

   public var chunkType:String;

   protected var orderSpecList_Explanatory:ArrayCollection = null;

   protected override function get orderSpecList():ArrayCollection {
      switch (chunkType) {
         case ChunkVO.CHUNK_TYPE__DEFAULT:
            return orderSpecList_Default;
         case ChunkVO.CHUNK_TYPE__EXPLANATORY:
            return orderSpecList_Explanatory;
         default:
            Log.error("SequenceStrategy_Chunk.get orderSpecList() - no case for chunkType of: " + chunkType);
            return orderSpecList_Default;
      }
   }

   public function SequenceStrategy_Chunk():void {
      orderSpecList_Explanatory = new ArrayCollection();
      orderSpecList_Explanatory.addItem(Constant_LangMentor_Misc.LEAF_TYPE__PAUSE_1000_MS);
      orderSpecList_Explanatory.addItem(Constant_LangMentor_Misc.LEAF_TYPE__AUDIO_EXPLANATORY);
   }

   public override function dispose():void {
      if (orderSpecList_Explanatory) {
         Utils_Dispose.disposeArrayCollection(orderSpecList_Explanatory, true);
         orderSpecList_Explanatory = null;
      }
      super.dispose();
   }

   public function init(elements:Dictionary):void {
      this.elements = elements;
   }

}
}
