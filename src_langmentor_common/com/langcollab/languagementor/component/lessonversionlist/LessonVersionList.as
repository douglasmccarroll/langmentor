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
package com.langcollab.languagementor.component.lessonversionlist {
// We're using composition instead of subclassing TreeList because we may
// want the ability to specify the tree list class in the future. For
// example, we may develop a CheckboxTreeList. But it might be better
// to subclass TreeList and pass in a custom ItemRenderer.

import com.brightworks.component.treelist.TreeItem;
import com.brightworks.component.treelist.TreeList;
import com.brightworks.event.Event_TreeList;
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_ArrayVectorEtc;
import com.brightworks.util.Utils_Dispose;
import com.langcollab.languagementor.event.Event_LessonVersionList;
import com.langcollab.languagementor.vo.LessonVersionVO;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.core.ClassFactory;

import spark.components.Group;
import spark.events.IndexChangeEvent;

[Event(name="event_LessonVersionList_LevelChange", type="com.langcollab.languagementor.event.Event_LessonVersionList")]

public class LessonVersionList extends Group implements IDisposable {
   public static const LEVEL_DISPLAY_NAME__LESSONS:String = "Lessons";
   public static const LEVEL_DISPLAY_NAME__LEVEL:String = "Level";
   public static const LEVEL_DISPLAY_NAME__LIBRARY:String = "Library";

   public var allowMultipleSelection:Boolean;

   private var _isDisposed:Boolean = false;
   private var _currentParentTreeItem:TreeItem;
   private var _selectedLessonVersionVOs:Array;
   private var _treeData:ArrayCollection;
   private var _treeList:TreeList;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters / Setter
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private var _currentLevelDisplayName:String = "";

   public function get currentLevelDisplayName():String {
      return _currentLevelDisplayName;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function LessonVersionList(treeData:ArrayCollection, selectedLessons:Array) {
      super();
      Log.debug("LessonVersionList constructor");
      _treeData = treeData;
      _selectedLessonVersionVOs = selectedLessons.slice();
      createTreeListComponent(_treeData);
   }

   public function dispose():void {
      Log.debug("LessonVersionList.dispose()");
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (_selectedLessonVersionVOs) {
         Utils_Dispose.disposeArray(_selectedLessonVersionVOs, false);
         _selectedLessonVersionVOs = null;
      }
      if (_treeData) {
         Utils_Dispose.disposeArrayCollection(_treeData, true);
         _treeData = null;
      }
      if (_treeList) {
         removeElement(_treeList);
         _treeList = null;
      }
   }

   public function handleBackButton():void {
      _currentParentTreeItem = _currentParentTreeItem.parent;
      var newDataProvider:ArrayCollection =
            (_currentParentTreeItem) ?
                  _currentParentTreeItem.children :
                  _treeData;
      createTreeListComponent(newDataProvider);
   }

   public function isListAtTopLevel():Boolean {
      return (_currentParentTreeItem == null);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function createSelectedIndicesVectorForLeafList(dataProvider:ArrayCollection):Vector.<int> {
      var result:Vector.<int> = new Vector.<int>();
      for (var i:int = 0; i < dataProvider.length; i++) {
         var ti:TreeItem = TreeItem(dataProvider[i]);
         var vo:LessonVersionVO = ti.data.lessonVersionVO;
         if (Utils_ArrayVectorEtc.useVoEqualsFunctionToGetIndexOfVoInArray(vo, _selectedLessonVersionVOs) != -1) {
            result.push(i)
         }
      }
      return result;
   }

   private function createTreeListComponent(dataProvider:ArrayCollection, isLeafs:Boolean = false):void {
      if (_treeList) {
         _treeList.dataProvider = null;
         removeElement(_treeList);
      }
      _treeList = new TreeList();
      _treeList.percentHeight = 100;
      _treeList.percentWidth = 100;
      _treeList.dataProvider = dataProvider;
      _treeList.itemRenderer = new ClassFactory(ItemRenderer_LessonVersionList);
      if (isLeafs) {
         _treeList.allowMultipleSelection = allowMultipleSelection;
         _treeList.selectedIndices = createSelectedIndicesVectorForLeafList(dataProvider);
         if (allowMultipleSelection)
            _treeList.addEventListener(Event_TreeList.TOGGLE_LEAF_ITEM, onLeafsTreeListChange);
         else
            _treeList.addEventListener(IndexChangeEvent.CHANGE, onLeafsTreeListChange);

      }
      else {
         _treeList.allowMultipleSelection = false;
         _treeList.addEventListener(IndexChangeEvent.CHANGE, onBranchesTreeListChange);
      }
      addElement(_treeList);
      var e:Event_LessonVersionList = new Event_LessonVersionList(Event_LessonVersionList.LEVEL_CHANGE);
      // dmccarroll 20121123
      // The next line is kludgy - every item in dataProvider has the same levelDisplayName - in other words the children are holding info
      // that should be carried by their parent. But their parent is an ArrayCollection and I suspect that if I try to subclass
      // ArrayCollection and add a levelDisplayName prop I'll run into problems - and I'm not sure that design purity justifies the
      // additional complexity that I'd have to introduce to correct this in another way.
      _currentLevelDisplayName = TreeItem(dataProvider[0]).levelDisplayName;
      dispatchEvent(e);
   }

   private function onBranchesTreeListChange(event:IndexChangeEvent):void {
      if (!_treeList)
         return;
      _currentParentTreeItem = _treeList.selectedItem;
      createTreeListComponent(_currentParentTreeItem.children, _currentParentTreeItem.areAllChildrenLeafs());
   }

   private function onLeafsTreeListChange(event:Event):void {
      if (!_treeList)
         return;
      var vo:LessonVersionVO;
      if (event is Event_TreeList) {
         vo = Event_TreeList(event).leafData.data.lessonVersionVO;
      }
      else if (event is IndexChangeEvent) {
         if (_treeList.selectedItem is TreeItem) {
            vo = TreeItem(_treeList.selectedItem).data.lessonVersionVO;
         }
         else {
            return;
         }
      }
      else {
         Log.error("LessonVersionList.onLeafsTreeListChange(): event is neither Event_TreeList or IndexChangeEvent");
         return;
      }
      var voIndex:int = Utils_ArrayVectorEtc.useVoEqualsFunctionToGetIndexOfVoInArray(vo, _selectedLessonVersionVOs);
      if (voIndex == -1) {
         _selectedLessonVersionVOs.push(vo);
      }
      else {
         _selectedLessonVersionVOs.splice(voIndex, 1);
      }
      var e:Event_LessonVersionList = new Event_LessonVersionList(Event_LessonVersionList.TOGGLE_LESSON_SELECTED);
      e.lessonVersionVO = vo;
      dispatchEvent(e);
   }

}
}

