// The MIT License

// Copyright (c) 2018 Daniel
// Copyright (c) 2023 Roman Dubtsov
// Copyright (c) 2026 Daniel Lawson Github: @danjlawson

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// see README.md for usage instructions

import Cocoa

func calcWindowPosition(windowSize: CGSize, screenSize: CGSize) -> CGPoint {

    let position = UserDefaults.standard.integer(forKey: "position")
    let xoffset = CGFloat(UserDefaults.standard.double(forKey: "xoffset"))
    let yoffset = CGFloat(UserDefaults.standard.double(forKey: "yoffset"))

    switch position {
    case 1: // Top Left
        return CGPoint(x: xoffset,
                       y: screenSize.height - windowSize.height - yoffset)

    case 2: // Bottom Right
        return CGPoint(x: screenSize.width - windowSize.width - xoffset,
                       y: 0)

    case 3: // Bottom Left
        return CGPoint(x: xoffset,
                       y: yoffset)

    default: // Top Right
        return CGPoint(x: screenSize.width - windowSize.width - xoffset,
                       y: screenSize.height - windowSize.height - yoffset)
    }
}

class Clock: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusItem: NSStatusItem!
    var settingsWindow: NSWindow!

    var timeLabel: NSTextField!

    func initSettingsWindow() {
        
        let width: CGFloat = 300
        let height: CGFloat = 340
        
        settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: width, height: height),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
                             )
        
        settingsWindow.title = "Clock Settings"
        settingsWindow.center()
        settingsWindow.isReleasedWhenClosed = false
        
        let content = NSView(frame: settingsWindow.contentRect(forFrameRect: settingsWindow.frame))
        settingsWindow.contentView = content
        
        buildSettingsUI(in: content)
    }
    
    func updateWindowPosition() {
        if let screen = window.screen {
            let pos = calcWindowPosition(windowSize: self.window.frame.size,
                                         screenSize: screen.frame.size)
            window.setFrameOrigin(pos)
        }
    }

    func initStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem.button else { return }
        
        button.image = NSImage(
                systemSymbolName: "clock",
                accessibilityDescription: "Clock"
                           )
        button.image?.isTemplate = true
        
        let menu = NSMenu()
        
        let toggleItem = NSMenuItem(
                title: "Show / Hide Clock",
                action: #selector(toggleWindow),
                keyEquivalent: ""
                             )
        toggleItem.target = self
        menu.addItem(toggleItem)

        let settingsItem = NSMenuItem(
                title: "Settings…",
                action: #selector(openSettings),
                keyEquivalent: ","
                               )
        settingsItem.target = self
        menu.insertItem(settingsItem, at: 0)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(
                title: "Quit",
                action: #selector(quitApp),
                keyEquivalent: "q"
                           )
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }

    @objc func openSettings() {
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func toggleWindow() {
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.orderFrontRegardless()
            updateWindowPosition()
        }
    }

    func buildSettingsUI(in view: NSView) {

        let defaults = UserDefaults.standard

        // Padding slider
        let paddingLabel = NSTextField(labelWithString: "X Padding")
        paddingLabel.frame = NSRect(x: 20, y: 210, width: 100, height: 20)
        view.addSubview(paddingLabel)
        let paddingSlider = NSSlider(value: defaults.double(forKey: "padding"),
                             minValue: 0,
                             maxValue: 30,
                             target: self,
                             action: #selector(paddingChanged(_:)))
        paddingSlider.frame = NSRect(x: 120, y: 210, width: 150, height: 20)
        view.addSubview(paddingSlider)


        // FONT SIZE
        let fontLabel = NSTextField(labelWithString: "Font Size")
        fontLabel.frame = NSRect(x: 20, y: 170, width: 100, height: 20)
        view.addSubview(fontLabel)

        let fontSlider = NSSlider(
            value: defaults.double(forKey: "fontSize"),
            minValue: 8,
            maxValue: 48,
            target: self,
            action: #selector(fontSizeChanged)
        )
        fontSlider.frame = NSRect(x: 120, y: 170, width: 150, height: 20)
        view.addSubview(fontSlider)

        // BACKGROUND COLOR
        let bgcolorLabel = NSTextField(labelWithString: "Background Color")
        bgcolorLabel.frame = NSRect(x: 20, y: 130, width: 100, height: 20)
        view.addSubview(bgcolorLabel)

        let savedbgColor = loadBackgroundColor()

        let bgcolorWell = NSColorWell(frame: NSRect(x: 120, y: 125, width: 50, height: 30))
        bgcolorWell.target = self
        bgcolorWell.action = #selector(bgcolorChanged)
        bgcolorWell.color = savedbgColor
        view.addSubview(bgcolorWell)

        // TEXT COLOR
        let colorLabel = NSTextField(labelWithString: "Text Color")
        colorLabel.frame = NSRect(x: 20, y: 90, width: 100, height: 20)
        view.addSubview(colorLabel)

        let savedColor = loadLabelColor()

        let colorWell = NSColorWell(frame: NSRect(x: 120, y: 85, width: 50, height: 30))
        colorWell.target = self
        colorWell.action = #selector(colorChanged)
        colorWell.color = savedColor
        view.addSubview(colorWell)

        // POSITION
        let positionLabel = NSTextField(labelWithString: "Position")
        positionLabel.frame = NSRect(x: 20, y: 50, width: 100, height: 20)
        view.addSubview(positionLabel)

        let positionPopup = NSPopUpButton(frame: NSRect(x: 120, y: 50, width: 150, height: 25))
        positionPopup.addItems(withTitles: [
            "Top Right",
            "Top Left",
            "Bottom Right",
            "Bottom Left"
        ])
        positionPopup.selectItem(at: defaults.integer(forKey: "position"))
        positionPopup.target = self
        positionPopup.action = #selector(positionChanged)
        view.addSubview(positionPopup)

    }

    
    @objc func quitApp() {
        // Clean up if needed
        NSApplication.shared.terminate(nil)
    }

    @objc func fontSizeChanged(_ sender: NSSlider) {
        let size = sender.doubleValue
        UserDefaults.standard.set(size, forKey: "fontSize")

        timeLabel.font = NSFont.monospacedDigitSystemFont(ofSize: CGFloat(size), weight: .regular)

        resizeWindowToFitText()
    } 

    @objc func bgcolorChanged(_ sender: NSColorWell) {

        let bgcolor = sender.color
        window.backgroundColor = bgcolor

        let data = try! NSKeyedArchiver.archivedData(
            withRootObject: bgcolor,
            requiringSecureCoding: false
        )

        UserDefaults.standard.set(data, forKey: "bgcolor")
        updateBackgroundAppearance()
    }
    
    
    @objc func colorChanged(_ sender: NSColorWell) {

        let color = sender.color
        timeLabel.textColor = color

        let data = try! NSKeyedArchiver.archivedData(
            withRootObject: color,
            requiringSecureCoding: false
        )

        UserDefaults.standard.set(data, forKey: "color")
    }

    @objc func paddingChanged(_ sender: NSSlider) {
        UserDefaults.standard.set(sender.doubleValue, forKey: "padding")
        resizeWindowToFitText()
    }

    @objc func xoffsetChanged(_ sender: NSSlider) {
        UserDefaults.standard.set(sender.doubleValue, forKey: "xoffset")
        updateWindowPosition()
    }

    @objc func yoffsetChanged(_ sender: NSSlider) {
        UserDefaults.standard.set(sender.doubleValue, forKey: "yoffset")
        updateWindowPosition()
    }

    func updateBackgroundAppearance() {
        // 

        guard let container = window.contentView else { return }

        let color = loadBackgroundColor()
        container.layer?.backgroundColor = color.cgColor
    }   
    
    func registerDefaults() {

        let defaultColor = NSColor(
            red: 0.6,
            green: 0.6,
            blue: 0.6,
            alpha: 1 - 1 / 8
        )

        let colorData = try! NSKeyedArchiver.archivedData(
            withRootObject: defaultColor,
            requiringSecureCoding: false
        )

        let defaultbgColor = NSColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 0
        )

        let bgcolorData = try! NSKeyedArchiver.archivedData(
            withRootObject: defaultbgColor,
            requiringSecureCoding: false
        )

        UserDefaults.standard.register(defaults: [
            "padding": 0.0,
            "xoffset": 10.0,
            "yoffset": 0.0,
            "fontSize": 12.0,
            "position": 0,
            "bgcolor": bgcolorData,
            "color": colorData
        ])
    }
    
    @objc func positionChanged(_ sender: NSPopUpButton) {
        // Save the new position to UserDefaults
        UserDefaults.standard.set(sender.indexOfSelectedItem, forKey: "position")
        updateWindowPosition()
    }
    
    func applySavedSettings() {
        // Apply saved settings to the time label and window. This includes font size, transparency, color, and position.

//        guard let timeLabel = timeLabel,
//            let window = window else { return }

        let defaults = UserDefaults.standard

        // Font
        let size = defaults.double(forKey: "fontSize")
        timeLabel.font = NSFont.monospacedDigitSystemFont(
            ofSize: CGFloat(size),
            weight: .regular
        )

        // Color
        if let colorData = defaults.data(forKey: "color"),
        let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) {
            timeLabel.textColor = color
        } 

        // Background Color
        updateBackgroundAppearance()

        resizeWindowToFitText()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set up settings and UI
        registerDefaults()
        
        self.initTimeDisplay()
        self.initStatusBar()
        initSettingsWindow()
        applySavedSettings()
        // implement any settings
        resizeWindowToFitText()
        updateWindowPosition()

        // Listen for screen changes to update window position
        NotificationCenter.default.addObserver(
                                      forName: NSApplication.didChangeScreenParametersNotification,
                                      object: NSApplication.shared,
                                      queue: OperationQueue.main
                                  ) {
                                      //notification -> Void in
                                      _ in 
                                      self.updateWindowPosition()
                                  }
    }
    
    func initLabel(font: NSFont, format: String, interval: TimeInterval) -> NSTextField {
        // We use a DateFormatter to format the time string according to the specified format.
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        let label = NSTextField()
        label.font = font
        label.isBezeled = false
        label.isEditable = false
        label.drawsBackground = false
        label.alignment = .center
        label.textColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1 - 1 / 8)

        let shadow = NSShadow()
        shadow.shadowColor = NSColor(red: 0, green: 0, blue: 0, alpha: 1)
        shadow.shadowOffset = NSMakeSize(0, 0)
        shadow.shadowBlurRadius = 1
        label.shadow = shadow

        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            label.stringValue = formatter.string(from: Date())
        }
        timer.tolerance = interval / 10
        timer.fire()

        return label
    }

    func initWindow(size: CGSize, label: NSTextField) -> NSWindow {
        // Calculate the initial position of the window based on the saved position setting and the screen size.
        let pos = calcWindowPosition(windowSize: size,
                                     screenSize: NSScreen.main!.frame.size)
        let rect = NSMakeRect(pos.x, pos.y, size.width, size.height)
        let window = NSWindow(
            contentRect: rect,
            styleMask: .borderless,
            backing: .buffered,
            defer: true

        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor

        // Container view
        let container = NSView(frame: rect)
        container.wantsLayer = true
        container.layer?.cornerRadius = 8
        container.layer?.masksToBounds = true
        container.layer?.borderWidth = 0
        
        // Apply background colour here
        let bgColor = loadBackgroundColor()
        container.layer?.backgroundColor = bgColor.cgColor
        
        // Center label inside container
        label.frame = container.bounds
        label.autoresizingMask = [.width, .height]
        label.sizeToFit()
        container.addSubview(label)

        window.contentView = container
        window.ignoresMouseEvents = true
        window.level = .floating
        window.collectionBehavior = .canJoinAllSpaces
        window.orderFrontRegardless()

        return window
    }

    func loadLabelColor() -> NSColor {
        // 
        let defaults = UserDefaults.standard

        if let colorData = defaults.data(forKey: "color"),
        let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) {
            return color
        } 
        return NSColor.white.withAlphaComponent(CGFloat(1))
    }

    func loadBackgroundColor() -> NSColor {
        // 
        let defaults = UserDefaults.standard

        if let bgcolorData = defaults.data(forKey: "bgcolor"),
        let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: bgcolorData) {
            return color
        } 
        return NSColor.black.withAlphaComponent(CGFloat(0))
    }

    func resizeWindowToFitText() {

        guard let label = timeLabel,
            let window = window,
            let container = window.contentView else { return }

        label.sizeToFit()

        let padding = CGFloat(UserDefaults.standard.double(forKey: "padding"))

        let newWidth = label.frame.width + padding * 2
        let newHeight = label.frame.height 

        // Resize window
        var frame = window.frame
        frame.size = CGSize(width: newWidth, height: newHeight)
        window.setFrame(frame, display: true)

        // Resize container
        container.frame = NSRect(x: 0, y: 0,
                                width: newWidth,
                                height: newHeight)

        // Center label inside container
        label.frame = NSRect(
            x: padding,
            y: 0,
            width: label.frame.width,
            height: label.frame.height
        )

        updateWindowPosition()
    }

    func initTimeDisplay() {
        // We create a monospaced font for the time display to ensure consistent character spacing, which helps prevent the window from resizing as the time changes.
        let font = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
        let label = self.initLabel(
            font: font,
            format: "hh:mm",
            interval: 1
                    )
        self.timeLabel = label

        let width: CGFloat = 60 //* UserDefaults.standard.string(forKey: "fontSize")!.doubleValue / 12.0
        let height: CGFloat = 12 //* UserDefaults.standard.string(forKey: "fontSize")!.doubleValue / 12.0

        self.window = self.initWindow(
            size: CGSizeMake(width, height),
            label: label
        )
    }
}

let clock = Clock()

let app = NSApplication.shared
app.delegate = clock
app.run()
