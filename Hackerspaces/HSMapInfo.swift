//
//  HackerspaceMapInfo.swift
//  Hackerspaces
//
//  Created by zephyz on 29/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import MapKit


class SpaceLocation : NSObject {
    let hackerspace: ParsedHackerspaceData
    let location: CLLocationCoordinate2D
    init(hackerspace: ParsedHackerspaceData) {
        self.hackerspace = hackerspace
        self.location = CLLocationCoordinate2D(latitude: CLLocationDegrees(hackerspace.location.lat), longitude: CLLocationDegrees(hackerspace.location.lon))
    }
}

extension SpaceLocation {
    var toLocation: LocationData {
        return LocationData(address: self.hackerspace.location.address,
                            lat: Float(self.location.latitude),
                            lon: Float(self.location.longitude))
    }
}

extension SpaceLocation : MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return self.location
    }
    var title: String? {
        return self.hackerspace.name
    }
    var subtitle: String? {
        return self.hackerspace.location.address
    }
}
