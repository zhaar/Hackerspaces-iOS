//
//  VCMapView.swift
//  Hackerspaces
//
//  Created by zephyz on 10/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import MapKit

extension MapViewController: MKMapViewDelegate {
    
    // 1
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(UIConstants.AnnotationViewReuseIdentifier)
        
        if view == nil {
            return nil
//            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: UIConstants.AnnotationViewReuseIdentifier)
//            view.canShowCallout = true
        } else {
            view.annotation = annotation
        }
        
        if let l = annotation as? SpaceLocation {
            if l.open {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
                label.text = UIConstants.SpaceIsOpenMark
                label.textColor = UIColor(red: 0, green: 255, blue: 0, alpha: 1)
                view.leftCalloutAccessoryView = label
            }
        }
        
        return view
    }
}