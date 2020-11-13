//
//  Capital.swift
//  Project16
//
//  Created by Iaroslav Denisenko on 12.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {

    let title: String?
    let coordinate: CLLocationCoordinate2D
    let info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
