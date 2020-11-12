//
//  Country.swift
//  MilestoneProject5
//
//  Created by Iaroslav Denisenko on 07.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import Foundation

struct Country: Codable {
    
    let name: String
    let capital: String
    let region: String
    let subregion: String
    let nativeName: String
    let population: Int
    let area: Double?
    let flag: String
    let callingCodes: [String]
    let languages: [Language]
    let currencies: [Currency]
    var generalProperties: [Any] {
        return [name, capital, region, subregion, nativeName, population, area ?? "no data"]
    }
    var allProperties: [[Any]] {
        return [generalProperties, [flag], callingCodes, languages, currencies]
    }
    
}

struct Language: Codable {
    let name: String
}

struct Currency: Codable {
    let code: String?
    let name: String?
    let symbol: String?
}

