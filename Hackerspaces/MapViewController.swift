//
//  SecondViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 05/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit
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
    
    @IBAction func resetMap(sender: UILongPressGestureRecognizer) {
        if let location = locationManager.location {
            centerMapOnLocation(location)
        }
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            map.showsUserLocation = true
            map.userTrackingMode = MKUserTrackingMode.None
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 5000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        map.setRegion(coordinateRegion, animated: true)
    }
        
    func refresh(sender: UIBarButtonItem) {
        self.navigationItem.rightBarButtonItem = loadingIndicator
        self.map.removeAnnotations(map.annotations)
        SpaceAPI.loadHackerspaceList(fromCache: true).map { hsList in
            hsList.map { name, url in
                SpaceAPI.getParsedHackerspace(url, name: name, fromCache: false).onSuccess { parsed in
                    self.map.addAnnotation(parsed.location)}
                }.sequence().onComplete { _ in
                    self.navigationItem.rightBarButtonItem = self.refreshButton
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(refresh))
        self.navigationItem.rightBarButtonItem = refreshButton
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        indicator.startAnimating()
        loadingIndicator = UIBarButtonItem(customView: indicator)
        refresh(refreshButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }

}

