package com.langcollab.languagementor.model
{
    import com.brightworks.techreport.ITechReport;
    import com.brightworks.techreport.TechReport;
    import com.brightworks.util.Utils_Dispose;

    public class ConfigFileInfoTechReport extends TechReport implements ITechReport
    {
        public var isMentorTypeFileDownloadFailure:Boolean = false;
        public var isMentorTypeFileParsingFailure:Boolean = false;
        public var isProcessTimedOut:Boolean = false;
        public var isRootConfigFileDownloadFailure:Boolean = false;
        public var isRootConfigFileParsingFailure:Boolean = false;
        public var problemDescriptionList:Array = [];

        private var _isDisposed:Boolean;

        public function ConfigFileInfoTechReport()
        {
            super();
        }

        override public function dispose():void
        {
            super.dispose();
            if (_isDisposed)
                return;
            _isDisposed = true;
            if (problemDescriptionList)
            {
                Utils_Dispose.disposeArray(problemDescriptionList, true);
                problemDescriptionList = null;
            }
        }


    }
}
