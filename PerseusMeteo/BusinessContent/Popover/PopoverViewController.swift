//
//  PopoverViewController.swift, PopoverViewController.storyboard
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
//  Special thanks for the macos-status-bar-apps tutorial goes to Gabriel Theodoropoulos.
//  https://www.appcoda.com/macos-status-bar-apps/
//
//  Special thanks for the SwiftCustomControl sample goes to Bill Waggoner.
//  https://github.com/ctgreybeard/SwiftCustomControl
//
// swiftlint:disable file_length
//

import Cocoa

public class PopoverViewController: NSViewController {

    // MARK: - Internals

    private let darkModeObserver = DarkModeObserver()
    private let meteoFactsSource = MeteoDataParser()

    // MARK: - Outlets

    @IBOutlet private(set) weak var viewLocation: LocationView!
    @IBOutlet private(set) weak var viewCurrentWeather: WeatherView!
    @IBOutlet private(set) weak var viewForecast: ForecastView!

    @IBOutlet private(set) weak var buttonFetchMeteoFacts: NSButton!
    @IBOutlet private(set) weak var progressIndicator: NSProgressIndicator!
    @IBOutlet private(set) weak var labelMadeWithLove: NSTextField!

    @IBOutlet private(set) weak var viewTabs: NSTabView!
    @IBOutlet private(set) weak var tabCurrentWeather: NSTabViewItem!
    @IBOutlet private(set) weak var tabForecast: NSTabViewItem!

    @IBOutlet private(set) weak var buttonQuit: NSButton!
    @IBOutlet private(set) weak var buttonAbout: NSButton!
    @IBOutlet private(set) weak var buttonOptions: NSButton!
    @IBOutlet private(set) weak var buttonHideAppScreens: NSButton!

    // MARK: - Actions

    @IBAction func fetchMeteoFactsButtonTapped(_ sender: NSButton) {

        log.message("[\(type(of: self))].\(#function)")

        globals.statusMenusButtonPresenter.callWeather(sender)
    }

    @IBAction func quitButtonTapped(_ sender: NSButton) {

        log.message("[\(type(of: self))].\(#function)")

        // AppOptions.removeAll()
        AppGlobals.quitTheApp()
    }

    @IBAction func aboutButtonTapped(_ sender: NSButton) {

        log.message("[\(type(of: self))].\(#function)")

        globals.statusMenusButtonPresenter.screenAbout.showWindow(sender)
    }

    @IBAction func optionsButtonTapped(_ sender: NSButton) {

        log.message("[\(type(of: self))].\(#function)")

        globals.statusMenusButtonPresenter.screenOptions.showWindow(sender)
    }

    @IBAction func hideAppScreensButtonTapped(_ sender: NSButton) {

        log.message("[\(type(of: self))].\(#function)")

        guard let popover = globals.statusMenusButtonPresenter.popover else { return }

        globals.statusMenusButtonPresenter.screenAbout.close()
        globals.statusMenusButtonPresenter.screenOptions.close()

        popover.performClose(sender)
    }

    // MARK: - Initialization

    public override func awakeFromNib() {
        super.awakeFromNib()

        log.message("[\(type(of: self))].\(#function)")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        log.message("[\(type(of: self))].\(#function)")

        // Setup content size.

        self.view.wantsLayer = true
        self.preferredContentSize = NSSize(width: self.view.frame.size.width,
                                           height: self.view.frame.size.height)

        // Dark Mode.

        darkModeObserver.action = { _ in self.makeup() }

        // Localization.

        let nc = AppGlobals.notificationCenter

        nc.addObserver(self, selector: #selector(localize),
                       name: NSNotification.Name.languageSwitchedManuallyNotification,
                       object: nil)

        // Meteo data.

        nc.addObserver(self, selector: #selector(reloadData),
                       name: NSNotification.Name.meteoDataOptionsDidChanged,
                       object: nil)

        // Data source.

        meteoFactsSource.path = { AppGlobals.appDelegate?.weather ?? Data() }
        viewCurrentWeather.data = meteoFactsSource

        // Appearance.

        makeup()
        localize()

        stopAnimationProgressIndicator(self)
    }

    // MARK: - Contract

    @objc public func reloadData() {

        guard
            let weather = self.viewCurrentWeather
        else {
            return
        }

        weather.reloadData()
        labelMadeWithLove.stringValue = meteoFactsSource.lastOne
    }

    public func startAnimationProgressIndicator(_ sender: Any?) {
        self.progressIndicator.isHidden = false
        self.progressIndicator.startAnimation(sender)
    }

    public func stopAnimationProgressIndicator(_ sender: Any?) {
        self.progressIndicator.isHidden = true
        self.progressIndicator.stopAnimation(sender)
    }
}

// MARK: - STORYBOARD INSTANCE

extension PopoverViewController {

    public class func storyboardInstance() -> PopoverViewController {

        log.message("[\(type(of: self))].\(#function)")

        let sb = NSStoryboard(name: String(describing: self), bundle: nil)

        guard
            let screen = sb.instantiateInitialController() as? PopoverViewController
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

extension PopoverViewController {

    private func makeup() {

        log.message("[\(type(of: self))].\(#function), DarkMode: \(DarkMode.style)")

        // Subviews.

        viewLocation?.makeup()
        viewCurrentWeather?.makeup()
        viewForecast?.makeup()

        // Make the appearance up.

        let appearance = DarkMode.style == .light ?
        NSAppearance(named: .aqua) : NSAppearance(named: .vibrantDark)

        globals.statusMenusButtonPresenter.popover?.appearance = appearance
        view.appearance = appearance

        guard #available(macOS 10.14, *) else {
            viewTabs.appearance = NSAppearance(named: .aqua)
            return
        }

        // view.layer?.backgroundColor = NSColor.perseusBlue.cgColor
    }
}

// MARK: - LOCALIZATION

extension PopoverViewController: Localizable {

    @objc func localize() {

        log.message("[\(type(of: self))].\(#function)")

        // Subviews.

        viewLocation?.localize()
        viewCurrentWeather?.localize()
        viewForecast?.localize()

        // Buttons and labels.

        buttonFetchMeteoFacts.title = "Button: Call Weather".localizedValue
        labelMadeWithLove.stringValue = meteoFactsSource.lastOne

        tabCurrentWeather.label = "Tab: Current Weather".localizedValue
        tabForecast.label = "Tab: Forecast".localizedValue

        buttonQuit.title = "Button: Quit".localizedValue

        buttonAbout.title = "Button: About".localizedValue
        buttonOptions.title = "Button: Options".localizedValue

        buttonHideAppScreens.title = "Button: Hide".localizedValue
    }
}
