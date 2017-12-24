
//
//  HackerspaceMapTableViewCell.swift
//  Hackerspaces
//
//  Created by zephyz on 21/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit
import MapKit

class HackerspaceMapTableViewCell: UITableViewCell {

    @IBOutlet weak var map: MKMapView!
    var location: SpaceLocation? {
        didSet {
            if let l = location {
                map.addAnnotation(l)
                map.showAnnotations([l], animated: true)
            }
        }
    }
}
