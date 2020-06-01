package com.langcollab.languagementor.component {
import spark.preloaders.SplashScreenImage;

public class SplashScreenImageComp extends SplashScreenImage {
   [Embed(source='/Splash_White.png')]
   protected var iPhoneOneSizeFitsAllWhiteScreenClass:Class;

   public function SplashScreenImageComp() {
      super();
   }

   override public function getImageClass(aspectRatio:String, dpi:Number, resolution:Number):Class {
      return iPhoneOneSizeFitsAllWhiteScreenClass;
   }
}
}
