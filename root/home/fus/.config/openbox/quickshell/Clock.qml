import QtQuick
import Quickshell
import Quickshell.Io

// Date + time (the slstatus formats), with a calendar on click.
//
// 12-hour by default. For a 24-hour clock create ~/.config/openbox/clock-24h
// (`touch` is enough — contents are ignored); delete it to go back. The
// file is live-watched, so no bar restart is needed either way.
BarModule {
    id: root

    property bool use24h: false

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    FileView {
        path: Theme.configDir + "/clock-24h"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.use24h = true
        onLoadFailed: root.use24h = false
    }

    label: Qt.formatDateTime(clock.date, "ddd MMM d") + "  "
           + Qt.formatDateTime(clock.date, root.use24h ? "HH:mm" : "h:mm AP")

    onClicked: calendar.visible = !calendar.visible

    CalendarPopup {
        id: calendar
        anchorItem: root
    }
}
