/*
Copyright 2018 Brightworks, Inc.

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
import com.brightworks.controller.Command_Base;
import com.langcollab.languagementor.controller.audio.AudioController;
import com.langcollab.languagementor.controller.lessondownload.LessonDownloadController;
import com.langcollab.languagementor.model.MainModel;
import com.langcollab.languagementor.model.appstatepersistence.AppStatePersistenceManager;
import com.langcollab.languagementor.model.currentlessons.CurrentLessons;

public class Command_Base__LangMentor extends Command_Base {
   protected var audioController:AudioController = AudioController.getInstance();
   protected var currentLessons:CurrentLessons = CurrentLessons.getInstance();
   protected var lessonDownloadController:LessonDownloadController = LessonDownloadController.getInstance();
   protected var model:MainModel = MainModel.getInstance();

   // --------------------------------------------
   //
   //           Getters / Setters
   //
   // --------------------------------------------

   private var _appStatePersistenceManager:AppStatePersistenceManager;

   protected function get appStatePersistenceManager():AppStatePersistenceManager {
      if (!_appStatePersistenceManager)
         _appStatePersistenceManager = AppStatePersistenceManager.getInstance();
      return _appStatePersistenceManager;
   }

   // --------------------------------------------
   //
   //           Public Methods
   //
   // --------------------------------------------

   public function Command_Base__LangMentor() {
      super();
   }


   override public function dispose():void {
      _appStatePersistenceManager = null;
      audioController = null;
      lessonDownloadController = null;
      super.dispose();
   }

}
}
