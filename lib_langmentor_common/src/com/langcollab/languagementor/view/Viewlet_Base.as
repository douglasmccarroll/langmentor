package com.langcollab.languagementor.view
{
    import com.brightworks.util.AppUseAnalytics;
    import com.brightworks.util.Utils_Layout;
    import com.langcollab.languagementor.controller.audio.AudioController;
    import com.langcollab.languagementor.controller.lessondownload.LessonDownloadController;
    import com.langcollab.languagementor.model.MainModel;
    import com.langcollab.languagementor.model.appstatepersistence.AppStatePersistenceManager;
    import com.langcollab.languagementor.model.currentlessons.CurrentLessons;

    import spark.components.SkinnableContainer;
    import spark.layouts.HorizontalAlign;
    import spark.layouts.VerticalLayout;

    public class Viewlet_Base extends SkinnableContainer
    {
        protected var appStatePersistenceManager:AppStatePersistenceManager = AppStatePersistenceManager.getInstance();
        protected var appUseAnalytics:AppUseAnalytics = AppUseAnalytics.getInstance();
        protected var audioController:AudioController = AudioController.getInstance();
        protected var currentLessons:CurrentLessons = CurrentLessons.getInstance();
        [Bindable]
        protected var model:MainModel = MainModel.getInstance();
        protected var lessonDownloadController:LessonDownloadController = LessonDownloadController.getInstance();

        private var _isDisposed:Boolean = false;

        public function Viewlet_Base()
        {
            super();
            percentWidth = 100;
            setLayoutAndPadding();
        }

        public function dispose():void
        {
            if (_isDisposed)
                return;
            _isDisposed = true;
        }

        protected function setLayoutAndPadding():void
        {
            layout = new VerticalLayout();
            VerticalLayout(layout).paddingBottom = Utils_Layout.getStandardPadding();
            VerticalLayout(layout).paddingLeft = Utils_Layout.getStandardPadding();
            VerticalLayout(layout).paddingRight = Utils_Layout.getStandardPadding();
            VerticalLayout(layout).paddingTop = Utils_Layout.getStandardPadding();
            VerticalLayout(layout).horizontalAlign = HorizontalAlign.CENTER;
        }

    }
}
