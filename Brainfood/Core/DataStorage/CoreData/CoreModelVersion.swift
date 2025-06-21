//
//  CoreModelVersion.swift
//  DoorDash
//
//  Created by Marvin Zhan on 2018-03-20.
//  Copyright © 2018 Monster. All rights reserved.
//

import CoreData

public enum CoreModelVersion: String {
    case version1 = "DoorDash"
}

extension CoreModelVersion {
    static var current: CoreModelVersion = .version1

    var name: String {
        return rawValue
    }

    var modelDirectoryName: String {
        return "DoorDash.momd"
    }

    func managedObjectModel() -> NSManagedObjectModel {
        guard let modelURL = ApplicationEnvironment.current.mainBundle.url(forResource: name, withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing ManagedObjectModel from : \(modelURL)")
        }
        return managedObjectModel
    }
}

