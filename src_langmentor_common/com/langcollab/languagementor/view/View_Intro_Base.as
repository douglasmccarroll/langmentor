package com.langcollab.languagementor.view {
import com.brightworks.util.Log;
import com.brightworks.util.Utils_AIR;
import com.brightworks.util.Utils_ANEs;
import com.brightworks.util.Utils_System;
import com.langcollab.languagementor.constant.Constant_MentorTypeSpecific;
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
            if (!Constant_MentorTypeSpecific.MENTOR_TYPE__IS_WHITE_LABEL__IE_NOT_LANGMENTOR) {
               navigator.pushView(View_Intro_OpenPlatform);
            }
            else {
               navigator.pushView(View_Intro_LessonLevels);
            }
         }
      }
      // No longer used:
            // View_Intro_SingleDualLanguages
            // View_Intro_PrivacyPolicy
            // View_Intro_Safety
            // View_Intro_Agreement
      else if (this is View_Intro_OpenPlatform) {
         if (!model.isRecommendedLibraryInfoFromRootConfigFileAvailable()) {
            Log.debug("View_Intro_Base.onNextButtonClick() - user is trying to leave 'open platform' intro screen, but root config file not downloaded yet - so we just show 'no internet access' alert");
            Utils_ANEs.showAlert_OkayButton(Constant_MentorTypeSpecific.APP_NAME__SHORT + " is having trouble accessing the Internet. If you continue to see this message, please check your device's Internet access.");
         }
         else if (Constant_MentorTypeSpecific.MENTOR_TYPE__CODE == Constant_MentorTypes.MENTOR_TYPE_CODE__UNIVERSAL) {
            navigator.pushView(View_Intro_SelectLanguage);
         }
         else {
            navigator.pushView(View_Intro_RecommendedLibraries);
         }
      }
      else if (this is View_Intro_SelectLanguage) {
         if (model.doesCurrentTargetLanguageHaveRecommendedLibraries()) {
            navigator.pushView(View_Intro_RecommendedLibraries);
         }
         else {
            model.useRecommendedLibraries = false;
            navigator.pushView(View_Intro_AddLibraries_Decide);
         }
      }
      else if (this is View_Intro_RecommendedLibraries) {
         if (model.useRecommendedLibraries) {
            navigator.pushView(View_Intro_LessonLevels);
         }
         else {
            navigator.pushView(View_Intro_AddLibraries_Decide);
         }
      }
      else if (this is View_Intro_AddLibraries_Decide)
         Log.error("View_Intro_Base.onNextButtonClick(): View_Intro_AddLibraries_Decide should handle this, and not call super.onNextButtonClick()");
      else if (this is View_Intro_AddLibraries_Warning) {
         navigator.pushView(View_Intro_AddLibraries_Agreement);
      }
      else if (this is View_Intro_AddLibraries_Agreement) {
         navigator.pushView(View_Intro_AddLibraries);
      }
      else if (this is View_Intro_AddLibraries) {
         View_Intro_Base.isUserCompletedAddLibraryProcess = true;
         navigator.pushView(View_Intro_AddLibraries_Decide);
      } else if (this is View_Intro_LessonLevels) {
         navigator.pushView(View_Intro_SetupComplete);
      }
      else if (this is View_Intro_SetupComplete) {
         saveSettings();
         doIntroDone();
      }
      else {
         doIntroDone();
         Log.error("View_Intro_Base.onContinueButtonClick(): no case for current view class");
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   protected function bypassIntroScreens():void {
      model.useRecommendedLibraries = true;
      model.initTargetLanguage(11, true);
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

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
