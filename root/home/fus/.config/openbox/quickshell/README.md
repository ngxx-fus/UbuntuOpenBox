# quickshell shell for openbox

The full desktop shell: bar, popups, wallpaper-driven theming, and the
network app. Openbox needs **no patch** — it honors dock struts natively,
desktop state streams from an `xprop -spy` on the root window (EWMH), and
actions go through `xdotool`.

Launch: `qs -p ~/.config/openbox/quickshell` (autostart does this), or
`scripts/bar restart|log` which handles the `-p` flag.

## Why so much QML?

~2,500 lines across ~27 files looks like a lot next to a 222-line polybar
ini. The difference: that ini sat on top of tens of thousands of lines of
other people's C++ — polybar, gsimplecal, dunst's popup renderer, nm-applet,
plus glue scripts. The QML replaces the config *and* several of those
binaries: `CalendarPopup.qml` is the calendar, `NotifyPopup.qml` is the
notification popup, `quickshell-network/` is the network applet, and
`WallpaperPicker.qml` is a tool that didn't exist before. The code didn't
appear — it moved from `apt` into this directory where you can read, edit,
and delete it.

Nobody edits 2,500 lines. It's one widget per file, averaging ~95 lines
(`Clock.qml` is 37). Want a module gone? Delete its file and its line in
`Bar.qml`. And much of QML *is* config — colors, spacing, and anchors that
were ini keys in polybar are QML properties here.

## Portability contract (read before porting to another WM)

This tree is the openbox vendored copy of the shell; **bspwm-setup holds the
reference implementation**. Cohesion across projects comes from keeping the
shared files byte-identical — `diff -r` between two projects' quickshell
dirs should show only the files listed as WM-specific.

**Shared verbatim (do not fork per WM):**
`Theme.qml` `BarModule.qml` `Popout.qml` `WallpaperPicker.qml`
`Weather.qml` `WeatherPopup.qml` `NotifyPopup.qml` `Network.qml`
`CalendarPopup.qml` `Clock.qml` `Media.qml` `Metrics.qml` `Volume.qml` `VolumePopup.qml`
`Tray.qml` `Bell.qml` `CapsLock.qml` `Screenshot.qml` `PowerButton.qml`
`Launcher.qml` `Title.qml` `Sys.qml` `TweakSlider.qml` `Commands.qml`
`MicMute.qml` `MediaPopup.qml` `Updates.qml` — plus `scripts/wallpaper-theme`
(all but its WM tail), `scripts/network`, `scripts/bar`, and the
`quickshell-network/` app.
(`Commands.qml` and `Updates.qml` are shared with dwm-setup too, differing
only in the terminal they spawn — `kitty` here, `st` there.)

