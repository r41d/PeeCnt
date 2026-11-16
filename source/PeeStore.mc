import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;

// Persistent storage. One Storage entry per day, keyed by the day as a
// Number (YYYYMMDD), holding the list of pee times of that day.
// Count = list size, first = first element, last = last element.
//
// A day runs from 04:00 to 04:00. Times are minutes since midnight of the
// day they belong to, so 01:30 at night is stored as 25:30 (1530) and
// averages across midnight come out right.
(:glance)
module PeeStore {

    const DAY_START_MIN = 240;   // 04:00
    const KEEP_DAYS = 365;
    const PRUNE_SPAN = 30;       // extra days checked beyond KEEP_DAYS

    // Now, shifted so that its calendar date is the day an entry belongs to.
    function logicalNow() as Time.Moment {
        return Time.now().add(new Time.Duration(-DAY_START_MIN * 60));
    }

    // Storage key for the calendar date of `moment`.
    function dayId(moment as Time.Moment) as Number {
        var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);
        return info.year * 10000 + (info.month as Number) * 100 + info.day;
    }

    // Entries of the given day (empty array if none).
    function get(id as Number) as Array<Number> {
        var list = Application.Storage.getValue(id);
        if (list instanceof Array) {
            return list as Array<Number>;
        }
        return [] as Array<Number>;
    }

    function today() as Array<Number> {
        return get(dayId(logicalNow()));
    }

    // Log one pee at the current time.
    function add() as Void {
        var now = logicalNow();
        var info = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var id = dayId(now);
        var list = get(id);
        if (list.size() == 0) {
            prune(now);   // once a day, on the first entry
        }
        list.add(info.hour * 60 + info.min + DAY_START_MIN);
        Application.Storage.setValue(id, list);
    }

    // Remove the most recent entry of the current day.
    function undo() as Void {
        var id = dayId(logicalNow());
        var list = get(id);
        var n = list.size();
        if (n == 0) {
            return;
        }
        if (n == 1) {
            Application.Storage.deleteValue(id);
        } else {
            Application.Storage.setValue(id, list.slice(0, n - 1));
        }
    }

    // Drop the days that just fell out of the KEEP_DAYS window.
    function prune(now as Time.Moment) as Void {
        for (var i = KEEP_DAYS; i < KEEP_DAYS + PRUNE_SPAN; i++) {
            Application.Storage.deleteValue(dayId(now.add(new Time.Duration(-i * 86400))));
        }
    }

    // Minutes since midnight -> "07:05" (always 24h). Values past 24:00 wrap.
    function formatTime(minutes as Number) as String {
        minutes = minutes % 1440;
        return (minutes / 60).format("%02d") + ":" + (minutes % 60).format("%02d");
    }
}
