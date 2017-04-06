/*
    Copyright 2008 - 2013 Brightworks, Inc.

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
package com.langcollab.languagementor.controller
{
    import com.brightworks.base.Callbacks;
    import com.brightworks.util.Log;
import com.brightworks.util.Utils_NativeExtensions;
import com.brightworks.util.Utils_System;
import com.langcollab.languagementor.model.MainModelDBOperationReport;
    import com.langcollab.languagementor.vo.ChunkVO;
    import com.langcollab.languagementor.vo.LessonVersionVO;

    public class Command_DoIKnowThis extends Command_Base__LangMentor
    {

        private var _preCommandSelectedLessonCount:uint;

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        //
        //          Public Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

        public function Command_DoIKnowThis(preCommandSelectedLessonCount:uint, callbacks:Callbacks)
        {
            super();
            Log.debug("Command_DoIKnowThis - Constructor");
            _preCommandSelectedLessonCount = preCommandSelectedLessonCount;
            this.callbacks = callbacks;
        }

        private var _isDisposed:Boolean = false;
        private var _isLessonVersionCurrentlyPlayingAndNotPaused:Boolean;
        private var _oldLessonVersion:LessonVersionVO;

        override public function dispose():void
        {
            Log.debug("Command_DoIKnowThis.dispose()");
            super.dispose();
            if (_isDisposed)
                return;
            _isDisposed = true;
            //_chunkLearningFeedbackVO = null;
            model = null;
            _oldLessonVersion = null;
        }

        public function execute():void
        {
            Log.info("Command_DoIKnowThis.execute()");
            _isLessonVersionCurrentlyPlayingAndNotPaused = ((currentLessons.isLessonPlaying) && (!currentLessons.isLessonPaused));
            currentLessons.pauseCurrentLessonVersionIfPlaying();
            _oldLessonVersion = currentLessons.currentLessonVO;
            var cvo:ChunkVO = currentLessons.getChunkVOByLessonVersionVOAndChunkLocationInOrder(currentLessons.currentLessonVO, currentLessons.currentChunkIndex + 1);
            cvo.suppressed = true;
            var updatedPropNames:Array = [];
            updatedPropNames.push("suppressed");
            var modelReport:MainModelDBOperationReport = 
                model.updateVO_NoKeyPropChangesAllowed("Command_DoIKnowThis.execute", cvo, updatedPropNames);
            if (modelReport.isAnyProblems)
            {
                // The only time that I've seen this happen is, when testing the app, I've hit the I know this button repeatedly and
                // quickly, and Data has found that its _currentSQLiteOperation prop != null.
                Log.warn(["Command_DoIKnowThis.execute(): Problem updating DB", modelReport]);
                modelReport.dispose();
                resumeAudioIfAppropriate();
            }
            else
            {
                modelReport.dispose();
                if (!currentLessons.doesLessonVersionContainAnyUnsuppressedChunks(_oldLessonVersion))
                {
                    currentLessons.stopPlayingCurrentLessonVersionIfPlaying();
                    // 20130711 - We do this before currentLessons.ensureStateIntegrity() because this both a) removes 
                    //            lesson, and b) unsupresses all chunks whereas ensureStateIntegrity() just removes 
                    //            the lesson without unsuppressing chunks. Which is wrong. And should probably be 
                    //            fixed. At some point.  :)
                    var c:Command_AddOrRemoveSelectedLessonVersion = 
                        new Command_AddOrRemoveSelectedLessonVersion(_oldLessonVersion);
                    c.execute();
                   if (Utils_System.isMobilePlatform())
                      reportLessonLearnedToAnalytics();
                }
                resumeAudioIfAppropriate();
                result(_preCommandSelectedLessonCount);
                dispose();
            }
            dispose();
        }

        private function reportLessonLearnedToAnalytics():void
        {
            var lessonName:String = model.getLessonVersionNativeLanguageNameFromLessonVersionVO(_oldLessonVersion);
            var lessonVersion:String = _oldLessonVersion.publishedLessonVersionVersion;
            Utils_NativeExtensions.googleAnalyticsTrackLessonLearned(lessonName, lessonVersion);
        }

        private function resumeAudioIfAppropriate():void
        {
            currentLessons.ensureStateIntegrity();
            audioController.decrementTempChunkSequenceStrategyAndClearIfAppropriate();
            if (!currentLessons.currentLessonVO.equals(_oldLessonVersion))
                audioController.doPost_IKnowThis_ChangedLessonVersionStuff();
            if ((_isLessonVersionCurrentlyPlayingAndNotPaused) && (currentLessons.length > 0))
            {
                currentLessons.playCurrentLessonVersionAndCurrentChunk();
            }
        }

    }
}






