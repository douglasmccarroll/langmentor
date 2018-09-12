package com.langcollab.languagementor.component {
import spark.preloaders.SplashScreenImage;

public class SplashScreenImageComp extends SplashScreenImage {
   [Embed(source='/assets/images/Splash_iPhone3.png')]
   protected var iPhone3ImageClass:Class;
   [Embed(source='/assets/images/Splash_iPhone4.png')]
   protected var iPhone4ImageClass:Class;
   [Embed(source='/assets/images/Splash_iPhone5.png')]
   protected var iPhone5ImageClass:Class;

   public function SplashScreenImageComp() {
      super();
   }

   override public function getImageClass(aspectRatio:String, dpi:Number, resolution:Number):Class {
      var splashClass:Class;
      switch (resolution) {
         case 1096: // iphone 5
            splashClass = iPhone5ImageClass;
            break;
         case 920: // iPhone 4
            splashClass = iPhone4ImageClass;
            break;
         case 460: //iPhone 3
            splashClass = iPhone3ImageClass;
            break;
         default:
            splashClass = iPhone4ImageClass;
            break;
      }
      return splashClass;
   }
}
}
