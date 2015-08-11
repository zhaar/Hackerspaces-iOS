//
//  MapArtwork.swift
//  Hackerspaces
//
//  Created by zephyz on 10/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import MapKit

class Artwork: NSObject, MKAnnotation {
    let title: String
    let spaceName: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, spaceName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.spaceName = spaceName
        self.coordinate = coordinate
        
        super.init()
    }
}