**WM-specific (this project's versions):**
- `Wm.qml` — EWMH backend: `xprop -spy -root` for
  `_NET_CURRENT_DESKTOP` / `_NET_NUMBER_OF_DESKTOPS` / `_NET_CLIENT_LIST`,
  occupancy recomputed from the client list (debounced), actions via
  `xdotool`. Works on any EWMH-compliant WM. Urgency not tracked yet.
- `Tags.qml` — same visuals as the reference, fed from the EWMH backend's
  seltags/occtags bitmasks.
- Layout modules (`LayoutButton.qml` `LayoutPicker.qml` `LayoutIcon.qml`,
  `scripts/layout`) — bspwm-only; dropped here.
- Tail of `scripts/wallpaper-theme` — generates the Openbox window theme
  (a flat `~/.themes/Wallpaper-Openbox/openbox-3/themerc` written from the
  palette; Orchis-Dark-Nord is the GTK recolor template, a separate step)
  and runs `openbox --reconfigure`.

**Interfaces that must never drift between projects:**
- `polybar/colors.ini` palette keys (background, background-alt, foreground,
  primary, secondary, alert, disabled, border) — Theme.qml's watch target.
- `wallpaper-theme <image> <8 semantic> <16 ansi>` argument order.
- IPC targets: `wallpapers` (toggle/random/set), `tweaks` (toggle),
  `commands` (toggle), `wm` (refreshLayout, bspwm only).
- Script names in `scripts/`: wallpaper-theme, network, bar (+ layout on
  bspwm).

## Live theming

`Theme.qml` watches `polybar/colors.ini`, which `scripts/wallpaper-theme`
rewrites on every wallpaper pick — the bar re-colors in place, no restart.
The picker extracts the palette in QML (Canvas histogram; fidelity mode for
flat designed art, pastel interpretation for photos). A beacon check runs
first: a small, bright, hue-distinct cluster — a lamp, neon sign, sunset
sliver — becomes the accent even though it barely registers in the
histogram, and the dominant field hue steps down to secondary; images
without one behave exactly as before and the script fans it
out to bar/rofi/dunst/kitty/GTK/borders plus the Openbox window theme.
Dunst's config is symlinked from `~/.config/dunst/dunstrc` so D-Bus-spawned
dunst is themed too.

## Controls

| Module   | Left click        | Right click   | Middle       | Scroll          |
|----------|-------------------|---------------|--------------|-----------------|
| Launcher | rofi drun         | wallpaper picker | random wallpaper | —         |
| Desktop  | focus             | —             | send window  | cycle occupied  |
| Media    | play/pause        | now-playing popup | dismiss until track changes | prev/next track |
| Weather  | 3-day forecast popup | rofi config (city/zip · °C/°F/auto) | — | — |
| Volume   | mute              | volume popup: slider, output picker, pavucontrol | — | ±2% |
| Network  | network app       | nm-connection-editor | —     | —               |
| Tray     | activate          | menu          | secondary    | —               |
| Bell     | (appears only while DND is on — click resumes, right-click history) |||
| Clock    | calendar popup    | —             | —            | —               |
| Updates  | (appears only with pending apt upgrades — click opens upgrade terminal, middle re-checks) |||
| Mic      | (appears only while the mic is muted — click unmutes) |||
| Caps     | (indicator — appears only while caps lock is on) |||
| Screenshot | flameshot gui   | —             | —            | —               |
| Commands | command menu popup | —            | —            | —               |
| Bar (empty area) | — | bar tweaks popup (height · element scale) | — | —    |

Keybindings (rc.xml, matching the bspwm bindings): `W-S-t` wallpaper
picker · `W-n` network app · `W-m` command menu (bspwm/dwm use
`super+shift+m`; `W-S-m` is keyboard Move here) · `W-C-r` restart the bar.

The command menu (󰘳, right end of the bar) is the quick-settings panel:
actions with **no other bar surface**. A 2-col grid of toggle pills
(filled = on; right-click opens the full tool where one exists —
mic → pavucontrol's input tab): power profile cycle, keep-screen-awake,
mic mute, night light, DND (right-click = notification history; the Bell
module is CapsLock-pattern now — on the bar only while DND is active, so
the silenced state stays glanceable), and a pomodoro (countdown + drain
bar show on the 󰘳 pill itself; right-click cycles 15/25/45/60 presets,
scroll nudges ±5 min, idle only). Below: brightness slider (laptops with
a backlight only), then launcher rows — apt updates, keybind help, bar
restart, and the rofi power menu (which replaced the old PowerButton
module — the file stays for other ports). Stateful glanceable modules
(volume, network, DND, media) never move in here. IPC: `commands toggle`.

Bar tweaks (`BarTweaks.qml`, IPC target `tweaks`): bar height and element
scale sliders, applied live and persisted to plain live-watched files
`bar-height` and `bar-scale` in the openbox dir — `echo 48 >
~/.config/openbox/bar-height` works identically. Element scale resizes
fonts, icons, module pills, tags, and tray; popups stay fixed. Height is
a floor, not a cap — the bar grows to fit when scaled elements outgrow
it. Defaults (42 / 1.0) apply when the files are absent. This is the
openbox counterpart of the bspwm layout picker's Desktop section, minus
the bspc-only tweaks.

Weather config: right-click the module → rofi flow (`scripts/weather`) for
location (city/zip/airport; empty = auto by IP) and units (°F/°C/auto by
locale). State is two plain live-watched files — `weather-location` and
`weather-units` in the openbox dir — so `echo`/`rm` work identically for
scripts. Location auto-detect follows VPN exit nodes; the popup's 󰍎 line
shows which location the data is actually for.

Clock format: 12-hour by default. `touch ~/.config/openbox/clock-24h` for
24-hour (`rm` it to go back) — live-watched, no restart needed.

Design grammar: indicators sit flat on the bar or icon-only — no
hover-expanding labels (a module growing on hover shifts the
right-anchored row out from under the cursor); details live in popups
and apps, and Volume's label flashes only on change. Pill backgrounds
mean "clickable". One popup per module — no hub:
three hub concepts (card, side panel, expanding deck) were built and
retired; every control lives in its module's obvious place. Anything
needing keyboard input (wifi passwords) is a floating window with its own
qs instance, not a popup. All popups share `Popout.qml` (card chrome +
click-outside/Escape close) — never hand-roll popup chrome. Battery joins
the flat metrics on laptops. VPN state (vpn/wireguard/tun) shows as a
green shield on the network module; the network app can toggle saved VPN
profiles (NM-managed vpn/wireguard only — externally managed tunnels
like tailscale show the shield and a read-only "external" row, but no
toggle: nmcli can down them but never bring them back), and carries the
bluetooth manager (power, paired-device connect/disconnect, PIN-less
pairing via "pair new"; PIN pairing stays blueman's job) — the section
renders only when an adapter exists.

## Development notes

- New QML type → add to `qmldir` **and** fully restart (`scripts/bar
  restart`). Hot reload registers no new types and can leave stale handler
  trees running — never trust it for behavior changes.
- Debug: `scripts/bar log` · IPC surface: `scripts/bar ipc show`.

## Fallback

Bar dies the moment you click it: check `~/.icons/default/index.theme`
for a self-referential Inherits loop — nwg-look ≤1.0.2 (what trixie
ships) generates one applying a cursor theme, and libxcb-cursor
recurses forever resolving the click cursor (found by ddubs, Aug 2026;
fixed upstream in nwg-look 1.0.3, issue #90). Delete the file or fix
the chain.

Uncomment the polybar line in `autostart` and comment the qs line. If
quickshell misbehaves: `scripts/bar restart`.
