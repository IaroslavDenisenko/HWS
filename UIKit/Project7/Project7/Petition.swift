//
//  Petition.swift
//  Project7
//
//  Created by Iaroslav Denisenko on 04.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import Foundation

struct Petition: Codable {
    let title: String
    let body: String
    let signatureCount: Int
}
