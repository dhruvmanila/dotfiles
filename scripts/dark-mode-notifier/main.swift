import Cocoa

@discardableResult
func shell(_ cmd: String, args: String...) -> Int32 {
    let task = Process()
    task.launchPath = cmd
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

func updateKittyTheme() {
    let kittyApps = NSRunningApplication.runningApplications(withBundleIdentifier: "net.kovidgoyal.kitty")
    if kittyApps.count > 0 {
        let isDark = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
        print("Notifying Kitty that macOS Dark Mode is:", isDark)
        shell("/usr/local/bin/kitty", args: "+kitten", "themes", "--reload-in=all", isDark ? "Gruvbox Dark" : "Gruvbox Light")
    }
}

updateKittyTheme()

DistributedNotificationCenter.default.addObserver(
    forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
    object: nil,
    queue: nil
) { (notification) in updateKittyTheme() }

// Enter cocoa run loop and start listening for notifyd events
NSApplication.shared.run()
