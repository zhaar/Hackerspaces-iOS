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
    var refreshButton: UIBarButtonItem!
    var loadingIndicator: UIBarButtonItem!

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

    func refresh(sender: UIBarButtonItem) {
        self.navigationItem.rightBarButtonItem = loadingIndicator
        self.map.removeAnnotations(map.annotations)
        let _ = SpaceAPI.loadHackerspaceList(fromCache: true).map { hsList in
            hsList.map { name, url in
                SpaceAPI.getParsedHackerspace(url: url, name: name, fromCache: false)
                    .onSuccess { self.map.addAnnotation($0.location) }
                }
                .sequence()
                .onComplete { _ in
                    self.navigationItem.rightBarButtonItem = self.refreshButton
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(refresh))
        self.navigationItem.rightBarButtonItem = refreshButton
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.startAnimating()
        loadingIndicator = UIBarButtonItem(customView: indicator)
        refresh(sender: refreshButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
}

