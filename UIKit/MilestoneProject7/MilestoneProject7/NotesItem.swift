//
//  NotesItem.swift
//  MilestoneProject7
//
//  Created by Iaroslav Denisenko on 27.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import Foundation

class NotesItem: Codable {
    var title: String
    
    init(title: String) {
        self.title = title
    }

    enum CodingKeys: String, CodingKey {
        case title
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
    }
    
}

