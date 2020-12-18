//
//  ViewController.swift
//  MilestoneProject8
//
//  Created by Iaroslav Denisenko on 18.12.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet var testView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoacationManager()
        setupExtensions()
        testView.bounceOut(duration: 3)
    }
    
    func setupExtensions() {
        var numbers = [1, 2, 3, 4, 5, 1]
        numbers.countOddEven()
        numbers.remove(item: 1)
        print(numbers)
        let count = -5
        count.times {
            print("Hello!")
        }
    }

    func setupLoacationManager() {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.requestAlwaysAuthorization()
        lm.requestLocation()
        lm.startMonitoringVisits()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user location\(location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        if visit.departureDate == Date.distantFuture {
            print("User arrived at location \(visit.coordinate) at time \(visit.arrivalDate)")
        } else {
            print("User departed location \(visit.coordinate) at time \(visit.departureDate)")
        }
    }
}

