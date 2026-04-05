import Toybox.Lang;
import Toybox.WatchUi;

class PeeCntDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new PeeCntMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}