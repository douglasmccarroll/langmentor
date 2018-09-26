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
import com.brightworks.vo.IVO;

import flash.events.Event;
import flash.utils.Dictionary;

public class AudioSequenceBranch extends AudioSequenceElement {
   private static var _availableInstancePool:Array = [];

   internal var autoAdvance:Boolean = true;
   internal var elements:Dictionary;
   internal var vo:IVO;

   private var _currentElement:AudioSequenceElement;
   private var _sequenceStrategy:ISequenceStrategy;

   // ****************************************************
   //
   //          Getters / Setters
   //
   // ****************************************************

   public function get currentElementIndex():int {
      // Not currently used (201305)
      //
      // We're actually looking for the index of _currentElement within the sequence defined by _sequenceStrategy.
      // So if our elements prop has props named "a", "b", "C", ... "z", and our sequence strategy is defining
      // our sequence as "g", "b", "h", and _currentElement references the value associated with "b", this
      // method should return the integer 1.
      //
      // We don't log anything here if (result == -1) because the log framework itself may be looking at this
      // before _sequenceStrategy has been initialized. So all uses of this (except the log framework) should
      // check for -1 after they access this.
      var result:int = _sequenceStrategy.currentOrderSpecListIndex;
      return result;
   }

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function AudioSequenceBranch(enforcer:Class) {
      super();
      if (enforcer != InstancePoolEnforcer)
         throw new Error("AudioSequenceBranch: create instances with acquireReusable()");
      isLeaf = false;
   }

   public static function acquireReusable(id:Object, levelId:String, vo:IVO, autoAdvance:Boolean = true):AudioSequenceBranch {
      var result:AudioSequenceBranch;
      if (_availableInstancePool.length > 0) {
         result = _availableInstancePool.pop();
         result.isDisposed = false;
      } else {
         result = new AudioSequenceBranch(InstancePoolEnforcer);
      }
      result.autoAdvance = autoAdvance;
      result.elements = new Dictionary();
      result.id = id;
      result.levelId = levelId;
      result.vo = vo;
      return result;
   }

   override public function dispose():void {
      removeEventListeners();
      _currentElement = null;
      if (_sequenceStrategy) {
         _sequenceStrategy.dispose();
         _sequenceStrategy = null;
      }
      if (elements) {
         Utils_Dispose.disposeDictionary(elements, true);
         elements = null;
      }
      vo = null;
      super.dispose();
      AudioSequenceBranch.releaseReusable(this);
   }

   public static function releaseReusable(instance:AudioSequenceBranch):void {
      if (_availableInstancePool.indexOf(instance) != -1)
         _availableInstancePool.push(instance);
   }

   public function getCurrentVOForLevel(levelId:String):IVO {
      var result:IVO;
      if (levelId == this.levelId) {
         result = vo;
      } else {
         if (_currentElement) {
            if (_currentElement.isLeaf)
               Log.fatal(["AudioSequenceBranch.getCurrentVOForLevel(): passed levelId doesn't match, and current element is a leaf:", levelId]);
            result = AudioSequenceBranch(_currentElement).getCurrentVOForLevel(levelId);
         } else {
            // This happens if we pause a chunk twice, i.e. with Pause button then by
            // leaving the play lessons view.
         }
      }
      return result;
   }

   public function moveToElement(levelWithinWhichToMoveToElement:String, id:Object):void {
      Log.debug(["AudioSequenceBranch.moveToElement(): levelWithinWhichToMoveToElement=" + levelWithinWhichToMoveToElement + " id:", id]);
      if (levelId == this.levelId) {
         if (_sequenceStrategy.isElementAllowed(id)) {
            var newElement:AudioSequenceElement = _sequenceStrategy.getElement(id);
            if (newElement != _currentElement) {
               cleanupCurrentElement();
            }
            _currentElement = newElement;
         } else {
            Log.warn("AudioSequenceBranch.moveToElement(): specified element not allowed");
         }
      } else {
         if (_currentElement.isLeaf)
            Log.fatal(["AudioSequenceBranch.moveToElement(): passed levelId doesn't match, and current element is a leaf:", levelId]);
         AudioSequenceBranch(_currentElement).moveToElement(levelId, id);
      }
   }

   override public function pause(levelIdForLevelToRestartFromBeginning:String):void {
      Log.debug(["AudioSequenceBranch.pause(): levelIdForLevelToRestartFromBeginning=" + levelIdForLevelToRestartFromBeginning]);
      super.pause(levelIdForLevelToRestartFromBeginning);
      if (levelIdForLevelToRestartFromBeginning == this.levelId) {
         // We don't call stop() here because it sets isPlaying to false, but otherwise
         // we pretty much duplicate its code here.
         cleanupCurrentElement();
         _sequenceStrategy.reset();
      } else {
         if (_currentElement) {
            _currentElement.pause(levelIdForLevelToRestartFromBeginning);
         } else {
            // This happens if we pause a chunk twice, i.e. with Pause button then by
            // leaving the play lessons view.
         }
      }
   }

