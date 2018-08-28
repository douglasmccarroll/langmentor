package com.langcollab.languagementor.util.singleton {
import com.brightworks.util.Log;
import com.brightworks.util.PerformanceAnalyzer;
import com.brightworks.util.Utils_DateTime;
import com.brightworks.util.singleton.SingletonManager;
import com.langcollab.languagementor.controller.audio.AudioController;
import com.langcollab.languagementor.controller.audio.AudioPlayer;
import com.langcollab.languagementor.controller.audio.AudioRecorder;
import com.langcollab.languagementor.controller.lessondownload.LessonDownloadController;
import com.langcollab.languagementor.model.MainModel;
import com.langcollab.languagementor.model.appstatepersistence.AppStatePersistenceManager;
import com.langcollab.languagementor.model.currentlessons.CurrentLessons;
import com.langcollab.languagementor.service.Delegate_DownloadFileText;

public class LangMentorSingletonManager extends SingletonManager {
   public function LangMentorSingletonManager() {
      super();
   }

   override protected function populateClassList():void {
      singletonClassList = [
         AppStatePersistenceManager,
         AudioController,
         AudioPlayer,
         AudioRecorder,
         CurrentLessons,
         Delegate_DownloadFileText,
         LessonDownloadController,
         Log,
         MainModel,
         Utils_DateTime,
         PerformanceAnalyzer]
   }
}
}
