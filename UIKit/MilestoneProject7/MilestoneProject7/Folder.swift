//
//  Folder.swift
//  MilestoneProject7
//
//  Created by Iaroslav Denisenko on 27.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import Foundation

final class Folder: NotesItem {
    
    var items = [NotesItem]()
    var id = UUID().uuidString
    
    enum CodingKeys: String, CodingKey {
        case items
        case id
    }

    override init(title: String) {
        super.init(title: title)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.items = try container.decode([NotesItem].self, forKey:.items)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(items, forKey: .items)
        try super.encode(to: encoder)
    }
}
