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

extension Dictionary {
    func split<Key: Hashable, Val>(dict: [Key : Val], discriminationFunction: (Key, Val) -> Bool) -> ([Key: Val],[Key : Val]) {
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
    
}

extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}

extension Dictionary {
    func map<OutKey: Hashable, OutValue>(transform: Element -> (OutKey, OutValue)) -> [OutKey: OutValue] {
        return Dictionary<OutKey, OutValue>(Swift.map(self, transform))
    }
    
    func filter(includeElement: Element -> Bool) -> [Key: Value] {
        return Dictionary(Swift.filter(self, includeElement))
    }
}