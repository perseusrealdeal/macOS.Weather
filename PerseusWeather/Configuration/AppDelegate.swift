//
//  AppDelegate.swift
//  PerseusWeather
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 Mikhail Zhigulin of Novosibirsk.
//  Copyright © PerseusRealDeal.
//
//  Licensed under the special license. See LICENSE file.
//  All rights reserved.
//

import Cocoa
import CoreLocation

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        log.message("Launching with business matter purpose", .info)
        log.message("[\(type(of: self))].\(#function)")

        AppearanceService.makeUp()
        addAbservers()

        let dealer = PerseusLocationDealer.shared
        dealer.askForCurrentLocation { permit in log.message("\(permit)") }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    private func addAbservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(locationDealerCurrentHandler(_:)),
            name: .locationDealerCurrentNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(locationDealerUpdatesHandler(_:)),
            name: .locationDealerUpdatesNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(locationDealerErrorHandler(_:)),
            name: .locationDealerErrorNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(locationDealerStatusChangedHandler(_:)),
            name: .locationDealerStatusChangedNotification,
            object: nil
        )
    }

    @objc private func locationDealerCurrentHandler(_ notification: Notification) {
        log.message("[\(type(of: self))].\(#function)")
        guard let result = notification.object as? Result<CLLocation, LocationDealerError>
            else { return }

        switch result {
        case .success(let data):
            log.message("\(data)")
        case .failure(let error):
            log.message("\(error)", .error)
        }
    }

    @objc private func locationDealerUpdatesHandler(_ notification: Notification) {
        log.message("[\(type(of: self))].\(#function)")
    }

    @objc private func locationDealerErrorHandler(_ notification: Notification) {
        log.message("[\(type(of: self))].\(#function)")

        guard let result = notification.object as? LocationDealerError else { return }
        log.message("\(result)", .error)
    }

    @objc private func locationDealerStatusChangedHandler(_ notification: Notification) {
        log.message("[\(type(of: self))].\(#function)")
    }
}
