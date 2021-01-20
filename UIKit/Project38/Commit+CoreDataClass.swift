//
//  Commit+CoreDataClass.swift
//  Project38
//
//  Created by Iaroslav Denisenko on 04.01.2021.
//  Copyright © 2021 Iaroslav Denisenko. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Commit)
public class Commit: NSManagedObject {

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("Init called!")
    }
}
