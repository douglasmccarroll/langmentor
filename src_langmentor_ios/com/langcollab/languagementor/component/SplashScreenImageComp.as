package com.langcollab.languagementor.component {
import spark.preloaders.SplashScreenImage;

public class SplashScreenImageComp extends SplashScreenImage {
   /*[Embed(source='/Splash_iPhone4.png')]
   protected var iPhone4ImageClass:Class;
   [Embed(source='/Splash_iPhone5.png')]
   protected var iPhone5ImageClass:Class;
   [Embed(source='/Splash_iPhone6.png')]
   protected var iPhone6ImageClass:Class;
   [Embed(source='/Splash_iPhone6Plus.png')]
   protected var iPhone6PlusImageClass:Class;*/
   [Embed(source='/Splash_White.png')]
   protected var iPhoneOneSizeFitsAllWhiteScreenClass:Class;

   public function SplashScreenImageComp() {
      super();
   }

   override public function getImageClass(aspectRatio:String, dpi:Number, resolution:Number):Class {
      return iPhoneOneSizeFitsAllWhiteScreenClass;
      /*var splashClass:Class;
      switch (resolution) {
         case 1920: // I'm not sure where I got this number, but...
         case 2001: // This is what I'm getting when I run the code now (201707)
            splashClass = iPhone6PlusImageClass;
            break;
         case 1334: // iphone 6
            splashClass = iPhone6ImageClass;
            break;
         case 1136: // iphone 5
            splashClass = iPhone5ImageClass;
            break;
         case 960: 
            splashClass = iPhone4ImageClass;
            break;
         default:
            // Return null
      }
      return splashClass;*/
   }
}
}
