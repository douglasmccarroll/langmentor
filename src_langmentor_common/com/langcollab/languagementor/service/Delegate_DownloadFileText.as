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
package com.langcollab.languagementor.service {
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.util.singleton.SingletonManager;

import mx.rpc.AsyncToken;
import mx.rpc.http.HTTPService;

public class Delegate_DownloadFileText implements IManagedSingleton {

   private static var _instance:Delegate_DownloadFileText;

   public var httpService:HTTPService;

   public function Delegate_DownloadFileText(manager:SingletonManager) {
      _instance = this;
      httpService = new HTTPService();
   }

   public function download(url:String):AsyncToken {
      httpService.url = url;
      httpService.method = "GET";
      httpService.resultFormat = "text";
      var token:AsyncToken = httpService.send();
      return token;
   }

   public static function getInstance():Delegate_DownloadFileText {
      if (!(_instance))
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function initSingleton():void {
   }


}
}

