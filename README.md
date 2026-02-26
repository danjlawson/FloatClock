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

Add to login items: `make register`

Remove from login items: `make unregister`

Uninstall: `make uninstall`

## Customisation notes

To make changes to the clock text color, edit [FloatClock.swift](FloatClock.swift) the line:

```{swift}
        label.textColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1 - 1 / 8)
```

To change the font size:

```{swift}
             let font = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
```

To change the size and position of the container, from the top right of the screen:

```{swift}
        let width: CGFloat = 60
        let height: CGFloat = 12
```
