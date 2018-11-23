package com.langcollab.languagementor.util {
import com.brightworks.util.Log;
import com.langcollab.languagementor.constant.Constant_TextDisplayTypeNames;

import flash.utils.Dictionary;

public class ChunkXMLConsistencyChecker {
   public function ChunkXMLConsistencyChecker() {
   }
   ///// Is this useful in LC? or delete
   public static function isAnyChunkNodesContainMultipleTextNodesOfSameType(chunksNode:XML):Boolean {
      var chunkNodeList:XMLList = chunksNode.chunk;
      if (chunkNodeList.length() == 0)
         return false;
      for each (var chunkNode:XML in chunkNodeList) {
         for each (var nodeName:String in Constant_TextDisplayTypeNames.TYPE_NAME_LIST) {
            var textNodeList:XMLList = chunkNode[nodeName];
            if (textNodeList.length() > 1)
               return true;
         }
      }
      return false;
   }

}
}






















