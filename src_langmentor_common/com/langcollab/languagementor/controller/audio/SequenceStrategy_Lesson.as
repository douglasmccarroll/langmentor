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
import com.brightworks.util.Utils_ArrayVectorEtc;
import com.brightworks.util.Utils_Object;

import flash.utils.Dictionary;

import mx.collections.ArrayCollection;

public class SequenceStrategy_Lesson extends SequenceStrategy implements ISequenceStrategy {
   public function SequenceStrategy_Lesson():void {
   }

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function clone():ISequenceStrategy {
      // Currently this class never gets cloned by LangCollab but if it ever did,
      // as things stand now, it would need to initialize both _elements and
      // its spec list in init()
      return new SequenceStrategy_Lesson();
   }

   public function init(elements:Dictionary):void {
      this.elements = elements;
      createSpecList();
   }

   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************

   private function createSpecList():void {
      // If we're using a default spec list, our elements instance should have properties ranging
      // from 0 to some integer, in order. Let's check.
      if (Utils_ArrayVectorEtc.getDictionaryLength(elements) == 0)
         Log.fatal(["SequenceStrategy_OrderSpecList.createDefaultOrderSpecList(): elements is empty"]);
      if (!Utils_Object.doInstancesPropNamesConsistOfSequenceOfIntegers(elements, 0))
         Log.fatal(["SequenceStrategy_OrderSpecList.createDefaultOrderSpecList(): elements's propNames don't make up a zero-based sequence of integers:", elements]);
      // We've passed the check so we simply create a zero-based ArrayCollection of the correct length.
      // The net effect is that all of our elements will be used.
      var propCount:int = Utils_Object.getDynamicVariableCount(elements);
      var orderedArray:Array = Utils_ArrayVectorEtc.createArrayContainingSequenceOfIntegers(propCount - 1);
      orderSpecList_Default = new ArrayCollection(orderedArray);
   }
}
}













