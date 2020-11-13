    //
//  ViewController.swift
//  Project16
//
//  Created by Iaroslav Denisenko on 12.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
        
    @IBOutlet var mapView: MKMapView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCapitals()
        title = "World's map"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(changeMapType))
    }
    
    func setupCapitals() {
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        mapView.addAnnotations([london, oslo, paris, rome, washington])
    }
    
    @objc func changeMapType() {
        let ac = UIAlertController(title: "Select map type", message: nil, preferredStyle: .actionSheet)
        let mapTypes: [String:MKMapType] = [
            "Standard" : .standard,
            "MutedStandard" : .mutedStandard,
            "Satellite" : .satellite,
            "SatelliteFlyover" : .satelliteFlyover,
            "Hybrid" : .hybrid,
            "HybridFlyover" : .hybridFlyover
        ]
        for element in mapTypes {
            ac.addAction(UIAlertAction(title: element.key, style: .default, handler: { [weak self] _ in
                self?.mapView.mapType = element.value
            }))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else { return nil }
        let identifier = "Capital"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
            if let annotationView = annotationView as? MKPinAnnotationView {
                annotationView.pinTintColor = UIColor.green
            }
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        let wikiVC = WikipediaViewController()
        wikiVC.capital = capital.title
        navigationController?.pushViewController(wikiVC, animated: true)
    }
    
}

