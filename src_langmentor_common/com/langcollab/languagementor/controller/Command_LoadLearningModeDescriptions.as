/*
    Copyright 2020 Brightworks, Inc.

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
package com.langcollab.languagementor.controller {
import com.brightworks.base.Callbacks;
import com.brightworks.service.BwAsyncResponder;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Dispose;
import com.langcollab.languagementor.service.Delegate_DownloadFileText;

import flash.utils.Dictionary;

import mx.rpc.AsyncToken;
import mx.rpc.events.ResultEvent;

public class Command_LoadLearningModeDescriptions extends Command_Base__LangMentor {
   private var _activeHttpRequests:Array = new Array(); // contains learningModeIds
   private var _delegate:Delegate_DownloadFileText = Delegate_DownloadFileText.getInstance();
   private var _isDisposed:Boolean = false;
   private var _result:Dictionary = new Dictionary(); // props are learningModeIds, values are HTML strings

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function Command_LoadLearningModeDescriptions(callbacks:Callbacks) {
      super();
      Log.debug("Command_LoadLearningModeDescriptions - Constructor");
      this.callbacks = callbacks;
   }

   override public function dispose():void {
      Log.debug("Command_LoadLearningModeDescriptions.dispose()");
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      _delegate = null;
      model = null;
      if (_activeHttpRequests) {
         Utils_Dispose.disposeArray(_activeHttpRequests, true);
         _activeHttpRequests = null;
      }
      if (_result) {
         // Don't 'dispose' _result - it's stored in MainModel and clearing its contents will wipe data
         _result = null;
      }
   }

   public function execute():void {
      Log.debug("Command_LoadLearningModeDescriptions.execute()");
      var learningModeIds:Array = model.getLearningModeIDListSortedByLocationInOrder();
      for each (var learningModeId:int in learningModeIds) {
         var modeToken:String = model.getLearningModeTokenFromID(learningModeId);
         var url:String = "html/" + model.getNativeLanguageIso639_3Code() + "/" + modeToken + ".html";
         var token:AsyncToken = _delegate.download(url);
         var responder:BwAsyncResponder = new BwAsyncResponder(onLoadComplete, onLoadFailure, [learningModeId]);
         token.addResponder(responder);
         _activeHttpRequests.push(learningModeId);
      }
   }

   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************

   private function onLoadComplete(data:Object, learningModeId:int):void {
      if (_isDisposed)
         return;
      /// implement user-friendly debug call
      if (_activeHttpRequests.indexOf(learningModeId) == -1)
         Log.fatal(["Command_LoadLearningModeDescriptions.result(): Result returned for learningModeId without an active HTTP request:", data]);
      _activeHttpRequests.splice(_activeHttpRequests.indexOf(learningModeId), 1);
      _result[learningModeId] = ResultEvent(data).result;
      if (_activeHttpRequests.length == 0) {
         model.learningModeDescriptionsHTML = _result;
         super.result(null);
         dispose();
      }
   }

   private function onLoadFailure(o:Object, oo:Object = null):void {
      if (oo) {
         // For debugging. When does this happen?
         var foo:int = 1;
      }
      if (_isDisposed)
         return;
      fault();
      dispose();
   }
}
}
















