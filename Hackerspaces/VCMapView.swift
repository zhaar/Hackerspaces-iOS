//
//  VCMapView.swift
//  Hackerspaces
//
//  Created by zephyz on 10/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import MapKit

class HSInfoCarrier: NSObject {
    let hsName: String
    let hsAPI: String
    init(name: String, url: String) {
        self.hsName = name
        self.hsAPI = url
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? SpaceLocation {
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(UIConstants.AnnotationViewReuseIdentifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: UIConstants.AnnotationViewReuseIdentifier)
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            }
            return view
        }
        return nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let SHVC = segue.destinationViewController as? SelectedHackerspaceTableViewController {
            let info = sender as! HSInfoCarrier
            SHVC.prepare(info.hsName, url: info.hsAPI)
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? SpaceLocation {
            SpaceAPI.loadAPI().onSuccess { dict in
                self.performSegueWithIdentifier(UIConstants.showHSMap, sender: HSInfoCarrier(name: annotation.name, url: dict[annotation.name]!))
            }
        }
    }
}