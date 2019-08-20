package com.langcollab.languagementor.view.supportClasses {

public class ViewContext {
   public static const CONTEXT_TYPE__FATAL_ERROR:String = "contextType_FatalError";
   public static const CONTEXT_TYPE__HELP:String = "contextType_Help";
   public static const CONTEXT_TYPE__HOME_SCREEN_LINK_BUTTON:String = "contextType_HomeScreenLinkButton";
   public static const CONTEXT_TYPE__HOME_SCREEN_BUTTON:String = "contextType_HomeScreenButton";
   public static const CONTEXT_TYPE__MANAGE_DOWNLOADS:String = "contextType_ManageDownloads";
   public static const CONTEXT_TYPE__MANAGE_LESSONS:String = "contextType_ManageLessons";
   public static const CONTEXT_TYPE__MORE:String = "contextType_More";
   public static const CONTEXT_TYPE__SELECT_MODE_SCREEN_HELP:String = "contextType_SelectModeScreenHelp";

   public var nextViewClass:Class;

   private var _contextType:String;

   public function get contextType():String {
      return _contextType;
   }

   public function ViewContext(contextType:String) {
      _contextType = contextType;
   }
}
}
