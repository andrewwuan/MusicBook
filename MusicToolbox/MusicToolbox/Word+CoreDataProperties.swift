//
//  Word+CoreDataProperties.swift
//  MusicBook
//
//  Created by An Wu on 4/10/16.
//  Copyright © 2016 An Wu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Word {

    @NSManaged var spelling: String?
    @NSManaged var explanations: NSOrderedSet?

}
