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
    var toLocation: LocationObject {
        return LocationObject(latitude: Float(self.location.latitude),
                              longitude: Float(self.location.longitude),
                              address: self.address)
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
