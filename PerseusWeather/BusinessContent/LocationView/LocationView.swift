//
//  LocationView.swift, LocationView.xib
//  PerseusWeather
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

class LocationView: NSView, Localizable {

    private var permissionStatusLocalized: String {
        let permit = globals.locationDealer.locationPermit
        var statusLocalized: String = ""

        switch permit {
        case .notDetermined:
            statusLocalized = "notDetermined Location Status".localizedValue
        case .deniedForAllAndRestricted:
            statusLocalized = "deniedForAllAndRestricted Location Status".localizedValue
        case .restricted:
            statusLocalized = "restricted Location Status".localizedValue
        case .deniedForAllApps:
            statusLocalized = "deniedForAllApps Location Status".localizedValue
        case .deniedForTheApp:
            statusLocalized = "deniedForTheApp Location Status".localizedValue
        case .allowed:
            statusLocalized = "allowed Location Status".localizedValue
        }

        return statusLocalized
    }

    @IBOutlet weak var locationNameValueLabel: NSTextField!

    @IBOutlet weak var permissionLabel: NSTextField!
    @IBOutlet weak var permissionValueLabel: NSTextField!

    @IBOutlet weak var geoCoordinatesValueLabel: NSTextField!

    @IBOutlet weak var refreshButton: NSButton!

    @IBAction func refreshButtonTapped(_ sender: NSButton) {
        log.message("[\(type(of: self))].\(#function)")

        globals.locationDealer.askForAuthorization { permit in
            let text = "[\(type(of: self))].\(#function) — It's already determined .\(permit)"
            log.message(text, .error)
        }

        try? globals.locationDealer.askForCurrentLocation()
    }

    // MARK: - Native methods

    override func awakeFromNib() {
        log.message("[\(type(of: self))].\(#function)")

        let nc = AppGlobals.notificationCenter

        nc.addObserver(self, selector: #selector(self.localize),
                       name: NSNotification.Name.languageSwitchedManuallyNotification,
                       object: nil)

        nc.addObserver(self, selector: #selector(locationDealerCurrentHandler(_:)),
                       name: .locationDealerCurrentNotification,
                       object: nil
        )
    }

    override func viewWillDraw() {
        log.message("[\(type(of: self))].\(#function)")

        permissionValueLabel.stringValue = self.permissionStatusLocalized
    }

    @objc func localize() {
        log.message("[\(type(of: self))].\(#function)")

        locationNameValueLabel.stringValue = "Location Name Label".localizedValue

        permissionLabel.stringValue = "Permission".localizedValue + ":"
        permissionValueLabel.stringValue = self.permissionStatusLocalized

        geoCoordinatesValueLabel.stringValue = "Latitude, Longitude Label".localizedValue

        refreshButton.title = "RefreshButton".localizedValue
    }

    @objc private func locationDealerCurrentHandler(_ notification: Notification) {
        log.message("[\(type(of: self))].\(#function)")

        guard
            let result = notification.object as? Result<PerseusLocation, LocationDealerError>
            else { return }

        switch result {
        case .success(let data):
            AppGlobals.appDelegate?.location = data
        case .failure(let error):
            log.message("\(error)", .error)
        }
    }
}
