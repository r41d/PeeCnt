import Toybox.Lang;
import Toybox.Time;

// Aggregated numbers for the last `range` days (today included).
class PeeStats {

    var counts as Array<Number> = [] as Array<Number>;   // oldest first
    var weekdays as Array<Number> = [] as Array<Number>; // 1 = Sunday
    var maxCount as Number = 0;
    var loggedDays as Number = 0;   // days with at least one entry
    var avgCount as Float = 0.0f;   // over logged days
    var avgFirst as Number = 0;     // minutes since midnight
    var avgLast as Number = 0;

    function initialize(range as Number) {
        var days = PeeStore.load();
        // Walk back from noon so DST shifts can't skip or repeat a day.
        var noon = Time.today().add(new Time.Duration(43200));
        var total = 0;
        var sumFirst = 0;
        var sumLast = 0;

        for (var i = range - 1; i >= 0; i--) {
            var moment = noon.add(new Time.Duration(-i * 86400));
            var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);
            weekdays.add(info.day_of_week as Number);

            var list = days[PeeStore.dayId(moment)];
            var n = 0;
            if (list instanceof Array) {
                n = list.size();
                if (n > 0) {
                    loggedDays++;
                    total += n;
                    sumFirst += list[0] as Number;
                    sumLast += list[n - 1] as Number;
                }
            }
            counts.add(n);
            if (n > maxCount) {
                maxCount = n;
            }
        }

        if (loggedDays > 0) {
            avgCount = total.toFloat() / loggedDays;
            avgFirst = sumFirst / loggedDays;
            avgLast = sumLast / loggedDays;
        }
    }
}
