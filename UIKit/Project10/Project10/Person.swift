//
//  Person.swift
//  Project10
//
//  Created by Iaroslav Denisenko on 19.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class Person: NSObject, Codable {

    var name: String
    var image: String
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
