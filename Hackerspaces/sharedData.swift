//
//  sharedData.swift
//  Hackerspaces
//
//  Created by zephyz on 29/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import Swiftz

let selected = "favorite"
let favoriteList = "listOfFavorites"

class Model {
    
    static let defaults = NSUserDefaults.standardUserDefaults()
    
    func listOfFavorites() -> [String] {
        return (Model.defaults.arrayForKey(favoriteList) >>- { arr in arr.map { obj in obj as! String} }) ?? [String]()
    }
    
    func setListOfFavorites(list: [String]) {
        Model.defaults.setValue(list, forKey: favoriteList)
    }
    
    func addToFavorites(url: String) {
        Model.defaults.setValue(listOfFavorites().cons(url), forKey: favoriteList)
    }
    
    func removeFromFavorites(url: String) {
        Model.defaults.setValue(listOfFavorites().filter { $0 != url }, forKey: favoriteList)
    }
    
    static let sharedInstance = Model()
}