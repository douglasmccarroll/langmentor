package com.langcollab.languagementor.view {
import com.brightworks.base.Callbacks;
import com.brightworks.util.Log;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.controller.Command_AddLibrary;
import com.langcollab.languagementor.controller.Command_AddLibraryErrorReport;

import spark.components.BusyIndicator;

public class Subviewlet_AddLibrary__URLEntry_Base extends Subviewlet_AddLibrary__Base {
   public static const SUCCESS_REPORT__LIBRARY_ADDED:String = "Success! Library has been added.";

   protected static const PROBLEM_REPORT__CANNOT_FIND_LIBRARY:String = "Problem: The Library URL that you've entered doesn't seem to point to a library.";
   protected static const PROBLEM_REPORT__APPARENT_LACK_OF_INTERNET_ACCESS:String = "Problem: It appears that we can't access the Internet. Please ensure that you have Internet access and try again.";
   protected static const PROBLEM_REPORT__CAUSE_UNKNOWN:String = "Problem: Unknown cause. " + Constant_LangMentor_Misc.MESSAGE__REPORT_PROBLEM;

   public var libraryAddedCallback:Function;

   private var _busyIndicator:BusyIndicator;
   private var _isDisposed:Boolean = false;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function Subviewlet_AddLibrary__URLEntry_Base() {
      super();
   }

   override public function dispose():void {
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   protected function displayAddURLResult(resultText:String):void {
      Log.error("Subviewlet_AddLibrary__URLEntry_Base.displayAddURLResult(): Abstract method - subclasses must override.");
   }

   protected function onAddURLComplete(o:Object = null):void {
      stopBusyIndicator();
      displayAddURLResult(SUCCESS_REPORT__LIBRARY_ADDED);
      libraryAddedCallback();
   }

   protected function onAddURLFailure(errorReport:Command_AddLibraryErrorReport):void {
      stopBusyIndicator();
      switch (errorReport.errorType) {
         case Command_AddLibraryErrorReport.ERROR_TYPE__CANNOT_FIND_LIBRARY:
         case Command_AddLibraryErrorReport.ERROR_TYPE__TIMEOUT: {
            displayAddURLResult(PROBLEM_REPORT__CANNOT_FIND_LIBRARY);
            break;
         }
         case Command_AddLibraryErrorReport.ERROR_TYPE__LIBRARY_ALREADY_IN_DB: {
            displayAddURLResult(SUCCESS_REPORT__LIBRARY_ADDED);
            break;
         }
         case Command_AddLibraryErrorReport.ERROR_TYPE__SAVE_TO_DB_FAILED: {
            displayAddURLResult(PROBLEM_REPORT__CAUSE_UNKNOWN);
            Log.error(["Subviewlet_AddLibrary__URLEntry_Base.onAddURLFailure(): Error type: " + errorReport.errorType, errorReport]);
            break;
         }
         case Command_AddLibraryErrorReport.ERROR_TYPE__UNABLE_TO_ACCESS_INTERNET: {
            displayAddURLResult(PROBLEM_REPORT__APPARENT_LACK_OF_INTERNET_ACCESS);
            break;
         }
         default: {
            Log.error("Subviewlet_AddLibrary__URLEntry_Base.onAddURLFailure(): No case for '" + errorReport.errorType + "'");

         }
      }
   }

   protected function startAddLibraryProcess(libraryUrl:String):void {
      var cb:Callbacks = new Callbacks(onAddURLComplete, onAddURLFailure);
      var c:Command_AddLibrary = new Command_AddLibrary(libraryUrl, cb);
      c.execute();
   }

   protected function startBusyIndicator():void {
      if (_busyIndicator)
         return;
      _busyIndicator = new BusyIndicator();
      _busyIndicator.x = (width - _busyIndicator.width) / 2;
      _busyIndicator.y = (height - _busyIndicator.width) / 2;
      addElement(_busyIndicator);
   }

   protected function stopBusyIndicator():void {
      if (_busyIndicator) {
         _busyIndicator.visible = false;
         removeElement(_busyIndicator);
         _busyIndicator = null;
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


}
}
