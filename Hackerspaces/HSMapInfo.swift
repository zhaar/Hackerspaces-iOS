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
    let name: String
    let address: String?
    let location: CLLocationCoordinate2D
    init(name: String, address: String?, location: CLLocationCoordinate2D) {
        self.name = name
        self.location = location
        self.address = address
    }
}

extension SpaceLocation {
    var toLocation: LocationData {
        return LocationData(address: self.address,
                            lat: Float(self.location.latitude),
                            lon: Float(self.location.longitude))
    }
}

extension SpaceLocation : MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return self.location
    }
    var title: String? {
        return self.name
    }
    var subtitle: String? {
        return self.address
    }
}
