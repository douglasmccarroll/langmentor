package com.langcollab.languagementor.view {
import com.brightworks.util.Log;
import com.brightworks.util.Utils_AIR;
import com.brightworks.util.Utils_System;
import com.langcollab.languagementor.constant.Constant_AppConfiguration;
import com.langcollab.languagementor.constant.Constant_MentorTypes;

import flash.events.MouseEvent;

import mx.events.FlexEvent;

public class View_Intro_Base extends View_CancelAndOrNext_Base {
   public static var isUserCompletedAddLibraryProcess:Boolean;
   public static var isUserStartedAddLibraryProcess:Boolean;

   private var _isDisposed:Boolean;

   public function View_Intro_Base() {
      addEventListener(FlexEvent.INITIALIZE, onInitialize);
   }

   override public function dispose():void {
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      removeEventListener(FlexEvent.INITIALIZE, onInitialize);
   }

   override public function doGoBack():void {
      // Do nothing
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   override protected function onNextButtonClick(event:MouseEvent):void {
      Log.info("View_Intro_Base.onNextButtonClick(): View class: " + this.toString());
      if (this is View_Intro_Welcome) {
         if ((Utils_System.isRunningOnDesktop()) &&
               (event.shiftKey)) {
            // Intro bypass for dev mode
            bypassIntroScreens();
         } else {
            navigator.pushView(View_Intro_OpenPlatform);
         }
      } else if (this is View_Intro_OpenPlatform)
         navigator.pushView(View_Intro_SingleDualLanguages);
      else if (this is View_Intro_SingleDualLanguages)
         navigator.pushView(View_Intro_PrivacyPolicy);
      //else if (this is View_Intro_Overview) /// Bypassing - delete?
      //navigator.pushView(View_Intro_PrivacyPolicy);
      else if (this is View_Intro_PrivacyPolicy)
         navigator.pushView(View_Intro_Safety);
      //else if (this is View_Intro_Safety)
      //navigator.pushView(View_Intro_Agreement);
      else if (this is View_Intro_Safety) {
         if (Constant_AppConfiguration.CURRENT_MENTOR_TYPE__CODE == Constant_MentorTypes.MENTOR_TYPE_CODE__GLOBAL) {
            navigator.pushView(View_Intro_SelectLanguage);
         } else {
            navigator.pushView(View_Intro_RecommendedLibraries_Decide);
         }
      } else if (this is View_Intro_SelectLanguage)
         navigator.pushView(View_Intro_RecommendedLibraries_Decide);
      else if (this is View_Intro_RecommendedLibraries_Decide) {
         if (model.useRecommendedLibraries)
            navigator.pushView(View_Intro_RecommendedLibraries_Display);
         else
            navigator.pushView(View_Intro_AddLibraries_Decide);
      } else if (this is View_Intro_RecommendedLibraries_Display)
         navigator.pushView(View_Intro_AddLibraries_Decide);
      else if (this is View_Intro_AddLibraries_Decide)
         Log.error("View_Intro_Base.onNextButtonClick(): View_Intro_AddLibraries_Decide should handle this, and not call super.onNextButtonClick()");
      else if (this is View_Intro_AddLibraries_Warning)
         navigator.pushView(View_Intro_AddLibraries_Agreement);
      else if (this is View_Intro_AddLibraries_Agreement)
         navigator.pushView(View_Intro_AddLibraries);
      else if (this is View_Intro_AddLibraries) {
         View_Intro_Base.isUserCompletedAddLibraryProcess = true;
         navigator.pushView(View_Intro_AddLibraries_Decide);
      } else if (this is View_Intro_LessonLevels)
         navigator.pushView(View_Intro_AutoDownloads);
      else if (this is View_Intro_AutoDownloads) {
         saveSettings();
         navigator.pushView(View_Intro_LibraryPreferencesSaved);
      } else if (this is View_Intro_LibraryPreferencesSaved)
         navigator.pushView(View_Intro_SetupComplete);
      else if (this is View_Intro_SetupComplete)
         doIntroDone();
      else {
         doIntroDone();
         Log.error("View_Intro_Base.onContinueButtonClick(): no case for current view class");
      }
   }

   override protected function onNextButtonDoubleClick(event:MouseEvent):void {
      if ((Utils_System.isInDebugMode()) ||
            (Utils_System.isAlphaOrBetaVersion()))
         bypassIntroScreens();
      else
         onNextButtonClick(event);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function bypassIntroScreens():void {
      model.autoDownloadLessons = true;
      model.useRecommendedLibraries = true;
      model.initTargetLanguage(1, true);
      var selectedLessonDownloadLevels_PrimaryLevels:Array = [];
      for each (var i:int in[1, 2, 6, 10]) /// kludge
      {
         selectedLessonDownloadLevels_PrimaryLevels.push(model.getLevelVOFromID(i));
      }
      model.selectedLessonDownloadLevels_PrimaryLevels = selectedLessonDownloadLevels_PrimaryLevels;
      navigator.pushView(View_Home, null, null, transition_CrossFade);
      //appStatePersistenceManager.persistMostRecentAppVersionWhereUserAgreedToLegalNotice(Utils_AIR.appVersionNumber);
      appStatePersistenceManager.persistAppInstallDate(new Date());
   }

   private function doIntroDone():void {
      Utils_AIR.keepSystemAwake(false);
      navigator.pushView(View_Home);
   }

   private function onInitialize(event:FlexEvent):void {
      navigationContent = [];
      Utils_AIR.keepSystemAwake();
   }

   private function saveSettings():void {
      // appStatePersistenceManager.persistMostRecentAppVersionWhereUserAgreedToLegalNotice(Utils_AIR.appVersionNumber);
      appStatePersistenceManager.persistAppInstallDate(new Date());
      appStatePersistenceManager.persistAutoDownloadLessons(model.autoDownloadLessons); // We do this now, rather than earlier, because it triggers the start of the download process
   }

}
}
