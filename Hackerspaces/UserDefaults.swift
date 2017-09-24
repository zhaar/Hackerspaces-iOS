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
let debugModeKey = "debugModeKey"
let darkModeKey = "darkModeKey"
let customEndpointsKey = "customEndpointsKey"

struct SharedData {
    
    typealias HackerspaceAPIURL = String
    static let defaults = UserDefaults.standard

    static func addCustomEndpoint(name: String, url: String) -> () {
        updateCustomEndpoint { [(name, url)] + $0 }
    }

    static func updateCustomEndpoint(_ updateFn: ([(String, String)]) -> [(String, String)]) -> () {
        setCustomEndPoint(updateFn(getCustomEndPoint()))
    }

    static func getCustomEndPoint() -> [(String, String)] {
        return defaults.array(forKey: customEndpointsKey) as? [(String, String)] ?? []
    }

    static func setCustomEndPoint(_ array:[(String, String)]) -> () {
        defaults.set(array, forKey: customEndpointsKey)
    }

    static func isInDarkMode() -> Bool {
        return defaults.bool(forKey: darkModeKey)
    }

    static func setDarkMode(value: Bool) -> () {
        defaults.set(value, forKey: darkModeKey)
    }

    static func isInDebugMode() -> Bool {
        return defaults.bool(forKey: debugModeKey)
    }
    
    static func setDebugMode(value: Bool) -> () {
        defaults.set(value, forKey: debugModeKey)
    }
    
    static func toggleDebugMode() -> () {
        setDebugMode(value: !isInDebugMode())
    }
    
    static func favoritesDictionary() -> [String: HackerspaceAPIURL] {
        return defaults.dictionary(forKey: favoriteDictKey)?.map { value in value as! HackerspaceAPIURL} ?? [String: HackerspaceAPIURL]()
    }
    
    static func addToFavoriteDictionary(hackerspace: (String, String)) {
        let (name, apiEndpoint) = hackerspace
        setFavorites(dictionary: favoritesDictionary().insert(name, v: apiEndpoint))
    }
    
    static func removeFromFavoritesList(name: String) {
        setFavorites(dictionary: favoritesDictionary().delete(name))
    }
    
    static func setFavorites(dictionary: [String : HackerspaceAPIURL]) {
        updateIconShortcuts(dict: dictionary)
        defaults.set(dictionary, forKey: favoriteDictKey)
    }
    
    static func deleteAllDebug() {
        setFavorites(dictionary: [String: HackerspaceAPIURL]())
    }
    
    static func updateIconShortcuts(dict: [String: String]) {
        let shorts = dict.map { key, value in
            UIApplicationShortcutItem(type: UIConstants.hackerspaceViewShortcut.rawValue, localizedTitle: key, localizedSubtitle: nil, icon: nil, userInfo: ["name": key, "url": value])
        }
        UIApplication.shared.shortcutItems = shorts
    }
}
