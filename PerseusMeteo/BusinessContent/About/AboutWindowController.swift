//
//  AboutWindowController.swift, AboutWindowController.storyboard
//  PerseusMeteo
//
//  Created by Mikhail Zhigulin in 7532.
//
//  Copyright © 7532 Mikhail Zhigulin of Novosibirsk
//  Copyright © 7532 PerseusRealDeal
//
//  The year starts from the creation of the world according to a Slavic calendar.
//  September, the 1st of Slavic year.
//
//  See LICENSE for details. All rights reserved.
//

import Cocoa

public class AboutWindowController: NSWindowController {

    // MARK: - Internals

    private var alwaysOnTop: Any?
    private let darkModeObserver = DarkModeObserver()

    // MARK: - Initialization

    public override func awakeFromNib() {
        super.awakeFromNib()

        log.message("[\(type(of: self))].\(#function)")

        let nc = AppGlobals.notificationCenter

        // Always on top.

        let notification = NSApplication.didResignActiveNotification
        let queue = OperationQueue.main

        alwaysOnTop = nc.addObserver(forName: notification,
                                     object: nil,
                                     queue: queue) { _ in self.window?.level = .floating }

        // Dark Mode.

        darkModeObserver.action = { _ in self.makeup() }

        // Localization.

        nc.addObserver(self, selector: #selector(self.localize),
                       name: NSNotification.Name.languageSwitchedManuallyNotification,
                       object: nil)

        // Apperance.

        makeup()
        localize()
    }

    public override func windowDidLoad() {
        super.windowDidLoad()

        log.message("[\(type(of: self))].\(#function)")

        // No title for the app screen.
        self.window?.title = ""
    }

    // MARK: - Other methods

    func windowShouldClose(_ sender: NSWindow) -> Bool {

        log.message("[\(type(of: self))].\(#function)")

        self.window?.orderOut(sender)
        return false
    }
}

// MARK: - STORYBOARD INSTANCE

extension AboutWindowController {

    class func storyboardInstance() -> AboutWindowController {

        log.message("[\(type(of: self))].\(#function)")

        let sb = NSStoryboard(name: String(describing: self), bundle: nil)

        guard
            let screen = sb.instantiateInitialController() as? AboutWindowController
        else {

            let text = "[\(type(of: self))].\(#function)"

            log.message(text, .error)
            fatalError(text)
        }

        // Do default setup; don't set any parameter causing loadWindow up, breaks unit tests.

        return screen
    }
}

// MARK: - DARK MODE

extension AboutWindowController {

    public func makeup() {

        guard
            let screen = self.contentViewController as? AboutViewController
        else {
            return
        }

        screen.makeup()
    }
}

// MARK: - LOCALIZATION

extension AboutWindowController: Localizable {

    @objc func localize() {

        guard
            let screen = self.contentViewController as? AboutViewController
        else {
            return
        }

        screen.localize()
    }
}
