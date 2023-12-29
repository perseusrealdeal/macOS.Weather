//
//  AppGlobals.swift
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 - 7532 Mikhail Zhigulin of Novosibirsk
//  Copyright © 7531 - 7532 PerseusRealDeal
//
//  The year starts from the creation of the world according to a Slavic calendar.
//  September, the 1st of Slavic year.
//
//  See LICENSE for details. All rights reserved.
//

import Cocoa

struct AppGlobals {

    // MARK: - Constants

    static let appKeyOpenWeather = "79eefe16f6e4714470502074369fc77b"

    static let statusMenusButtonIconName = "Icon"
    static let statusMenusButtonTitle = "Perseus"

    static var systemAppName: String? {

        var calculatedTitle: String?

        if #available(macOS 10.14, *) {
            calculatedTitle = "System Settings.app"
        } else {
            calculatedTitle = "System Preferences.app"
        }

        return calculatedTitle
    }

    // MARK: - System Services

    static let userDefaults = UserDefaults.standard
    static let notificationCenter = NotificationCenter.default

    static var appDelegate: AppDelegate? {
        return NSApplication.shared.delegate as? AppDelegate
    }

    static var workspace: NSWorkspace {
        return NSWorkspace.shared
    }

    static let openSystemApp = "x-apple.systempreferences:"

    // MARK: - Custom Services

    public let locationDealer: PerseusLocationDealer
    public let weatherClient: OpenWeatherFreeClient

    public let statusMenusButtonPresenter: StatusMenusButtonPresenter
    public let optionsPresenter: OptionsWindowController!
    public let aboutPresenter: AboutWindowController!

    public let languageSwitcher: LanguageSwitcher
    public let dataDefender: PerseusDataDefender

    init() {
        log.message("[AppGlobals].\(#function)")

        self.locationDealer = PerseusLocationDealer.shared
        self.weatherClient = OpenWeatherFreeClient()

        self.statusMenusButtonPresenter = StatusMenusButtonPresenter()

        self.optionsPresenter =
        OptionsWindowController.storyboardInstance() as? OptionsWindowController

        self.aboutPresenter =
        AboutWindowController.storyboardInstance()  as? AboutWindowController

        self.languageSwitcher = LanguageSwitcher.shared
        self.dataDefender = PerseusDataDefender.shared
    }

    static func openDefaultBrowser(string link: String) {

        log.message("[\(type(of: self))].\(#function)")

        guard let url = NSURL(string: link) as URL? else {
            log.message("[\(type(of: self))].\(#function)", .error)
            return
        }

        _ = workspace.open(url) ?
        log.message("[\(type(of: self))].\(#function) - Default browser was opened.") :
        log.message("[\(type(of: self))].\(#function) - Default browser wasn't opened.")
    }

    static func openTheApp(name: String?) {
        // One way to open System options app
        guard
            let theAppName = name,
            let pathURL = FileManager.default.urls(for: .applicationDirectory,
                                                   in: .systemDomainMask
                ).first?.appendingPathComponent(theAppName)
            else { return }

        // Another way to open System options app
        // guard let pathURL = URL(string: AppGlobals.openSystemApp) else { return }

        NSWorkspace.shared.open(pathURL)
    }

    static func quitTheApp() {
        app.terminate(appDelegate)
    }
}
