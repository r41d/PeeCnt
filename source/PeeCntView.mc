import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// One view with three pages: counter, history chart, statistics.
class PeeCntView extends WatchUi.View {

    enum {
        PAGE_COUNTER,
        PAGE_HISTORY,
        PAGE_STATS,
        PAGE_COUNT
    }

    var page as Number = PAGE_COUNTER;
    var range as Number = 7;   // 7 or 30 days, shared by history and stats

    function initialize() {
        View.initialize();
    }

    function changePage(delta as Number) as Void {
        page = (page + delta + PAGE_COUNT) % PAGE_COUNT;
        WatchUi.requestUpdate();
    }

    function toggleRange() as Void {
        range = (range == 7) ? 30 : 7;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (page == PAGE_COUNTER) {
            drawCounter(dc);
        } else if (page == PAGE_HISTORY) {
            drawHistory(dc);
        } else {
            drawStats(dc);
        }
        drawPageDots(dc);
    }

    private function drawTitle(dc as Dc, text as String) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() * 0.16, Graphics.FONT_SMALL, text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawCounter(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var center = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        var list = PeeStore.today(PeeStore.load());
        var n = list.size();

        drawTitle(dc, "Today");

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h / 2, Graphics.FONT_NUMBER_THAI_HOT, n.format("%d"), center);

        // Touch targets
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w * 0.16, h / 2, Graphics.FONT_LARGE, "-", center);
        dc.drawText(w * 0.84, h / 2, Graphics.FONT_LARGE, "+", center);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var info = (n > 0) ? "last " + PeeStore.formatTime(list[n - 1]) : "nothing yet";
        dc.drawText(w / 2, h * 0.80, Graphics.FONT_XTINY, info, center);
    }

    private function drawHistory(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var center = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        var stats = new PeeStats(range);
        var showLabels = (range == 7);

        drawTitle(dc, "Last " + range.format("%d") + " days");

        var left = w * 0.18;
        var right = w * 0.82;
        var top = h * 0.34;
        var bottom = h * 0.68;
        var slot = (right - left) / range;
        var barW = showLabels ? slot * 0.6 : slot - 2;
        if (barW < 1) {
            barW = 1;
        }
        var maxCount = (stats.maxCount > 0) ? stats.maxCount : 1;
        var letters = ["S", "M", "T", "W", "T", "F", "S"];

        for (var i = 0; i < range; i++) {
            var n = stats.counts[i];
            var cx = left + slot * (i + 0.5);
            var barH = (bottom - top) * n / maxCount;

            // The last bar is today
            dc.setColor(i == range - 1 ? Graphics.COLOR_YELLOW : Graphics.COLOR_BLUE,
                Graphics.COLOR_TRANSPARENT);
            if (n > 0) {
                dc.fillRectangle(cx - barW / 2, bottom - barH, barW, barH);
            } else {
                dc.fillRectangle(cx - barW / 2, bottom - 1, barW, 1);
            }

            if (showLabels) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                if (n > 0) {
                    dc.drawText(cx, bottom - barH - h * 0.045, Graphics.FONT_XTINY, n.format("%d"), center);
                }
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, bottom + h * 0.05, Graphics.FONT_XTINY, letters[stats.weekdays[i] - 1], center);
            }
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.84, Graphics.FONT_XTINY,
            "avg " + stats.avgCount.format("%.1f") + " / day", center);
    }

    private function drawStats(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var stats = new PeeStats(range);
        var hasData = stats.loggedDays > 0;

        drawTitle(dc, "Stats - " + range.format("%d") + " days");

        drawStatRow(dc, h * 0.36, "Avg / day", hasData ? stats.avgCount.format("%.1f") : "--");
        drawStatRow(dc, h * 0.50, "Avg first", hasData ? PeeStore.formatTime(stats.avgFirst) : "--");
        drawStatRow(dc, h * 0.64, "Avg last", hasData ? PeeStore.formatTime(stats.avgLast) : "--");

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.82, Graphics.FONT_XTINY,
            stats.loggedDays.format("%d") + " days logged",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawStatRow(dc as Dc, y as Numeric, label as String, value as String) as Void {
        var mid = dc.getWidth() * 0.54;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mid - 8, y, Graphics.FONT_TINY, label,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mid + 8, y, Graphics.FONT_MEDIUM, value,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawPageDots(dc as Dc) as Void {
        var x = dc.getWidth() * 0.05;
        var cy = dc.getHeight() / 2;
        for (var i = 0; i < PAGE_COUNT; i++) {
            dc.setColor(i == page ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY,
                Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, cy + (i - 1) * 16, 4);
        }
    }

}
