//
//  Note.swift
//  MilestoneProject7
//
//  Created by Iaroslav Denisenko on 27.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import Foundation

final class Note: NotesItem {
    
    var text: String
    
    enum CodingKeys: String, CodingKey {
        case text
    }
    
    init(title: String, text: String) {
        self.text = text
        super.init(title: title)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try super.encode(to: encoder)
    }
}
