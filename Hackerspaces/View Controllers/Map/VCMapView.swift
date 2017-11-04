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

    let parsedData: ParsedHackerspaceData
    init(data: ParsedHackerspaceData) {
        self.parsedData = data
    }
}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? SpaceLocation else { return nil }
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: UIConstants.AnnotationViewReuseIdentifier.rawValue)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: UIConstants.AnnotationViewReuseIdentifier.rawValue)
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let SHVC = segue.destination as? SelectedHackerspaceTableViewController,
            let info = sender as? HSInfoCarrier {
            SHVC.prepare(info.parsedData)
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? SpaceLocation {
            self.performSegue(withIdentifier: UIConstants.showHSMap.rawValue, sender: HSInfoCarrier(data: annotation.hackerspace))
        }
    }
}
