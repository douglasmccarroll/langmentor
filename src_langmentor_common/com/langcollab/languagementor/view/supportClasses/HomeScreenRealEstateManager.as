package com.langcollab.languagementor.view.supportClasses {
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Dispose;
import com.langcollab.languagementor.component.button.Button_Standard_Blue;
import com.langcollab.languagementor.component.button.HomeScreenBackgroundButton;
import com.langcollab.languagementor.controller.lessondownload.LessonDownloadController;
import com.langcollab.languagementor.model.MainModel;
import com.langcollab.languagementor.model.appstatepersistence.AppStatePersistenceManager;

import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

import spark.components.Group;

public class HomeScreenRealEstateManager {

   public static const SCREEN_AREA_LABEL__BOTTOM:String = "screenAreaLabel_Bottom";
   public static const SCREEN_AREA_LABEL__BOTTOM_LEFT:String = "screenAreaLabel_BottomLeft";
   public static const SCREEN_AREA_LABEL__BOTTOM_RIGHT:String = "screenAreaLabel_BottomRight";
   public static const SCREEN_AREA_LABEL__TOP_LEFT:String = "screenAreaLabel_TopLeft";
   public static const SCREEN_AREA_LABEL__LEFT:String = "screenAreaLabel_Left";
   public static const SCREEN_AREA_LABEL__RIGHT:String = "screenAreaLabel_Right";
   public static const SCREEN_AREA_LABEL__TOP:String = "screenAreaLabel_Top";
   public static const SCREEN_AREA_LABEL__TOP_RIGHT:String = "screenAreaLabel_TopRight";

   private var _appStatePersistenceManager:AppStatePersistenceManager = AppStatePersistenceManager.getInstance();
   private var _index_ClickFunctions_to_Targets:Dictionary;
   private var _isDisposed:Boolean;
   private var _lessonDownloadController:LessonDownloadController = LessonDownloadController.getInstance();
   private var _model:MainModel = MainModel.getInstance();

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function HomeScreenRealEstateManager() {
      _index_ClickFunctions_to_Targets = new Dictionary();
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (_index_ClickFunctions_to_Targets) {
         for (var o:Object in _index_ClickFunctions_to_Targets) {
            var func:Function = (o as Function);
            var targ:IEventDispatcher = _index_ClickFunctions_to_Targets[func];
            targ.removeEventListener(MouseEvent.CLICK, func);
         }
         Utils_Dispose.disposeDictionary(_index_ClickFunctions_to_Targets, true);
      }
   }

   public function populateScreenAreaGroup(group:Group, screenAreaLabel:String, clickFunction:Function):void {
      switch (screenAreaLabel) {
         case SCREEN_AREA_LABEL__BOTTOM:
            populateScreenAreaGroup_Bottom(group, clickFunction);
            break;
         case SCREEN_AREA_LABEL__BOTTOM_LEFT:
            populateScreenAreaGroup_BottomLeft(group, clickFunction);
            break;
         case SCREEN_AREA_LABEL__BOTTOM_RIGHT:
            populateScreenAreaGroup_BottomRight(group, clickFunction);
            break;
         case SCREEN_AREA_LABEL__LEFT:
            populateScreenAreaGroup_Left(group, clickFunction);
            break;
         case SCREEN_AREA_LABEL__RIGHT:
            populateScreenAreaGroup_Right(group, clickFunction);
            break;
         case SCREEN_AREA_LABEL__TOP:
            populateScreenAreaGroup_Top(group, clickFunction);
            break;
         case SCREEN_AREA_LABEL__TOP_LEFT:
            populateScreenAreaGroup_TopLeft(group, clickFunction);
            break;
         case SCREEN_AREA_LABEL__TOP_RIGHT:
            populateScreenAreaGroup_TopRight(group, clickFunction);
            break;
         default:
            Log.error("HomeScreenRealEstateManager.populateScreenAreaGroup(): No case for screenAreaLabel: " + screenAreaLabel);
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function populateScreenAreaGroup_Bottom(group:Group, clickFunction:Function):void {
      var bttn:Button_Standard_Blue = new Button_Standard_Blue();
      bttn.label = "More";
      bttn.addEventListener(MouseEvent.CLICK, clickFunction);
      _index_ClickFunctions_to_Targets[clickFunction] = bttn;
      group.addElement(bttn);
   }

   private function populateScreenAreaGroup_BottomLeft(group:Group, clickFunction:Function):void {
      if ((_appStatePersistenceManager.retrieveIsNaggingDisabledSaved()) && (_appStatePersistenceManager.retrieveNaggingDisabled()))
         return;
      if (!_appStatePersistenceManager.retrieveIsHomeScreenDisplayCountSaved())
         return;
      if (_appStatePersistenceManager.retrieveHomeScreenDisplayCount() < 40)
         return;
      //if ((_model.appStatePersistenceManager.retrieveHomeScreenDisplayCount() % 10) != 0)
      //    return;
      var bttn:HomeScreenBackgroundButton = new HomeScreenBackgroundButton();
      bttn.text = "Share";
      bttn.addEventListener(MouseEvent.CLICK, clickFunction);
      _index_ClickFunctions_to_Targets[clickFunction] = bttn;
      group.addElement(bttn);
   }

   private function populateScreenAreaGroup_BottomRight(group:Group, clickFunction:Function):void {
      var bttn:HomeScreenBackgroundButton = new HomeScreenBackgroundButton();
      bttn.text = "Credits";
      bttn.addEventListener(MouseEvent.CLICK, clickFunction);
      _index_ClickFunctions_to_Targets[clickFunction] = bttn;
      group.addElement(bttn);
   }

   private function populateScreenAreaGroup_Left(group:Group, clickFunction:Function):void {
      var bttn:Button_Standard_Blue = new Button_Standard_Blue();
      bttn.label = "Select\nMode";
      bttn.addEventListener(MouseEvent.CLICK, clickFunction);
      _index_ClickFunctions_to_Targets[clickFunction] = bttn;
      group.addElement(bttn);
   }

   private function populateScreenAreaGroup_Right(group:Group, clickFunction:Function):void {
      var bttn:Button_Standard_Blue = new Button_Standard_Blue();
      bttn.label = "Select\nLessons";
      bttn.addEventListener(MouseEvent.CLICK, clickFunction);
      _index_ClickFunctions_to_Targets[clickFunction] = bttn;
      group.addElement(bttn);
   }

   private function populateScreenAreaGroup_Top(group:Group, clickFunction:Function):void {
      var bttn:Button_Standard_Blue = new Button_Standard_Blue();
      bttn.label = "Play\nLessons";
      bttn.addEventListener(MouseEvent.CLICK, clickFunction);
      _index_ClickFunctions_to_Targets[clickFunction] = bttn;
      group.addElement(bttn);
   }

   private function populateScreenAreaGroup_TopLeft(group:Group, clickFunction:Function):void {
      if ((_lessonDownloadController.successfulDownloadInfoList_NewDownloads.length == 0) &&
            (_lessonDownloadController.successfulDownloadInfoList_Updates.length == 0))
         return;
      var bttn:HomeScreenBackgroundButton = new HomeScreenBackgroundButton();
      bttn.text = "Downloads";
      bttn.addEventListener(MouseEvent.CLICK, clickFunction);
      _index_ClickFunctions_to_Targets[clickFunction] = bttn;
      group.addElement(bttn);
   }

   private function populateScreenAreaGroup_TopRight(group:Group, clickFunction:Function):void {
      if (!_model.configFileInfo.isMostRecentNewsUpdateAvailableForDisplay())
         return;
      var linkText:String = _model.configFileInfo.getMostRecentNewsUpdateLinkText();
      var bttn:HomeScreenBackgroundButton = new HomeScreenBackgroundButton();
      bttn.text = linkText;
      bttn.addEventListener(MouseEvent.CLICK, clickFunction);
      _index_ClickFunctions_to_Targets[clickFunction] = bttn;
      group.addElement(bttn);
   }


}
}
