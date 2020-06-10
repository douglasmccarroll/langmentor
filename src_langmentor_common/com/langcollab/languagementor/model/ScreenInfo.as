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
package com.langcollab.languagementor.model {

public class ScreenInfo {
   public function ScreenInfo() {
   }

   /*public function getScreenIdFromPosition(horizontalPos:int, verticalPos:int):int
   {
       var result:int;
       switch (horizontalPos)
       {
           case 2:
               switch (verticalPos)
               {
                   case 3:
                       result = Constants_ScreenStateCodes.SELECT_MODE;
                       break;
                   default:
   Log.fatal("ScreenInfo.getScreenIdFromPosition(): no screen defined at " + horizontalPos + ", " + verticalPos);
               }
               break;
           case 3:
               switch (verticalPos)
               {
                   case 2:
                       result = Constants_ScreenStateCodes.PLAY_LESSONS;
                       break;
                   case 3:
                       result = Constants_ScreenStateCodes.MAIN_MENU;
                       break;
                   case 4:
                       result = Constants_ScreenStateCodes.OPTIONS;
                       break;
                   default:
   Log.fatal("ScreenInfo.getScreenIdFromPosition(): no screen defined at " + horizontalPos + ", " + verticalPos);
               }
               break;
           case 4:
               switch (verticalPos)
               {
                   case 3:
                       result = Constants_ScreenStateCodes.SELECT_LESSONS;
                       break;
                   default:
   Log.fatal("ScreenInfo.getScreenIdFromPosition(): no screen defined at " + horizontalPos + ", " + verticalPos);
               }
               break;
           case 5:
               switch (verticalPos)
               {
                   case 3:
                       result = Constants_ScreenStateCodes.SELECT_LESSONS_OPTIONS;
                       break;
                   default:
   Log.fatal("ScreenInfo.getScreenIdFromPosition(): no screen defined at " + horizontalPos + ", " + verticalPos);
               }
               break;
           default:
   Log.fatal("ScreenInfo.getScreenIdFromPosition(): no screen defined at " + horizontalPos + ", " + verticalPos);
       }
       return result;
   }*/

   /*public function getScreenHorizontalPositionFromScreenId(screen:int):int
   {
       var result:int;
       switch (screen)
       {
           case Constants_ScreenStateCodes.OPTIONS:
               result = 3;
               break;
           case Constants_ScreenStateCodes.MAIN_MENU:
               result = 3;
               break;
           case Constants_ScreenStateCodes.PLAY_LESSONS:
               result = 3;
               break;
           case Constants_ScreenStateCodes.SELECT_MODE:
               result = 2;
               break;
           case Constants_ScreenStateCodes.SELECT_LESSONS:
               result = 4;
               break;
           case Constants_ScreenStateCodes.SELECT_LESSONS_OPTIONS:
               result = 5;
               break;
           default:
   Log.fatal("MainModel.getScreenX() - no matching case: " + screen);
       }
       return result;
   }*/

   /*public function getScreenVerticalPositionFromScreenId(screen:int):int
   {
       var result:int;
       switch (screen)
       {
           case Constants_ScreenStateCodes.OPTIONS:
               result = 4;
               break;
           case Constants_ScreenStateCodes.MAIN_MENU:
               result = 3;
               break;
           case Constants_ScreenStateCodes.PLAY_LESSONS:
               result = 2;
               break;
           case Constants_ScreenStateCodes.SELECT_MODE:
               result = 3;
               break;
           case Constants_ScreenStateCodes.SELECT_LESSONS:
               result = 3;
               break;
           case Constants_ScreenStateCodes.SELECT_LESSONS_OPTIONS:
               result = 3;
               break;
           default:
   Log.fatal("MainModel.getScreenY() - no matching case: " + screen);
       }
       return result;
   }
*/
}
}
