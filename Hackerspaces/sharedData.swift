//
//  sharedData.swift
//  Hackerspaces
//
//  Created by zephyz on 29/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation

let favoriteKey = "favorite"

class Model {
    let defaults = NSUserDefaults.standardUserDefaults()
    var favoriteHackerspaceURL: String? {
        set {
            println("setting new value for prefered hackerspace")
            defaults.setObject(newValue!, forKey: favoriteKey)
        }
        get {
            println("fetching favorite hackerspace")
            return defaults.stringForKey(favoriteKey)
        }
    }
    static let sharedInstance = Model()
}