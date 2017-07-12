/*
 Copyright 2008, 2009, 2010, 2011, 2012 Brightworks, Inc.

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
import com.brightworks.base.Callbacks;
import com.brightworks.component.mobilealert.MobileDialog;
import com.brightworks.resource.Resources_Audio;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_AIR;
import com.brightworks.util.Utils_String;
import com.brightworks.util.Utils_System;
import com.langcollab.languagementor.component.button.Button_ActionBar_Home;
import com.langcollab.languagementor.component.button.Button_ActionBar_LeftArrow;
import com.langcollab.languagementor.constant.Constant_AppConfiguration;
import com.langcollab.languagementor.controller.Command_InitApplication;
import com.langcollab.languagementor.controller.audio.AudioController;
import com.langcollab.languagementor.model.MainModel;
import com.langcollab.languagementor.model.appstatepersistence.AppStatePersistenceManager;
import com.langcollab.languagementor.model.currentlessons.CurrentLessons;
import com.langcollab.languagementor.util.Utils_LangCollab;
import com.langcollab.languagementor.util.singleton.LangMentorSingletonManager;
import com.langcollab.languagementor.view.supportClasses.ViewContext;

import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.events.UncaughtErrorEvent;
import flash.ui.Keyboard;
import flash.utils.Timer;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;

import spark.components.Button;
import spark.components.View;
import spark.components.ViewNavigatorApplication;

public class App_LanguageMentor_Base extends ViewNavigatorApplication {
   private var _appStatePersistenceManager:AppStatePersistenceManager;
   private var _audioController:AudioController;
   private var _currentLessons:CurrentLessons;
   private var _model:MainModel;
   private var _singletonManager:LangMentorSingletonManager;
   private var _timer_UpdateTitle:Timer;


   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function App_LanguageMentor_Base() {
      super();
      Utils_System.releaseType = Constant_AppConfiguration.RELEASE_TYPE;
      Log.init(Utils_AIR.appName, onFatalLog, null, Utils_LangCollab.appendLogInfoToLogSummaryString, true);
      frameRate = 6;
      addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
      addEventListener(FlexEvent.INITIALIZE, onInitialize);
      addEventListener(FlexEvent.PREINITIALIZE, onPreinitialize);
      _singletonManager = new LangMentorSingletonManager();
      _appStatePersistenceManager = AppStatePersistenceManager.getInstance();
      _audioController = AudioController.getInstance();
      _currentLessons = CurrentLessons.getInstance();
      _model = MainModel.getInstance();

   }

   public function displayMobileDialog(alertText:String, callback:Function = null):void {
      MobileDialog.open(alertText, callback);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   override protected function backKeyUpHandler(event:KeyboardEvent):void {
   }

   override protected function partAdded(partName:String, instance:Object):void {
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function doBackButton():void {
      if (navigator.activeView is View_Home) {
         // exit() doesn't work in iOS
         if (!Utils_System.isRunningOnDesktop())
            _currentLessons.stopPlayingCurrentLessonVersionIfPlaying();
         //// not needed in iOS - useful in Android?   SoundMixer.audioPlaybackMode = AudioPlaybackMode.VOICE;
         NativeApplication.nativeApplication.exit();
      } else {
         View_Base(navigator.activeView).doGoBack();
      }
   }

   private function onActionBarBackButtonClick(event:MouseEvent):void {
      Resources_Audio.CLICK.play();
      doBackButton();
   }

   private function onActionBarHomeButtonClick(event:MouseEvent):void {
      Resources_Audio.CLICK.play();
      View_Base(navigator.activeView).doGoHome();
   }

   private function onActivateApp(event:Event):void {
      // This happens when the app 'returns' from running in the background.
      if (Utils_System.isRunningOnDesktop()) {
         // See comment in onDeactivateApp()
         return;
      } else {
         Log.info("App_LanguageMentor_Base.onActivateApp() *************************");
      }
      //// not needed in iOS - useful in Android?   SoundMixer.audioPlaybackMode = AudioPlaybackMode.MEDIA;
   }

   private function onCreationComplete(event:FlexEvent):void {
      navigationContent = [];
      var leftArrowButton:Button_ActionBar_LeftArrow;
      leftArrowButton = new Button_ActionBar_LeftArrow();
      leftArrowButton.percentHeight = 100;
      leftArrowButton.addEventListener(MouseEvent.CLICK, onActionBarBackButtonClick);
      navigationContent.push(leftArrowButton);
      var homeButton:Button = new Button_ActionBar_Home();
      homeButton.percentHeight = 100;
      homeButton.addEventListener(MouseEvent.CLICK, onActionBarHomeButtonClick);
      navigationContent.push(homeButton);
   }

   private function onDeactivateApp(event:Event):void {
      // This happens when the device sends the app into the background - i.e. when 
      // the phone rings, when a clock alarm goes off, etc...
      if (Utils_System.isRunningOnDesktop()) {
         // When running on desktop, a deactivate event indicates that the app's window has lost
         // focus, but the app continues to execute. So we haven't really deactivated.
         return;
      } else {
         Log.info("App_LanguageMentor_Base.onDeactivateApp() *************************");
         _currentLessons.stopPlayingCurrentLessonVersionIfPlaying();
      }
      //// not needed in iOS - useful in Android?   SoundMixer.audioPlaybackMode = AudioPlaybackMode.VOICE;
   }

   private function onExiting(event:Event):void {
      // On desktop, this occurs when I close the program
   }

   private function onFatalLog():void {
      var ctxt:ViewContext = new ViewContext(ViewContext.CONTEXT_TYPE__FATAL_ERROR);
      if ((navigator) && (navigator.activeView)) {
         navigator.pushView(View_SendProblemReport, null, ctxt, View_Base(navigator.activeView).transition_CrossFade);
      } else {
         NativeApplication.nativeApplication.exit();
      }
   }

   private function onInitApplicationComplete(o:Object):void {
      Log.debug("App_LanguageMentor_Base.onInitApplicationComplete()");
   }

   private function onInitApplicationFailure(o:Object):void {
      // Currently not called - command calls Log.fatal() directly.
      Log.info("App_LanguageMentor_Base.onInitApplicationFailure()");
   }

   private function onInitialize(event:FlexEvent):void {
      if (!Utils_System.isScreenResolutionHighEnough(Constant_AppConfiguration.REQUIRED_SCREEN_RESOLUTION__X, Constant_AppConfiguration.REQUIRED_SCREEN_RESOLUTION__Y, true)) {
         navigator.pushView(View_ScreenResolutionTooLow);
         return;
      }
      NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivateApp);
      NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivateApp);
      NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
      NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
      systemManager.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
      /*if ((appStatePersistenceManager.retrieveIsMostRecentAppVersionWhereUserAgreedToLegalNoticeSaved()) &&
       (appStatePersistenceManager.retrieveMostRecentAppVersionWhereUserAgreedToLegalNotice() >= Constant_AppConfiguration.APP_VERSION__MINIMUM__USER_AGREED_TO_LEGAL_NOTICE) &&
       (appStatePersistenceManager.retrieveIsTargetLanguageIdSaved()))*/
      if ((_appStatePersistenceManager.retrieveAppInstallDate()) &&
            (_appStatePersistenceManager.retrieveIsTargetLanguageIdSaved())) {
         _model.initTargetLanguage(_appStatePersistenceManager.retrieveTargetLanguageId());
         navigator.firstView = View_Home;
      } else {
         navigator.firstView = View_Intro_Welcome;
      }
      if (Utils_System.isAlphaVersion()) {
         _timer_UpdateTitle = new Timer(1000, 0);
         _timer_UpdateTitle.addEventListener(TimerEvent.TIMER, onUpdateTitleTimer);
         //_timer_UpdateTitle.start();
      }
      var cb:Callbacks = new Callbacks(onInitApplicationComplete, onInitApplicationFailure);
      var c:Command_InitApplication = new Command_InitApplication(cb);
      c.execute();
   }

   private function onKeyDown(event:KeyboardEvent):void {
      switch (event.keyCode) {
         case Keyboard.BACK: {
            // We need to catch this because in one case - in the 'select lessons' screen -
            // for some reason, once Android gets its hands on this event it concludes that
            // it should close (or, is it 'deactivate'?) the app. It seems to think that
            // we're at the home screen when we're not.
            event.preventDefault();
            if (MobileDialog.isDisplayed) {
               MobileDialog.close();
            } else {
               doBackButton();
            }
            break;
         }
         case Keyboard.HOME: {
            if (!Utils_System.isRunningOnDesktop())
               _currentLessons.stopPlayingCurrentLessonVersionIfPlaying();
            //// not needed in iOS - useful in Android?   SoundMixer.audioPlaybackMode = AudioPlaybackMode.VOICE;
            //NativeApplication.nativeApplication.exit();
            break;
         }
         case Keyboard.SEARCH: {
            if ((_model) && (_currentLessons.currentLessonVO))
               navigator.pushView(View_Credits_Lesson, _currentLessons.currentLessonVO);
            break;
         }
      }
   }

   private function onPreinitialize(event:FlexEvent):void {
      if (!Utils_System.isScreenResolutionHighEnough(Constant_AppConfiguration.REQUIRED_SCREEN_RESOLUTION__X, Constant_AppConfiguration.REQUIRED_SCREEN_RESOLUTION__Y, true))
         return;
   }

   private function onUncaughtError(event:UncaughtErrorEvent):void {
      event.preventDefault();
      Log.warn(["App_LanguageMentor_Base.onUncaughtError()", event]);
   }

   private function onUpdateTitleTimer(event:TimerEvent):void {
      if (!_model)
         return;
      var view:View = ViewNavigatorApplication(FlexGlobals.topLevelApplication).navigator.activeView;
      if (!view)
         return;
      view.title = Utils_String.padBeginning(String(_model.recentDBAccessCount), 5) + " " + _model.mostRecentDownloadLessonProcessStatus;
   }

}
}
