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


struct MKFunctions {
    static func spaceCoordinate(json: [String : JSONDecoder]) -> CLLocation? {
        let locationDict = json["location"]?.dictionary
        let lat = locationDict?["lat"]?.number >>- {CLLocationDegrees($0)}
        let lon = locationDict?["lon"]?.number >>- {CLLocationDegrees($0)}
        return lat >>- {la in lon >>- { lo in CLLocation(latitude: la, longitude: lo)}}
    }
    
    static func centerMapOnLocation(map: MKMapView, location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        map.setRegion(coordinateRegion, animated: true)
    }
}

func splitDict<Key, Val>(dict: [Key : Val], discriminationFunction: (Key, Val) -> Bool) -> ([Key: Val],[Key : Val]) {
    var target = [Key: Val]()
    var rest = [Key : Val]()
    for (k, v) in dict {
        if discriminationFunction(k,v) {
            target[k] = v
        } else {
            rest[k] = v
        }
    }
    return (target, rest)
}