   public function replayCurrentElement(levelId:String):void {
      Log.debug(["AudioSequenceBranch.replayCurrentElement(): levelId=" + levelId]);
      if (!_currentElement)
         Log.fatal("AudioSequenceBranch.replayCurrentElement(): no _currentElement");
      if (levelId == this.levelId) {
         startElementFromBeginning(_currentElement);
      } else {
         if (!_currentElement is AudioSequenceBranch)
            Log.fatal("AudioSequenceBranch.replayCurrentElement(): this.levelId doesn't match passed levelId, and _currentElement isn't branch");
         AudioSequenceBranch(_currentElement).replayCurrentElement(levelId);
      }
   }

   override public function resume(levelIdForLevelToRestartFromBeginning:String):void {
      Log.debug(["AudioSequenceBranch.resume(): levelIdForLevelToRestartFromBeginning=" + levelIdForLevelToRestartFromBeginning]);
      super.resume(levelIdForLevelToRestartFromBeginning);
      if (levelIdForLevelToRestartFromBeginning == this.levelId) {
         startElementFromBeginning(_sequenceStrategy.getFirstElement());
      } else {
         if (_currentElement) {
            _currentElement.resume(levelIdForLevelToRestartFromBeginning);
         } else {
            startElementFromBeginning(_sequenceStrategy.getFirstElement());
         }
      }
   }

   public function setSequenceStrategy(strategy:ISequenceStrategy, levelId:String):void {
      Log.debug(["AudioSequenceBranch.setSequenceStrategy(): levelId=" + levelId, strategy]);
      if (this.levelId == levelId) {
         _sequenceStrategy = strategy;
         _sequenceStrategy.init(this.elements);
      } else {
         // call setSequenceStrategy() for all children
         for each (var element:AudioSequenceElement in elements) {
            if (!element.isLeaf) {
               AudioSequenceBranch(element).setSequenceStrategy(strategy.clone(), levelId);
            }
         }
      }
   }

   // This method should start playing the first element, whether or not 
   // we have a 'current element'
   override public function startFromBeginning():void {
      Log.debug(["AudioSequenceBranch.startFromBeginning()"]);
      //trace("AudioSeqenceBranch.start(): " + levelId + " " + id);
      super.startFromBeginning();
      AudioRecorder.getInstance().clear();
      cleanupCurrentElement();
      startElementFromBeginning(_sequenceStrategy.getFirstElement());
   }

   public function startFromCurrentElement(levelThroughWhichToUseCurrentElement:String):void {
      Log.debug(["AudioSequenceBranch.startFromCurrentElement(): levelThroughWhichToUseCurrentElement=" + levelThroughWhichToUseCurrentElement]);
      if (!_currentElement) {
         startFromBeginning();
      } else if (levelThroughWhichToUseCurrentElement == levelId) {
         _currentElement.startFromBeginning();
      } else {
         if (_currentElement.isLeaf) {
            AudioSequenceLeaf(_currentElement).startFromBeginning();
         } else {
            AudioSequenceBranch(_currentElement).startFromCurrentElement(levelThroughWhichToUseCurrentElement);
         }
      }
   }

   override public function stop():void {
      Log.debug(["AudioSequenceBranch.stop()"]);
      super.stop();
      // We may not have a current element - see the pause() method for details
      if (_currentElement) {
         Log.debug(["AudioSequenceBranch.stop(): _currentElement:", _currentElement]);
         cleanupCurrentElement();
      }
      _sequenceStrategy.reset();
   }

   // ****************************************************
   //
   //          Protected Methods
   //
   // ****************************************************

   override protected function onAllElementsComplete():void {
      Log.debug(["AudioSequenceBranch.onAllElementsComplete()", "this.vo:", vo]);
      super.onAllElementsComplete();
   }

   override protected function onElementComplete(event:Event):void {
      Log.debug(["AudioSequenceBranch.onElementComplete()", "event:", event, "this.vo:", vo]);
      if (isDisposed)
         return;
      var element:AudioSequenceElement;
      cleanupCurrentElement();
      if (autoAdvance) {
         if (_sequenceStrategy.hasNextElement()) {
            element = _sequenceStrategy.getNextElement();
            startElementFromBeginning(element);
         } else {
            onAllElementsComplete();
         }
      } else {
         element = _sequenceStrategy.getCurrentElement();
         startElementFromBeginning(element);
      }
   }

   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************

   private function cleanupCurrentElement():void {
      removeEventListeners();
      if (_currentElement) {
         _currentElement.stop();
         /*if (_currentElement.isPlaying)
         {
             _currentElement.stop();
         }*/
         _currentElement = null;
      }
   }

   private function removeEventListeners():void {
      if (_currentElement) {
         _currentElement.removeEventListener(Event.COMPLETE, onElementComplete);
      }
   }

   private function startElementFromBeginning(element:AudioSequenceElement):void {
      Log.debug(["AudioSequenceBranch.startElementFromBeginning()", "this.vo:", vo, "Element:", element]);
      _currentElement = element;
      _currentElement.addEventListener(Event.COMPLETE, onElementComplete);
      element.startFromBeginning();
   }
}
}

class InstancePoolEnforcer {
}
