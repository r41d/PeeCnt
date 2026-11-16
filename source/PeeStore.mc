import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

// Persistent storage. One dictionary, keyed by day (YYYYMMDD as a Number),
// each value being the list of pee times of that day in minutes since midnight.
// Count = list size, first = first element, last = last element.
(:glance)
module PeeStore {

    const KEY = "days";
    const KEEP_DAYS = 30;

    function dayId(moment as Time.Moment) as Number {
        var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);
        return info.year * 10000 + (info.month as Number) * 100 + info.day;
    }

    function load() as Dictionary {
        var days = Application.Storage.getValue(KEY);
        if (days instanceof Dictionary) {
            return days;
        }
        return {};
    }

    function save(days as Dictionary) as Void {
        Application.Storage.setValue(KEY, days as Application.PropertyValueType);
    }

    // Entries of the current day (empty array if none).
    function today(days as Dictionary) as Array<Number> {
        var list = days[dayId(Time.now())];
        if (list instanceof Array) {
            return list as Array<Number>;
        }
        return [] as Array<Number>;
    }

    // Log one pee at the current time.
    function add() as Void {
        var days = load();
        var now = Time.now();
        var info = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var list = today(days);
        list.add(info.hour * 60 + info.min);
        days[dayId(now)] = list;
        prune(days);
        save(days);
    }

    // Remove the most recent entry of the current day.
    function undo() as Void {
        var days = load();
        var list = today(days);
        var n = list.size();
        if (n == 0) {
            return;
        }
        var id = dayId(Time.now());
        if (n == 1) {
            days.remove(id);
        } else {
            days[id] = list.slice(0, n - 1);
        }
        save(days);
    }

    // Drop days older than KEEP_DAYS.
    function prune(days as Dictionary) as Void {
        if (days.size() <= KEEP_DAYS) {
            return;
        }
        var cutoff = dayId(Time.now().add(new Time.Duration(-KEEP_DAYS * 86400)));
        var keys = days.keys();
        for (var i = 0; i < keys.size(); i++) {
            if ((keys[i] as Number) < cutoff) {
                days.remove(keys[i]);
            }
        }
    }

    // Minutes since midnight -> "07:05" or "7:05a".
    function formatTime(minutes as Number) as String {
        var h = minutes / 60;
        var m = minutes % 60;
        if (System.getDeviceSettings().is24Hour) {
            return h.format("%02d") + ":" + m.format("%02d");
        }
        var suffix = h < 12 ? "a" : "p";
        h = h % 12;
        if (h == 0) {
            h = 12;
        }
        return h.format("%d") + ":" + m.format("%02d") + suffix;
    }
}
