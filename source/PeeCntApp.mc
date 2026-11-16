import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class PeeCntApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    // Entry in the glance carousel
    function getGlanceView() as [WatchUi.GlanceView] or [WatchUi.GlanceView, WatchUi.GlanceViewDelegate] or Null {
        return [ new PeeCntGlanceView() ];
    }

    // Full app, opened by selecting the glance
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new PeeCntView();
        return [ view, new PeeCntDelegate(view) ];
    }

}

function getApp() as PeeCntApp {
    return Application.getApp() as PeeCntApp;
}
