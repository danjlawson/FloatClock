# Bare-bones floating clock for macOS

My setup has auto-hide for menu bar and dock, so I use this clock to show the
current time in the top right corner.

Unlike the original repo its forked from, this version has:
1) A menubar icon that allows you to quit and access settings,
2) Settings for size, position, color and (e.g. semi-transparant) background.

This allows you to make the clock small enough to avoid clashing with icons on window decorations, and always visible regardless of light or dark background.

Screenshot:

![screenshot](screenshot.png)

## Build instructions

Requires Swift

Build: `make all`

Clean: `make clean`

Install: `make install`

Add to login items: Settings->Login Items & Extensions

- under "Opens at Login" click + and select `$HOME/Applications/FloatClock.app` exactly as for any other OSX app.

Uninstall: `make uninstall`

## Customisation notes

The menubar icon contains options to:

* Hide the clock temporarily
* Quit
* Update the settings:
        * Font size
        * Text Color
        * Position on screen (always a corner, configurable distance from that corner)


## Known issues:

* Resizing occasionally chops a character off, but tweaking the size bar returns it.
* Not as many configuration options as would be desirable (y axis offset, choice of font, AM/PM label, etc).
