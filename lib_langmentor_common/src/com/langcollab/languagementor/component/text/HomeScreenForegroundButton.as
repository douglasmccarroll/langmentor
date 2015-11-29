
package com.langcollab.languagementor.component.text
{
import com.brightworks.component.text.CenteredMobileText;
import com.brightworks.resource.Resources_Audio;
import com.brightworks.util.Utils_Text;

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import spark.core.SpriteVisualElement;

public class HomeScreenForegroundButton extends CenteredMobileText
    {
        private static const _BORDER_ALPHA__UP:Number = .2;
        private static const _BORDER_ALPHA__DOWN:Number = .6;

        public var color:uint;

        private var _isDisposed:Boolean;
        private var _isClickActive:Boolean;
        private var _spriteVisualElement_Border:SpriteVisualElement;
        private var _timer:Timer;

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        //
        //          Public Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

        public function HomeScreenForegroundButton()
        {
            super();
            percentHeight = 100;
            percentWidth = 100;
            spriteVisualElement.alpha = 1;
            _spriteVisualElement_Border = new SpriteVisualElement();
            _spriteVisualElement_Border.alpha = 0;
            addChild(_spriteVisualElement_Border);
            addEventListener(MouseEvent.CLICK, onClick);
        }

        override public function dispose():void
        {
            super.dispose();
            if (_isDisposed)
                return;
            _isDisposed = true;
            _spriteVisualElement_Border = null;
            removeEventListener(MouseEvent.CLICK, onClick);
        }

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        //
        //          Protected Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

        override protected function doInitTextField():void
        {
            super.doInitTextField();
            textField.setStyle("color", 0xFFFFFF);
            textField.setStyle("fontSize", Math.round(Utils_Text.getStandardFontSize() * 1.3));
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            updateButton();
        }

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        //
        //          Private Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        private function onClick(event:MouseEvent):void
        {
            if (_isClickActive)
                return;
            event.stopImmediatePropagation();
            event.preventDefault();
            Resources_Audio.CLICK.play();
            _isClickActive = true;
            _timer = new Timer(200);
            _timer.addEventListener(TimerEvent.TIMER, onTimer);
            _timer.start();
            invalidateDisplayList();
        }

        private function onTimer(event:TimerEvent):void
        {
            _timer.stop();
            _timer.addEventListener(TimerEvent.TIMER, onTimer);
            _timer = null;
            dispatchEvent(new MouseEvent(MouseEvent.CLICK));
            _isClickActive = false;
            invalidateDisplayList();
        }

        private function updateButton():void
        {
            spriteVisualElement.graphics.clear();
            _spriteVisualElement_Border.graphics.clear();
            spriteVisualElement.graphics.lineStyle(1, color, 1, true);
            spriteVisualElement.graphics.beginFill(color, 1);
            spriteVisualElement.graphics.drawRoundRect(
                0,
                0,
                spriteVisualElement.width,
                spriteVisualElement.height,
                6,
                6);
            spriteVisualElement.graphics.endFill();
            _spriteVisualElement_Border.alpha =
                _isClickActive ?
                _BORDER_ALPHA__DOWN :
                _BORDER_ALPHA__UP;
            _spriteVisualElement_Border.height = spriteVisualElement.height;
            _spriteVisualElement_Border.width = spriteVisualElement.width;
            _spriteVisualElement_Border.x = spriteVisualElement.x;
            _spriteVisualElement_Border.y = spriteVisualElement.y;
            _spriteVisualElement_Border.graphics.lineStyle(1, 0xFFFFFF, 1, true);
            _spriteVisualElement_Border.graphics.drawRoundRect(
                0,
                0,
                spriteVisualElement.width,
                spriteVisualElement.height,
                6,
                6);
        }

    }
}























