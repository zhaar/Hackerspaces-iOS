//
//  sharedData.swift
//  Hackerspaces
//
//  Created by zephyz on 29/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit
import Swiftz

let selected = "favorite"
let favoriteList = "listOfFavorites"
let favoriteDictKey = "DictionaryOfFavorites"
let parsedDataList = "listOfParsedHackerspaceData"
let debugModeKey = "debugModeKey"
let darkModeKey = "darkModeKey"
let customEndpointsKey = "customEndpointsKey"

struct KeyValuePair<Key: Codable, Value: Codable>: Codable {
    let key: Key
    let value: Value
}

func shouldDisplayCustomSection(indexPath: IndexPath? = nil) -> Bool {
    let section = indexPath?.section
    let isZero = section.map(==0) ?? true
    return !SharedData.getCustomEndPoints().isEmpty && SharedData.isInDebugMode() && isZero
}

struct SharedData {
    
    typealias HackerspaceAPIURL = String
    static let defaults = UserDefaults.standard

    static func addCustomEndpoint(name: String, url: String) -> () {
        updateCustomEndpoint { [(name, url)] + $0 }
    }

    static func updateCustomEndpoint(_ updateFn: ([(String, String)]) -> [(String, String)]) -> () {
        setCustomEndPoint(updateFn(getCustomEndPoints()))
    }

    static func getCustomEndPoints() -> [(String, String)] {
        return getKeyValuePair(forKey: customEndpointsKey)
    }

    static func setCustomEndPoint(_ array:[(String, String)]) -> () {
        setKeyValuePair(forkey: customEndpointsKey, pair: array)
    }

    static func removeCustomEndPoint(name: String) -> () {
        updateCustomEndpoint { (endpoints) -> [(String, String)] in

            return Array.init(tuplesAsDict(endpoints).delete(name))
        }
    }

    // - MARK: Generic manipulation of storing key-value pairs
    static func getKeyValuePair<K: Codable, V: Codable>(forKey key: String) -> [(K, V)] {
        let plist = defaults.data(forKey: key)
        let kvPairs = plist.flatMap { try? PropertyListDecoder().decode([KeyValuePair<K, V>].self, from: $0) } ?? []
        return kvPairs.map { pair in (pair.key, pair.value) }
    }

    static func setKeyValuePair<K: Codable, V: Codable>(forkey key: String, pair: [(K, V)])  -> () {
        let pairs = pair.map { KeyValuePair<K, V>(key: $0.0, value: $0.1) }
        do {
            defaults.set(try PropertyListEncoder().encode(pairs), forKey: key)
        } catch {
            print("could not set the keyvalue pair: \(pair) \n with key: \(key)")
        }
    }

    static func updateKeyValuePair<K: Codable, V: Codable>(key: String, updateFn: ([(K, V)]) -> [(K, V)]) -> () {
        setKeyValuePair(forkey: key, pair: updateFn(getKeyValuePair(forKey: key)))

    }

    // - MARK: Dark mode
    static func isInDarkMode() -> Bool {
        return defaults.bool(forKey: darkModeKey)
    }

    static func setDarkMode(value: Bool) -> () {
        defaults.set(value, forKey: darkModeKey)
    }

    // - MARK: Debug mode
    static func isInDebugMode() -> Bool {
        return defaults.bool(forKey: debugModeKey)
    }
    
    static func setDebugMode(value: Bool) -> () {
        defaults.set(value, forKey: debugModeKey)
    }
    
    static func toggleDebugMode() -> () {
        setDebugMode(value: !isInDebugMode())
    }

    // - MARK
    static func favoritesDictionary() -> [(String, HackerspaceAPIURL)] {
        return getKeyValuePair(forKey: favoriteDictKey)
    }
    
    static func addToFavoriteDictionary(hackerspace: (String, String)) {
        let (name, apiEndpoint) = hackerspace
        updateKeyValuePair(key: favoriteDictKey, updateFn: curry(addOrUpdate)(name)(apiEndpoint))
    }
    
    static func removeFromFavoritesList(name: String) {
        
        updateKeyValuePair(key: favoriteDictKey, updateFn: { arr -> [(String, String)] in remove(from: arr, key: name) })
    }
    
    static func setFavorites(dictionary: [(String, HackerspaceAPIURL)]) {
        setKeyValuePair(forkey: favoriteDictKey, pair: dictionary)
    }
    
    static func deleteAllDebug() {
        setKeyValuePair(forkey: favoriteDictKey, pair: [(String, String)]())
        setKeyValuePair(forkey: customEndpointsKey, pair: [(String, String)]())
    }

}
