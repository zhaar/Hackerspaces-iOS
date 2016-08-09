//
//  sharedData.swift
//  Hackerspaces
//
//  Created by zephyz on 29/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation

let selected = "favorite"
let favoriteList = "listOfFavorites"
let favoriteDictKey = "DictionaryOfFavorites"
let parsedDataList = "listOfParsedHackerspaceData"

class SharedData {
    
    typealias HackerspaceAPIURL = String
    static let defaults = NSUserDefaults.standardUserDefaults()
    
    func favoritesDictionary() -> [String: HackerspaceAPIURL] {
        return SharedData.defaults.dictionaryForKey(favoriteDictKey)?.map { value in value as! HackerspaceAPIURL} ?? [String: HackerspaceAPIURL]()
    }
    
    func addToFavoriteDictionary(hackerspace: (String, String)) {
        let (name, apiEndpoint) = hackerspace
        setFavoritesDictionary(favoritesDictionary().insert(name, v: apiEndpoint))
    }
    
    func removeFromFavoritesList(name: String) {
        setFavoritesDictionary(favoritesDictionary().delete(name))
    }
    
    func setFavoritesDictionary(dict: [String : HackerspaceAPIURL]) {
        SharedData.defaults.setObject(dict, forKey: favoriteDictKey)
    }
    
    func deleteAllDebug() {
        setFavoritesDictionary([String: HackerspaceAPIURL]())
    }
    
    static let sharedInstance = SharedData()
}