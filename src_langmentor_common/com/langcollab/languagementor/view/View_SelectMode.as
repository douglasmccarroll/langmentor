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
package com.langcollab.languagementor.view {
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_ANEs;
import com.brightworks.util.Utils_Dispose;
import com.langcollab.languagementor.component.learningmodelist.ItemRenderer_LearningModeList;
import com.langcollab.languagementor.component.learningmodelist.LearningModeList;
import com.langcollab.languagementor.component.learningmodelist.LearningModeListItem;
import com.langcollab.languagementor.constant.Constant_LearningModeLabels;
import com.langcollab.languagementor.constant.Constant_UserActionTypes;
import com.langcollab.languagementor.controller.Command_ChangeCurrentLearningMode;
import com.langcollab.languagementor.controller.useractionreporting.UserAction;
import com.langcollab.languagementor.controller.useractionreporting.UserActionReportingManager;
import com.langcollab.languagementor.event.Event_LearningModeList;
import com.langcollab.languagementor.model.MainModel;
import com.langcollab.languagementor.view.supportClasses.ViewContext;
import com.langcollab.languagementor.vo.LearningModeVO;

import flash.events.Event;
import flash.utils.Dictionary;

import mx.binding.utils.ChangeWatcher;
import mx.collections.ArrayCollection;
import mx.core.ClassFactory;
import mx.core.FlexGlobals;

import spark.components.List;
import spark.events.IndexChangeEvent;

public class View_SelectMode extends View_Base implements IDisposable {
   private var _index_ButtonToLearningModeVO:Dictionary;
   private var _isDisposed:Boolean = false;
   private var _isListComponentInstantiated:Boolean = false;
   [Bindable]
   private var _learningModeListIndexHistory:Array = []; // There may be a simpler way to do things - this was created before "leave screen when mode selected" was implemented
   private var _modeList:List;
   private var _modeListDataProvider:ArrayCollection;
   private var _watcher_IsModelDataInitialized:ChangeWatcher;

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function View_SelectMode() {
      super();
      title = "Select Mode";
      _watcher_IsModelDataInitialized =
            ChangeWatcher.watch(model, "isDataInitialized", onModelDataInitialized);
   }

   override public function dispose():void {
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (_index_ButtonToLearningModeVO) {
         Utils_Dispose.disposeDictionary(_index_ButtonToLearningModeVO, true);
         _index_ButtonToLearningModeVO = null;
      }
      if (_modeListDataProvider) {
         Utils_Dispose.disposeArrayCollection(_modeListDataProvider, true);
         _modeListDataProvider = null;
      }
      if (_watcher_IsModelDataInitialized) {
         _watcher_IsModelDataInitialized.unwatch();
         _watcher_IsModelDataInitialized = null;
      }
      model = null;
   }

   override public function doGoBack():void {
      Log.info("View_SelectMode.doGoBack()");
      saveSelectedLearningMode();
      var mode:LearningModeVO = model.getLearningModeVOFromID(model.currentLearningModeId);
      if (mode.isDualLanguage) {
         if ((currentLessons.getSelectedSingleLanguageLessonVersionCount() > 0) && !model.isSingleLanguageLessonsSelectedInDualLanguageModeAlertDisplayed) {
            var message:String =
                  createMessage_DualLanguageModeSelectedWhileSingleLanguageLessonsSelected();
            Utils_ANEs.showAlert_OkayButton(message, onDualLanguageModeSelectedWhileSingleLanguageLessonsSelectedMessageClose);
            model.isSingleLanguageLessonsSelectedInDualLanguageModeAlertDisplayed = true;
         }
         else {
            doGoBack_Continued();
         }
      }
      else {
         doGoBack_Continued();
      }
   }

   public function doGoBack_Continued():void {
      navigator.pushView(View_Home, null, null, transition_SlideView_Left);
   }

   // ****************************************************
   //
   //          Protected Methods
   //
   // ****************************************************

   override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
      super.updateDisplayList(unscaledWidth, unscaledHeight);
      if ((model) && (model.isDataInitialized)) {
         // We make sure that we only do this once. The act of creation
         // invalidates the display list, so we'll get an endless loop if we don't.
         if ((navigator.actionBar) &&
               (navigator.actionBar.height) &&
               (navigator.actionBar.height > 0) &&
               (!_isListComponentInstantiated)) {
            createUI();
            invalidateDisplayList();
         }
      }
   }

   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************

   private function createMessage_DualLanguageModeSelectedWhileSingleLanguageLessonsSelected():String {
      var repeatNativeModeString:String = model.getLearningModeDisplayNameFromLabelToken(Constant_LearningModeLabels.TARGET_PAUSE);
      return 'The selected learning mode is a dual-language mode. Single-language lessons will be played in ' + repeatNativeModeString + ' mode.';
      /*var isAllSelectedLessonsSingleMode:Boolean =
          (model.getLessonVersionCount_SingleLanguage() == currentLessons.length);
      var isMultipleLessonsSelected:Boolean = (currentLessons.length > 1);
      var isMultipleSingleLangLessonsSelected:Boolean = (currentLessons.getSelectedSingleLanguageLessonVersionCount() > 1);
      var doNotString:String = isMultipleSingleLangLessonsSelected ? "don't" : "doesn't";
      var isAreSingleLanguageLessonString:String = isMultipleSingleLangLessonsSelected ? "are single-language lessons" : "is a single-language lesson";
      var itTheyString:String = isMultipleSingleLangLessonsSelected ? "they" : "it";
      var nativeLanguageString:String = model.getCurrentNativeLanguageDisplayName_InCurrentNativeLanguage();
      var thisLessonString:String = isMultipleSingleLangLessonsSelected ? "These lessons" : "This lesson";
      var result:String =
          "The " +
          _modeList.selectedItem.label +
          " learning mode provides " +
          nativeLanguageString +
          " translations for lesson content, but " +
          currentLessons.getSelectedSingleLanguageLessonVersionCount() +
          " of the lessons that are currently selected " +
          isAreSingleLanguageLessonString +
          ", i.e. " +
          itTheyString +
          " " +
          doNotString +
          " offer " + nativeLanguageString + " translation. " +
          thisLessonString +
          " will be played using " +
          repeatNativeModeString +
          " mode.";
      return result;*/
   }

   private function createUI():void {
      _index_ButtonToLearningModeVO = new Dictionary();
      _modeListDataProvider = new ArrayCollection;
      var learningModeIds:Array = model.getLearningModeIDListSortedByLocationInOrder();
      var currentListIndex:int = -1;
      var listIndexForCurrentLearningModeId:int = -1;
      for each (var learningModeId:int in learningModeIds) {
         var learningModeVO:LearningModeVO = model.getLearningModeVOFromID(learningModeId);
         if ((!(model.isAppDualLanguage())) && (learningModeVO.isDualLanguage))
            continue;
         currentListIndex++;
         if (learningModeId == model.currentLearningModeId)
            listIndexForCurrentLearningModeId = currentListIndex;
         var modeLabelToken:String = learningModeVO.labelToken;
         var modeLabel:String = model.getLearningModeDisplayNameFromLabelToken(modeLabelToken);
         var item:LearningModeListItem = new LearningModeListItem();
         item.isDualLanguage = learningModeVO.isDualLanguage;
         item.label = modeLabel;
         item.value = learningModeId;
         _modeListDataProvider.addItem(item);
      }
      _modeList = new LearningModeList();
      _modeList.itemRenderer = new ClassFactory(ItemRenderer_LearningModeList);
      _modeList.percentWidth = 100;
      _modeList.percentHeight = 100;
      _modeList.dataProvider = _modeListDataProvider;
      _modeList.addEventListener(IndexChangeEvent.CHANGE, onModeListChange);
      _modeList.addEventListener(Event_LearningModeList.DISPLAY_LEARNING_MODE_HELP, onModeListDisplayLearningModeHelp);
      addElement(_modeList);
      _modeList.selectedIndex = listIndexForCurrentLearningModeId;
      _learningModeListIndexHistory.push(listIndexForCurrentLearningModeId);
      _isListComponentInstantiated = true;
   }

   private function onDualLanguageModeSelectedWhileSingleLanguageLessonsSelectedMessageClose():void {
      callLater(doGoBack_Continued);
   }

   private function onModelDataInitialized(event:Event):void {
      if (_watcher_IsModelDataInitialized) {
         _watcher_IsModelDataInitialized.unwatch();
         _watcher_IsModelDataInitialized = null;
      }
      this.invalidateDisplayList();
   }

   private function onModeListChange(event:IndexChangeEvent):void {
      Log.info("View_SelectMode.onModeListChange(): " + event.newIndex);
      _learningModeListIndexHistory.push(_modeList.selectedIndex);
      callLater(onModeListChange_Continued);
   }

   private function onModeListChange_Continued():void {
      // This is a bit convoluted and/or unclear...
      // Help button click calls pushView() which eventually calls dispose(). Then, this method gets called.
      // So, in that case, the right thing (i.e. nothing) happens.
      // Also, if this is called as a result of the user selecting a mode in the list, the right thing (doGoBack()) happens.
      if (!_isDisposed)
         doGoBack();
   }

   private function onModeListDisplayLearningModeHelp(event:Event_LearningModeList):void {
      // If we clicked the button on any item except the selected item, onModeListChange() was called, and a spurious item was added
      // to _learningModeListIndexHistory.
      if (event.learningModeId != model.currentLearningModeId)
         _learningModeListIndexHistory.pop();
      _modeList.selectedIndex = _learningModeListIndexHistory[_learningModeListIndexHistory.length - 1]; // Prevents selected item from changing before transition to help screen
      var ctxt:ViewContext = new ViewContext(ViewContext.CONTEXT_TYPE__SELECT_MODE_SCREEN_HELP);
      navigator.pushView(View_SelectModeHelp, event.learningModeId, ctxt, transition_SlideView_Right);
      reportUserActivity_ViewHelp(event.learningModeId);
   }

   private function reportUserActivity_ViewHelp(learningModeId:int):void {
      var activity:UserAction = new UserAction();
      activity.actionType = Constant_UserActionTypes.LEARNING_MODES__VIEW_HELP;
      activity.learningModeDisplayName = MainModel.getInstance().getLearningModeDisplayNameFromId(learningModeId);
      UserActionReportingManager.reportActivityIfUserHasActivatedReporting(activity);
   }

   private function saveSelectedLearningMode():void {
      if (_modeList.selectedIndex != -1) {
         var c:Command_ChangeCurrentLearningMode = new Command_ChangeCurrentLearningMode(_modeList.selectedItem.value);
         c.execute();
      }
   }

}
}

