This file contains instructions for setting up and building the Language Mentor 
Android/iOS app, and copyright and license information.

Setting Up & Building
*********************

These instructions assume that you're using Adobe Flash Builder, and have a fair amount 
of experience with it and knowledge of its details. In other words, we provide only the 
details that an experienced Adobe AIR/Flex developer will need. 

To set up and build this project you'll need to do the following:
  - Check out https://languagementor.googlecode.com/svn/trunk/languagementor (this ReadMe 
    file is in this repository's root folder)
    These instructions refer to the folder you put this code into as [languagementor].
  - Check out https://languagementor.googlecode.com/svn/trunk/brightworks
    These instructions refer to the folder you put this code into as [brightworks].
  - In [languagementor] you'll find three project folders. Import one or more of these into 
    Flash Builder:
         /langmentor_android
         /langmentor_desktop - used for running in simulator on desktop
         /langmentor_ios
  - The projects share the code in [languagementor]/src_common. Go into project properties 
    and edit the source path entry that points at this folder so that it matches your folder 
    hierarchy.
  - The projects also use the following source folders. You'll need to edit their source paths as well.
         [brightworks]/src_bright
         [brightworks]/src_bright_air
         [brightworks]/src_tink  
         [brightworks]/src_zxing 
  - The projects are configured to use a folder containing native extensions. As most of these are
    licensed from vendors and not available for free distribution we haven't included them. You'll 
    need to either provide your own and edit the paths that point to them in the projects' properties, 
    or remove the references to them in the projects' properties. These extensions are used by only one 
    class - com.brightworks.util.Utils_NativeExtensions. A separate version of this class is 
    provided for each of the three projects. This allows us to configure native extensions separately 
    for each project. Take a look at the version that's in [brightworks]/langmentor_desktop/src. This
    version's methods are all empty, i.e. they do nothing, because the native extensions we use don't
    work on the desktop. If you've chosen to disable native extensions in the langmentor_android and
    langmentor_ios projects, you should edit these projects' Utils_NativeExtensions files so that they 
    are similar or identical to the langmentor_desktop project's version.
    
We hope that this is helpful. If we've missed anything, please let us know at 
http://www.brightworks.com/contact.html.

    
Copyright & License Info - Brightworks Code
*******************************************

Copyright 2008 - 2015 Brightworks, Inc.

Language Mentor is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Language Mentor is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You can find a copy of the GNU Public License, Version 3 in the same folder
where you found this file, i.e. the root folder of
https://languagementor.googlecode.com/svn/trunk/languagementor.
You can also find a copy at http://www.gnu.org/licenses.


Copyright & License Info - Tink's Code
**************************************

Copyright and license information for Tink's code can be found at the root
of the source_tink source code folder (see above). A full version of his code 
can be found at http://code.google.com/p/tink/.

Thanks for sharing, Tink!


Copyright & License Info - ZXing Code
*******************************************

Copyright and license information for the ZXing code can be found at the root
of the source_zxing source code folder (see above). A full version of this code 
can be found at https://github.com/zxing/zxing/tree/master/actionscript.

Thanks for sharing, ZXing authors!
    

    
