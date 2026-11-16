import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class PeeCntDelegate extends WatchUi.BehaviorDelegate {

    private var _view as PeeCntView;

    function initialize(view as PeeCntView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // UP / DOWN buttons and vertical swipes switch pages
    function onNextPage() as Boolean {
        _view.changePage(1);
        return true;
    }

    function onPreviousPage() as Boolean {
        _view.changePage(-1);
        return true;
    }

    // START button: count up on the counter page, toggle 7/30 days elsewhere.
    // Handled as a raw key rather than via onSelect(): a screen tap also
    // triggers onSelect() first, which would swallow it before onTap().
    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        if (evt.getKey() != WatchUi.KEY_ENTER) {
            return false;
        }
        if (_view.page == PeeCntView.PAGE_COUNTER) {
            add();
        } else {
            _view.toggleRange();
        }
        return true;
    }

    // Touch: left third of the counter page lowers, the rest raises
    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        if (_view.page != PeeCntView.PAGE_COUNTER) {
            _view.toggleRange();
        } else if (evt.getCoordinates()[0] < System.getDeviceSettings().screenWidth / 3) {
            undo();
        } else {
            add();
        }
        return true;
    }

    // Long-press UP
    function onMenu() as Boolean {
        var menu = new WatchUi.Menu2({ :title => "PeeCnt" });
        menu.addItem(new WatchUi.MenuItem("Undo last", "Lower today's count", :undo, null));
        menu.addItem(new WatchUi.MenuItem("Toggle range", "7 / 30 days", :range, null));
        WatchUi.pushView(menu, new PeeCntMenuDelegate(self, _view), WatchUi.SLIDE_UP);
        return true;
    }

    function add() as Void {
        PeeStore.add();
        vibrate(60);
        WatchUi.requestUpdate();
    }

    function undo() as Void {
        PeeStore.undo();
        vibrate(25);
        WatchUi.requestUpdate();
    }

    private function vibrate(ms as Number) as Void {
        if (Attention has :vibrate) {
            Attention.vibrate([ new Attention.VibeProfile(50, ms) ]);
        }
    }

}

class PeeCntMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _delegate as PeeCntDelegate;
    private var _view as PeeCntView;

    function initialize(delegate as PeeCntDelegate, view as PeeCntView) {
        Menu2InputDelegate.initialize();
        _delegate = delegate;
        _view = view;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :undo) {
            _delegate.undo();
        } else if (id == :range) {
            _view.toggleRange();
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}
