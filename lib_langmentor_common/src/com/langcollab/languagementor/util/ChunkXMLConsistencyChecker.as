package com.langcollab.languagementor.util
{
    import com.brightworks.util.Log;
    import com.langcollab.languagementor.constant.Constant_TextDisplayTypeNames;

    import flash.utils.Dictionary;

    public class ChunkXMLConsistencyChecker
    {
        public function ChunkXMLConsistencyChecker()
        {
        }

        // Search for "ChunkXMLConsistencyCheck" for comments explaining what this method does.
        // if (any textNode type exists in some but not all chunk nodes)
        //   add lessonId:false to all indexes
        //   return false
        // else
        //   for each textNode type
        //     if no  chunks have that textNode type, add lessonId:false to matching index.
        //     if all chunks have that textNode type, add lessonId:true  to matching index.
        //   return true
        public static function check(
            lessonId:String, 
            chunksNodeList:XMLList, 
            hasTextIndexList:Array):Boolean
        {
            if (Constant_TextDisplayTypeNames.TYPE_NAME_LIST.length != hasTextIndexList.length)
            {
                Log.fatal("ChunkXMLConsistencyChecker.check(): lists must be same length");
            }
            if (chunksNodeList.length() == 0)
            {
                // This isn't an error - this lesson just doesn't have any text.
                for each (var hasTextIndex:Dictionary in hasTextIndexList)
                {
                    hasTextIndex[lessonId] = false;
                }
                return true;
            }
            else if (chunksNodeList.length() > 1)
            {
                // This is an error, and should have been caught before this.
                Log.error("ChunkXMLConsistencyChecker.check(): multiple chunks nodes");
                return false;
            }
            var chunkNodeList:XMLList = chunksNodeList[0].chunk;
            if (chunkNodeList.length() == 0)
                return true; // Not an error, though a bit odd...
            var chunkNodeCount:uint = chunkNodeList.length();
            var index_textNodeName_to_hasTextBoolean:Dictionary = new Dictionary();
            var index_textNodeName_to_hasTextIndex:Dictionary = new Dictionary();
            var textTypeCount:uint = Constant_TextDisplayTypeNames.TYPE_NAME_LIST.length;
            for (var i:uint = 0; i < textTypeCount; i++)
            {
                var textNodeName:String = Constant_TextDisplayTypeNames.TYPE_NAME_LIST[i];
                hasTextIndex = hasTextIndexList[i];
                index_textNodeName_to_hasTextIndex[textNodeName] = hasTextIndex;
                var isError:Boolean;
                var chunksWithThisTypeTextNodeCount:uint = ChunkXMLConsistencyChecker.getCountOfChunksWithTextNode(textNodeName, chunkNodeList);
                if ((chunksWithThisTypeTextNodeCount > 0) &&
                    (chunksWithThisTypeTextNodeCount < chunkNodeCount))
                    return false;
                index_textNodeName_to_hasTextBoolean[textNodeName] = 
                    (chunksWithThisTypeTextNodeCount == chunkNodeCount);
            }
            // If we've gotten this far, all text types are either in all nodes or in no nodes
            for each (textNodeName in Constant_TextDisplayTypeNames.TYPE_NAME_LIST)
            {
                var hasTextBoolean:Boolean = index_textNodeName_to_hasTextBoolean[textNodeName];
                hasTextIndex = index_textNodeName_to_hasTextIndex[textNodeName];
                hasTextIndex[lessonId] = hasTextBoolean;
            }
            return true;
        }

        public static function isAnyChunkNodesContainMultipleTextNodesOfSameType(chunksNode:XML):Boolean
        {
            var chunkNodeList:XMLList = chunksNode.chunk;
            if (chunkNodeList.length() == 0)
                return false;
            for each (var chunkNode:XML in chunkNodeList)
            {
                for each (var nodeName:String in Constant_TextDisplayTypeNames.TYPE_NAME_LIST)
                {
                    var textNodeList:XMLList = chunkNode[nodeName];
                    if (textNodeList.length() > 1)
                        return true;
                }
            }
            return false;
        }

        private static function getCountOfChunksWithTextNode(textNodeName:String, chunkNodeList:XMLList):uint
        {
            var result:uint = 0;
            for each (var chunkNode:XML in chunkNodeList)
            {
                if (XMLList(chunkNode[textNodeName]).length() > 0)
                    result++;
            }
            return result;
        }
    }
}






















