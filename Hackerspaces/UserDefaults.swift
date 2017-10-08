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
    return !SharedData.customEndpoints.emptyGet().isEmpty && SharedData.isInDebugMode() && isZero
}

protocol DataBaseTable {
    associatedtype Key
    associatedtype Value
    typealias KeyValue = [(Key, Value)]

    var title: String { get }
    func get() -> KeyValue?
    func set(data: KeyValue) -> ()
}

extension DataBaseTable {

    func emptyGet() -> KeyValue {
        return get() ?? []
    }

    func deleteRow(at index: Int) -> () {
        self.updateData { (array: KeyValue) -> KeyValue in
            var cpy = array
            cpy.remove(at: index)
            return cpy
        }
    }

    func updateData(_ fn: (KeyValue) -> KeyValue) -> ()? {
        if let data: KeyValue = get() {
            return set(data: fn(data))
        } else {
            return nil
        }
    }
}

extension DataBaseTable where Key: Equatable {

    func addRow(key: Key, value: Value) -> () {
        if self.updateData(curry(addOrUpdate)(key)(value)) == nil {
            set(data: [(key, value)])
        }
    }

    func getRow(named key: Key) -> Value? {
        if let data = get(),
            let found = data.first(where: { pair in pair.0 == key }) {
            return found.1
        } else {
            return nil
        }
    }

    func deleteRow(named key: Key) -> () {
        self.updateData { (array: KeyValue) -> KeyValue in
            remove(from: array, key: key)
        }
    }
}

struct ManagedData<Key: Codable & Equatable, Value: Codable>: DataBaseTable {
    typealias KeyValue = [(Key, Value)]
    let mainKey: String

    var title: String {
        return mainKey
    }
    func set(data: KeyValue) -> () {
        SharedData.setKeyValuePair(forkey: mainKey, pair: data)
    }

    func get() -> KeyValue? {
        return SharedData.getKeyValuePair(forKey: mainKey)
    }
}

struct SharedData {
    
    typealias HackerspaceAPIURL = String
    static let defaults = UserDefaults.standard

    static let customEndpoints = ManagedData<String, String>(mainKey: customEndpointsKey)

    static let favorites = ManagedData<String, String>(mainKey: favoriteDictKey)

    // - MARK: Generic manipulation of storing key-value pairs
    static func getKeyValuePair<K: Codable, V: Codable>(forKey key: String) -> [(K, V)]? {
        let plist = defaults.data(forKey: key)
        let kvPairs = plist.flatMap { try? PropertyListDecoder().decode([KeyValuePair<K, V>].self, from: $0) }
        return kvPairs.map { array in array.map { pair in (pair.key, pair.value) } }
    }

    static func setKeyValuePair<K: Codable, V: Codable>(forkey key: String, pair: [(K, V)])  -> () {
        let pairs = pair.map { KeyValuePair<K, V>(key: $0.0, value: $0.1) }
        do {
            defaults.set(try PropertyListEncoder().encode(pairs), forKey: key)
        } catch {
            print("could not set the keyvalue pair: \(pair) \n with key: \(key)")
        }
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

    static func deleteAllDebug() {
        setKeyValuePair(forkey: favoriteDictKey, pair: [(String, String)]())
        setKeyValuePair(forkey: customEndpointsKey, pair: [(String, String)]())
    }
}
