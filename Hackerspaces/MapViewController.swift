//
//  SecondViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 05/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit
import Swiftz
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView! {
        didSet {
            map.delegate = self
        }
    }
    
    let locationManager = CLLocationManager()
    
    @IBAction func resetMap(_ sender: UILongPressGestureRecognizer) {
        if let location = locationManager.location {
            centerMapOnLocation(location)
        }
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            map.showsUserLocation = true
            map.userTrackingMode = MKUserTrackingMode.none
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let regionRadius: CLLocationDistance = 5000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SpaceAPI.getHackerspaceLocations().onSuccess { array in
            self.map.addAnnotations(array.flatMap(identity))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }

}

