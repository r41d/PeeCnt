import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class PeeCntGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var list = PeeStore.today(PeeStore.load());
        var n = list.size();
        var line = n.format("%d") + " today";
        if (n > 0) {
            line += "  -  last " + PeeStore.formatTime(list[n - 1]);
        }

        var h = dc.getHeight();
        var just = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, h * 0.28, Graphics.FONT_GLANCE, "PEE COUNT", just);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, h * 0.72, Graphics.FONT_GLANCE, line, just);
    }
}
