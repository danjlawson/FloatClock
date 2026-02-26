# Bare-bones floating clock for macOS

My setup has auto-hide for menu bar and dock, so I use this clock to show the
current time in the top right corner.

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
        * Position on screen (always a corner, always 10px from the edge at present) 
