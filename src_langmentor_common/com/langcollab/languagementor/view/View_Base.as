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
import com.brightworks.event.BwEvent;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_ANEs;
import com.brightworks.util.Utils_System;
import com.brightworks.util.gestures.GestureTranslator;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.controller.audio.AudioController;
import com.langcollab.languagementor.controller.lessondownload.LessonDownloadController;
import com.langcollab.languagementor.model.MainModel;
import com.langcollab.languagementor.model.appstatepersistence.AppStatePersistenceManager;
import com.langcollab.languagementor.model.currentlessons.CurrentLessons;
import com.langcollab.languagementor.view.supportClasses.ViewContext;

import flash.display.StageOrientation;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TransformGestureEvent;

import mx.events.ResizeEvent;

import spark.components.BusyIndicator;

import spark.components.View;
import spark.components.ViewMenuItem;
import spark.events.ViewNavigatorEvent;
import spark.skins.mobile.BusyIndicatorSkin;
import spark.transitions.CrossFadeViewTransition;
import spark.transitions.SlideViewTransition;
import spark.transitions.ViewTransitionDirection;

public class View_Base extends View {
   private static const VIEW_MENU_ITEM_LABEL__CREDITS:String = "Credits";
   private static const VIEW_MENU_ITEM_LABEL__HELP:String = "Help";
   private static const VIEW_MENU_ITEM_LABEL__SEND_FEEDBACK:String = "Send Feedback";

   public var transition_CrossFade:CrossFadeViewTransition;

   protected var appStatePersistenceManager:AppStatePersistenceManager = AppStatePersistenceManager.getInstance();
   protected var audioController:AudioController = AudioController.getInstance();
   protected var currentLessons:CurrentLessons = CurrentLessons.getInstance();
   protected var isCustomGesturesEnabled:Boolean = false;
   [Bindable]
   protected var model:MainModel = MainModel.getInstance();
   protected var lessonDownloadController:LessonDownloadController = LessonDownloadController.getInstance();
   protected var transition_SlideView_Down:SlideViewTransition;
   protected var transition_SlideView_Left:SlideViewTransition;
   protected var transition_SlideView_Right:SlideViewTransition;
   protected var transition_SlideView_Up:SlideViewTransition;

   private var _busyIndicator:BusyIndicator;
   private var _gestureTranslator:GestureTranslator;
   private var _isDisposed:Boolean = false;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters / Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function get context():ViewContext {
      return ViewContext(navigator.context);
   }

