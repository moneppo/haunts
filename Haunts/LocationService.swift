//
//  LocationService.swift
//  Haunts
//
//  Created by Michael Oneppo on 4/2/15.
//  Copyright (c) 2015 moneppo. All rights reserved.
//

import Foundation
import CoreLocation

private var _manager = CLLocationManager()
private var _running = false

class LocationService {
    class func start() {
        if !_running {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                _manager.requestWhenInUseAuthorization()
            }
            _manager.startMonitoringSignificantLocationChanges()
            _running = true
        }
    }

    class func stop() {
        if _running {
            _manager.stopMonitoringSignificantLocationChanges()
            _running = false
        }
    }

    class func getLocationString() -> String {
        if let loc = _manager.location {
            let coord = loc.coordinate
            return String(format: "%3.2f-%3.2f", coord.latitude, coord.longitude)
        } else {
            return "nowhere"
        }
    }
}



