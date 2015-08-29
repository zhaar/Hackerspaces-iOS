//
//  hackerspaceDataFunctions.swift
//  Hackerspaces
//
//  Created by zephyz on 22/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import MapKit
import JSONJoy
import Swiftz
import BrightFutures


struct MKFunctions {
    
    static func centerMapOnLocation(map: MKMapView, location: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
            regionRadius * 2.0, regionRadius * 2.0)
        map.setRegion(coordinateRegion, animated: true)
    }
}