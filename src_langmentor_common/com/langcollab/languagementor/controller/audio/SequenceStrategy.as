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
package com.langcollab.languagementor.controller.audio {
   import com.brightworks.interfaces.IDisposable;
   import com.brightworks.util.Log;
   import com.brightworks.util.Utils_Dispose;

   import flash.utils.Dictionary;

   import mx.collections.ArrayCollection;

   public class SequenceStrategy implements IDisposable {
      protected var orderSpecList:ArrayCollection = null;

      private var _isDisposed:Boolean = false;

      public function SequenceStrategy():void {
      }

      // ****************************************************
      //
      //          Getters / Setters
      //
      // ****************************************************

      private var _currentOrderSpecListIndex:int = -1;

      public function get currentOrderSpecListIndex():int {
         return _currentOrderSpecListIndex;
      }

      private var _elements:Dictionary;  // Getter/Setter for debugging

      protected function get elements():Dictionary {
         return _elements;
      }

      protected function set elements(value:Dictionary):void {
         _elements = value;
      }

      // ****************************************************
      //
      //          Public Methods
      //
      // ****************************************************

      public function dispose():void {
         if (_isDisposed)
            return;
         _isDisposed = true;
         if (elements) {
            // Don't do this here - AudioSequenceBranch does this
            // Utils_Dispose.disposeDictionary(_elements);
            elements = null;
         }
         if (orderSpecList) {
            Utils_Dispose.disposeArrayCollection(orderSpecList, true);
            orderSpecList = null;
         }
      }

      public function getCurrentElement():AudioSequenceElement {
         return elements[orderSpecList[_currentOrderSpecListIndex]];
      }

      public function getElement(id:Object):AudioSequenceElement {
         if (!isElementAllowed(id))
            Log.fatal(["SequenceStrategy.getElement(): passed id not allowed:", id]);
         _currentOrderSpecListIndex = orderSpecList.getItemIndex(id);
         return getCurrentElement();
      }

      public function getFirstElement():AudioSequenceElement {
         reset();
         if (!hasNextOrderSpecListIndexWhereMatchingElementExists())
            Log.fatal("SequenceStrategy.getFirstElement(): no next element - call hasElements() before calling this method");
         return getNextElement();
      }

      public function getNextElement():AudioSequenceElement {
         if (!hasNextOrderSpecListIndexWhereMatchingElementExists())
            Log.fatal("SequenceStrategy.getNextElement(): no next element - call hasNextElement() before calling this method");
         iterateToNextOrderSpecListIndexWhereMatchingElementExists();
         return getCurrentElement();
      }

      public function hasElements():Boolean {
         for (var i:int = 0; i < (orderSpecList.length - 1); i++) {
            if (elements.hasOwnProperty(orderSpecList[i])) {
               return true;
            }
         }
         return false;
      }

      public function hasNextElement():Boolean {
         return hasNextOrderSpecListIndexWhereMatchingElementExists();
      }

      public function isElementAllowed(id:Object):Boolean {
         if (!elements.hasOwnProperty(String(id)))
            return false;
         if (!orderSpecList.contains(id))
            return false;
         return true;
      }

      public function reset():void {
         _currentOrderSpecListIndex = -1;
      }

      // ****************************************************
      //
      //          Private Methods
      //
      // ****************************************************

      private function getNextOrderSpecListIndexWhereMatchingElementExists():int {
         for (var i:int = currentOrderSpecListIndex + 1; i < orderSpecList.length; i++) {
            if (elements.hasOwnProperty(orderSpecList[i])) {
               return i;
            }
         }
         return -1;
      }

      private function hasNextOrderSpecListIndexWhereMatchingElementExists():Boolean {
         return (getNextOrderSpecListIndexWhereMatchingElementExists() >= 0);
      }

      private function iterateToNextOrderSpecListIndexWhereMatchingElementExists():void {
         if (getNextOrderSpecListIndexWhereMatchingElementExists() < 0)
            Log.fatal("mx.collections.ArrayCollection.SequenceStrategy.iterateToNextOrderSpecListIndexWhereMatchingElementExists(): call hasNextOrderSpecListIndexWhereMatchingElementExists() before calling this method");
         _currentOrderSpecListIndex = getNextOrderSpecListIndexWhereMatchingElementExists();
      }
   }
}
