//
//  sharedData.swift
//  Hackerspaces
//
//  Created by zephyz on 29/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import Swiftz

let favoriteKey = "favorite"
let favoriteList = "listOfFavorites"

class Model {
    
    static let defaults = NSUserDefaults.standardUserDefaults()
    
    var favoriteHackerspaceURL: String? {
        set {
            println("setting new value for prefered hackerspace")
            Model.defaults.setObject(newValue!, forKey: favoriteKey)
        }
        get {
            println("fetching favorite hackerspace")
            return Model.defaults.stringForKey(favoriteKey)
        }
    }
    
    func listOfFavorites() -> [String] {
        return (Model.defaults.arrayForKey(favoriteList) >>- { arr in arr.map { obj in obj as! String} }) ?? [String]()
    }
    
    func addToFavorites(url: String) {
        Model.defaults.setValue(listOfFavorites().cons(url), forKey: favoriteList)
    }
    
    func removeFromFavorites(url: String) {
        Model.defaults.setValue(listOfFavorites().filter { $0 != url }, forKey: favoriteList)
    }
    
    static let sharedInstance = Model()
}