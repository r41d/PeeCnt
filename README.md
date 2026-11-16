# PeeCnt

A Garmin Connect IQ app that counts how often you pee each day. It adds an entry to the watch's glance list and keeps a year of history on the watch.

Currently built for the Forerunner 265 only.

## Features

- **Glance:** shows today's count and the time of the last entry. Selecting it opens the app.
- **Counter:** raise the count with one press, or lower it again after a mis-press.
- **History:** bar chart of the last 7 or 30 days.
- **Statistics:** average count per day, average time of the first and of the last entry, over the last 7 or 30 days.

## Controls

| Input | Counter page | History and statistics pages |
| --- | --- | --- |
| START button | Count up | Switch between 7 and 30 days |
| Tap, right two-thirds of the screen | Count up | Switch between 7 and 30 days |
| Tap, left third of the screen | Count down | Switch between 7 and 30 days |
| UP / DOWN or vertical swipe | Previous / next page | Previous / next page |
| Long-press UP | Menu: undo last, toggle range | Same menu |
| BACK | Exit | Exit |

## How the data is handled

- A day runs from 04:00 to 04:00, so an entry at 01:30 belongs to the previous day.
- Averages only include days with at least one entry.
- Times are always shown in 24-hour format.
- Entries are kept for 365 days, then deleted.
- All data stays on the watch. There is no sync to Garmin Connect: Connect IQ only lets apps attach data to a recorded activity, not publish a standalone daily value.

## Building

You need the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) with the Forerunner 265 device files, Java, and a developer key.

With the Monkey C extension for VS Code, run "Monkey C: Build for Device". From the command line:

```
monkeyc -d fr265 -f monkey.jungle -o bin/PeeCnt.prg -y /path/to/developer_key
```

To run it in the simulator:

```
connectiq &
monkeydo bin/PeeCnt.prg fr265
```

On Linux, the SDK Manager and the simulator need WebKitGTK 4.0 (`libwebkit2gtk-4.0.so.37`). Distributions that no longer package it, such as Arch and Manjaro, need a container with an older release (for example Ubuntu 22.04) to run them.

## Installing on the watch

1. Connect the watch over USB. It appears as an MTP device.
2. Copy `PeeCnt.prg` into `GARMIN/Apps/`.
3. Disconnect the watch.
4. From the watch face, scroll to the bottom of the glance list, choose Edit, then Add, and pick PeeCnt.

To update, copy a new build over the old file. Logged data is kept as long as the app ID in `manifest.xml` is unchanged. Uninstalling the app deletes its data.

## Project layout

| Path | Contents |
| --- | --- |
| `source/PeeStore.mc` | Storage: one entry per day, holding that day's times |
| `source/PeeStats.mc` | Counts and averages for a range of days |
| `source/PeeCntView.mc` | The counter, history and statistics pages |
| `source/PeeCntDelegate.mc` | Button, touch and menu handling |
| `source/PeeCntGlanceView.mc` | The glance |
| `source/PeeCntApp.mc` | App entry point |
| `resources/` | App name and launcher icon |
| `assets/` | Source artwork, not compiled into the app |
