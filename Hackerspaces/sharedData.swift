//
//  sharedData.swift
//  Hackerspaces
//
//  Created by zephyz on 29/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit

let selected = "favorite"
let favoriteList = "listOfFavorites"
let favoriteDictKey = "DictionaryOfFavorites"
let parsedDataList = "listOfParsedHackerspaceData"

struct SharedData {
    
    typealias HackerspaceAPIURL = String
    static let defaults = NSUserDefaults.standardUserDefaults()
    
    static func favoritesDictionary() -> [String: HackerspaceAPIURL] {
        return SharedData.defaults.dictionaryForKey(favoriteDictKey)?.map { value in value as! HackerspaceAPIURL} ?? [String: HackerspaceAPIURL]()
    }
    
    static func addToFavoriteDictionary(hackerspace: (String, String)) {
        let (name, apiEndpoint) = hackerspace
        setFavoritesDictionary(favoritesDictionary().insert(name, v: apiEndpoint))
    }
    
    static func removeFromFavoritesList(name: String) {
        setFavoritesDictionary(favoritesDictionary().delete(name))
    }
    
    static func setFavoritesDictionary(dict: [String : HackerspaceAPIURL]) {
        updateIconShortcuts(dict)
        SharedData.defaults.setObject(dict, forKey: favoriteDictKey)
    }
    
    static func deleteAllDebug() {
        setFavoritesDictionary([String: HackerspaceAPIURL]())
    }
    
    static func updateIconShortcuts(dict: [String: String]) {
        let shorts = dict.map { key, value in
            UIApplicationShortcutItem(type: UIConstants.hackerspaceViewShortcut.rawValue, localizedTitle: key, localizedSubtitle: nil, icon: nil, userInfo: ["name": key, "url": value])
        }
        UIApplication.sharedApplication().shortcutItems = shorts
    }
}