   public function get contextType():String {
      if ((!navigator) || (!(navigator.context is ViewContext)))
         return null;
      return ViewContext(navigator.context).contextType;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function View_Base() {
      super();
      transition_CrossFade = new CrossFadeViewTransition();
      transition_CrossFade.duration = Constant_LangMentor_Misc.EFFECT__CROSSFADE_TRANSITION_DURATION;
      transition_SlideView_Down = new SlideViewTransition();
      transition_SlideView_Down.direction = ViewTransitionDirection.DOWN;
      transition_SlideView_Down.duration = Constant_LangMentor_Misc.EFFECT__SLIDE_TRANSITION_DURATION;
      transition_SlideView_Left = new SlideViewTransition();
      transition_SlideView_Left.direction = ViewTransitionDirection.LEFT;
      transition_SlideView_Left.duration = Constant_LangMentor_Misc.EFFECT__SLIDE_TRANSITION_DURATION;
      transition_SlideView_Right = new SlideViewTransition();
      transition_SlideView_Right.direction = ViewTransitionDirection.RIGHT;
      transition_SlideView_Right.duration = Constant_LangMentor_Misc.EFFECT__SLIDE_TRANSITION_DURATION;
      transition_SlideView_Up = new SlideViewTransition();
      transition_SlideView_Up.direction = ViewTransitionDirection.UP;
      transition_SlideView_Up.duration = Constant_LangMentor_Misc.EFFECT__SLIDE_TRANSITION_DURATION;
      addEventListener(MouseEvent.DOUBLE_CLICK, onBaseDoubleClick);
      addEventListener(MouseEvent.MOUSE_DOWN, onBaseMouseDown);
      addEventListener(MouseEvent.MOUSE_MOVE, onBaseMouseMove);
      addEventListener(MouseEvent.MOUSE_UP, onBaseMouseUp);
      addEventListener(ResizeEvent.RESIZE, onBaseResize);
      addEventListener(TransformGestureEvent.GESTURE_SWIPE, onBaseGestureSwipe);
      addEventListener(ViewNavigatorEvent.REMOVING, onRemoving);
      doubleClickEnabled = true;
      if (stage) {
         onAddedToStage();
      }
      else {
         addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
      }
      createViewMenu();
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      removeEventListener(MouseEvent.DOUBLE_CLICK, onBaseDoubleClick);
      removeEventListener(MouseEvent.MOUSE_DOWN, onBaseMouseDown);
      removeEventListener(MouseEvent.MOUSE_MOVE, onBaseMouseMove);
      removeEventListener(MouseEvent.MOUSE_UP, onBaseMouseUp);
      removeEventListener(ResizeEvent.RESIZE, onBaseResize);
      removeEventListener(TransformGestureEvent.GESTURE_SWIPE, onBaseGestureSwipe);
      removeEventListener(ViewNavigatorEvent.REMOVING, onRemoving);
      for each (var vmi:ViewMenuItem in viewMenuItems) {
         vmi.removeEventListener(MouseEvent.CLICK, onViewMenuItemClick);
      }
      if (_busyIndicator) {
         _busyIndicator.visible = false;
         removeElement(_busyIndicator);
         _busyIndicator = null;
      }
   }

   // This needs to be public because the app does this:
   //   View_Base(navigator.activeView).doGoBack();
   public function doGoBack():void {
      navigator.popView();
   }

   // This needs to be public because the app does this:
   //   View_Base(navigator.activeView).doGoHome();
   public function doGoHome():void {
      navigator.pushView(View_Home, null, null, transition_SlideView_Left);
   }

   public function startBusyIndicator():void {
      if (!_busyIndicator) {
         _busyIndicator = new BusyIndicator();
         _busyIndicator.visible = false;
         _busyIndicator.horizontalCenter = 0;
         _busyIndicator.verticalCenter = 0;
         _busyIndicator.alpha = .5;
         _busyIndicator.setStyle("skinClass", BusyIndicatorSkin);
         addElement(_busyIndicator);
      }
      _busyIndicator.height = width / 6;
      _busyIndicator.width = width / 6;
      _busyIndicator.visible = true;
   }

   public function stopBusyIndicator():void {
      if (_busyIndicator) {
         _busyIndicator.visible = false;
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   protected function createViewMenu():void {
      //// 20200602 dmccarroll - looks like I wrote this code long ago - and haven't used it in a long time, if ever
      /*viewMenuItems = new Vector.<ViewMenuItem>();
      var vmi:ViewMenuItem;
      vmi = new ViewMenuItem();
      vmi.label = VIEW_MENU_ITEM_LABEL__CREDITS;
      vmi.addEventListener(MouseEvent.CLICK, onViewMenuItemClick);
      viewMenuItems.push(vmi);
      vmi = new ViewMenuItem();
      vmi.label = VIEW_MENU_ITEM_LABEL__HELP;
      vmi.addEventListener(MouseEvent.CLICK, onViewMenuItemClick);
      viewMenuItems.push(vmi);
      vmi = new ViewMenuItem();
      vmi.label = VIEW_MENU_ITEM_LABEL__SEND_FEEDBACK;
      vmi.addEventListener(MouseEvent.CLICK, onViewMenuItemClick);
      viewMenuItems.push(vmi);*/

   }

   override protected function createChildren():void {
      super.createChildren();
      navigator.actionBar.setStyle("color", 0xFFFFFF);
   }

   protected function onAddedToStage(event:Event = null):void {
      removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
      stage.autoOrients = false;
      stage.setOrientation(StageOrientation.DEFAULT);
   }

   protected function onBaseDoubleClick(event:MouseEvent):void {
      if (this is View_Intro_Base)
         return;
      if (!Utils_System.isAlphaOrBetaVersion())
         return;
      //var logDataString:String = Log.createLogInfoSummaryString() + "\n\n" + Log.getLogInfoForClipboard();
      Log.copyRecentInfoToClipboard();
      Utils_ANEs.showAlert_Toast("Log data copied to clipboard");
      Log.displayDiagnosticsScreen();
   }

   protected function onCustomGesture_Arrow_Down():void {
      // Abstract method - override if desired
   }

   protected function onCustomGesture_Arrow_Left():void {
      // Abstract method - override if desired
   }

   protected function onCustomGesture_Arrow_Right():void {
      // Abstract method - override if desired
   }

   protected function onCustomGesture_Arrow_Up():void {
      // Abstract method - override if desired
   }

   protected function onCustomGesture_Circle():void {
      // Abstract method - override if desired
   }

   protected function onCustomGesture_SwipeDown():void {
      // Abstract method - override if desired
   }

   protected function onCustomGesture_SwipeDownLeft():void {
      // Abstract method - override if desired
   }

   protected function onCustomGesture_SwipeDownRight():void {
      // Abstract method - override if desired
   }

   protected function onCustomGesture_SwipeLeft():void {
      // Abstract method - override if desired
   }

   protected function onCustomGesture_SwipeRight():void {
      // Abstract method - override if desired
   }

   protected function onCustomGesture_SwipeUp():void {
      // Abstract method - override if desired
   }

   protected function onCustomGesture_SwipeUpLeft():void {
      // Abstract method - override if desired
   }

   protected function onCustomGesture_SwipeUpRight():void {
      // Abstract method - override if desired
   }

   protected function onGestureSwipe(message:String = null):void {
      // Abstract method - override if desired
   }

   protected function onGestureSwipe_Down():void {
      // Abstract method - override if desired
   }

   protected function onGestureSwipe_Left():void {
      // Abstract method - override if desired
   }

   protected function onGestureSwipe_Right():void {
      // Abstract method - override if desired
   }

   protected function onGestureSwipe_Up():void {
      // Abstract method - override if desired
   }

   protected function onMouseDown(message:String = null):void {
      // Abstract method - override if desired
   }

   protected function onMouseMove(message:String = null):void {
      // Abstract method - override if desired
   }

   protected function onMouseUp(message:String = null):void {
      // Abstract method - override if desired
   }

   protected function onResize(message:String = null):void {
      // Abstract method - override if desired
   }

   protected function onViewMenuItemClick(event:MouseEvent):void {
      //// 20200602 dmccarroll - looks like I wrote this code long ago - and haven't used it in a long time, if ever
      /*switch (event.currentTarget.label) {
         case VIEW_MENU_ITEM_LABEL__CREDITS: {
            navigator.pushView(View_Credits, null, null, transition_CrossFade);
            break;
         }
         case VIEW_MENU_ITEM_LABEL__HELP: {
            var ctxt:ViewContext = new ViewContext(ViewContext.CONTEXT_TYPE__FATAL_ERROR);
            navigator.pushView(View_Help, null, null, transition_CrossFade);
            break;
         }
         case VIEW_MENU_ITEM_LABEL__SEND_FEEDBACK: {
            navigator.pushView(View_SendFeedback, null, null, transition_CrossFade);
            break;
         }
         default: {
            Log.warn("View_Base.onMenuViewItemClick(): No case for '" + event.currentTarget.label + "'");
         }
      }*/
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function activateMouseMoveTracking(mouseStageX:int, mouseStageY:int):void {
      if (isCustomGesturesEnabled)
         _gestureTranslator = new GestureTranslator(mouseStageX, mouseStageY, stage.height, stage.width)
   }

   private function deactivateMouseMoveTracking():void {
      if (_gestureTranslator) {
         _gestureTranslator.dispose();
         _gestureTranslator = null;
      }
   }

   private function handleCustomGesture(gesture:String):void {
      switch (gesture) {
         case GestureTranslator.GESTURE__ARROW_DOWN: {
            onCustomGesture_Arrow_Down();
            break;
         }
         case GestureTranslator.GESTURE__ARROW_LEFT: {
            onCustomGesture_Arrow_Left();
            break;
         }
         case GestureTranslator.GESTURE__ARROW_RIGHT: {
            onCustomGesture_Arrow_Right();
            break;
         }
         case GestureTranslator.GESTURE__ARROW_UP: {
            onCustomGesture_Arrow_Up();
            break;
         }
         case GestureTranslator.GESTURE__CIRCLE: {
            onCustomGesture_Circle();
            break;
         }
         case GestureTranslator.GESTURE__NONE:
            break;
         case GestureTranslator.GESTURE__SWIPE_DOWN: {
            onCustomGesture_SwipeDown();
            break;
         }
         case GestureTranslator.GESTURE__SWIPE_DOWN_LEFT: {
            onCustomGesture_SwipeDownLeft();
            break;
         }
         case GestureTranslator.GESTURE__SWIPE_DOWN_RIGHT: {
            onCustomGesture_SwipeDownRight();
            break;
         }
         case GestureTranslator.GESTURE__SWIPE_LEFT: {
            onCustomGesture_SwipeLeft();
            break;
         }
         case GestureTranslator.GESTURE__SWIPE_RIGHT: {
            onCustomGesture_SwipeRight();
            break;
         }
         case GestureTranslator.GESTURE__SWIPE_UP: {
            onCustomGesture_SwipeUp();
            break;
         }
         case GestureTranslator.GESTURE__SWIPE_UP_LEFT: {
            onCustomGesture_SwipeUpLeft();
            break;
         }
         case GestureTranslator.GESTURE__SWIPE_UP_RIGHT: {
            onCustomGesture_SwipeUpRight();
            break;
         }
         default: {
            Log.warn("View_Base.handleCustomGesture(): No match for 'gesture' arg of '" + gesture + "'.");
         }
      }
   }

   private function onBaseGestureSwipe(event:TransformGestureEvent):void {
      var direction:String;
      if (event.offsetX == 1) {
         direction = "Right";
         onGestureSwipe_Right();
      }
      if (event.offsetX == -1) {
         direction = "Left";
         onGestureSwipe_Left();
      }
      if (event.offsetY == 1) {
         direction = "Down";
         onGestureSwipe_Down();
      }
      if (event.offsetY == -1) {
         direction = "Up";
         onGestureSwipe_Up();
      }
      //var message:String = "on GestureSwipe() " + direction + " offsetX:" + event.offsetX + " offsetY:" + event.offsetY;
      //trace(message);
      onGestureSwipe(); //message);
   }

   private function onBaseMouseDown(event:MouseEvent):void {
      //var message:String = "onMouseDown() x:" + event.stageX + " y:" + event.stageY;
      //trace(message);
      activateMouseMoveTracking(event.stageX, event.stageY);
      onMouseDown(); //message);
   }

   private function onBaseMouseMove(event:MouseEvent):void {
      if (_gestureTranslator) {
         if (_gestureTranslator.isTimedOut()) {
            deactivateMouseMoveTracking();
         }
         else {
            _gestureTranslator.mouseMove(event.stageX, event.stageY);
            onMouseMove(); //message);
         }
      }
   }

   private function onBaseMouseUp(event:MouseEvent):void {
      if ((_gestureTranslator) && (!_gestureTranslator.isTimedOut())) {
         var gesture:String = _gestureTranslator.mouseUp(event.stageX, event.stageY);
         handleCustomGesture(gesture);
         //var message:String = "onMouseUp() x:" + event.stageX + " y:" + event.stageY;
         //trace(message)
         onMouseUp(); //message);
      }
      deactivateMouseMoveTracking();
   }

   private function onBaseResize(event:ResizeEvent):void {
      // If the user rotates the device in mid-gesture, well, this is just too confusing
      // to deal with.
      deactivateMouseMoveTracking();
      onResize();
   }

   private function onRemoving(event:ViewNavigatorEvent):void {
      dispose();
   }

}
}
