package com.langcollab.languagementor.view.supportClasses
{

    public class ViewContext
    {
        public static const CONTEXT_TYPE__FATAL_ERROR:String = "contextType_FatalError";
        public static const CONTEXT_TYPE__HELP:String = "contextType_Help";
        public static const CONTEXT_TYPE__MAIN_SCREEN_LINK_BUTTON:String = "contextType_MainScreenLinkButton";
        public static const CONTEXT_TYPE__MORE:String = "contextType_More";
        public static const CONTEXT_TYPE__SCREEN_INTRO:String = "contextType_ScreenIntro";
        public static const CONTEXT_TYPE__SELECT_MODE_SCREEN_HELP:String = "contextType_SelectModeScreenHelp";

        public var nextViewClass:Class;

        private var _contextType:String;

        public function get contextType():String
        {
            return _contextType;
        }

        public function ViewContext(contextType:String)
        {
            _contextType = contextType;
        }
    }
}
