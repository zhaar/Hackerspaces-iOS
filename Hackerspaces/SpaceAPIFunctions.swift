//
//  HackerspaceAPIFunctions.swift
//  Hackerspaces
//
//  Created by zephyz on 24/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import Swiftz
import SwiftHTTP
import BrightFutures
import Result
import MapKit
import Haneke

struct SpaceAPI {
    
    static func loadAPI() -> Future<[String : String], NSError> {
        let p = Promise<[String: String], NSError>()
        DispatchQueue.global().async {
            let cache = Shared.dataCache
            cache.fetch(URL: URL(string: SpaceAPIConstants.FIXMEAPI.rawValue)!).onSuccess { data in
                if let dict = JSONDecoder(data).dictionary{
                    var api = [String : String]()
                    for key in dict.keys {
                        if let value = dict[key]?.string {
                            api[key] = value
                        }
                    }
                    p.success(api)
                } else {
                    p.failure(NSError(domain: "HTTP request json cast error: \(JSONDecoder(data).description)", code: 126, userInfo: nil))
                }
                }.onFailure { error in
                    p.failure(NSError(domain: "HTTP request error: \(String(describing: error?.localizedDescription))", code: -889, userInfo: nil))
            }
        }
        return p.future
    }
    
    static func loadAPIFromWeb() -> Future<[String : String], NSError> {
        let p = Promise<[String: String], NSError>()
        DispatchQueue.global().async {
            do {
                let req = try HTTP.GET(SpaceAPIConstants.FIXMEAPI.rawValue)
                req.start { response in
                    Shared.dataCache.set(value: response.data, key: SpaceAPIConstants.FIXMEAPI.rawValue)
                    if let dict = JSONDecoder(response.data).dictionary {
                        var api = [String : String]()
                        for key in dict.keys {
                            if let value = dict[key]?.string {
                                api[key] = value
                            }
                        }
                        p.success(api)
                    } else {
                        p.failure(NSError(domain: "HTTP GET response cast", code: 124, userInfo: nil))
                    }
                }
            } catch let err {
                p.failure(NSError(domain: "HTTP GET request failed with error: \(err)", code: 123, userInfo: nil))
            }
        }
        return p.future
    }
    
    static func loadHackerspace(_ url: String, fromCache: Bool = true) -> Future<[String : JSONDecoder], NSError> {
        return (fromCache ? SpaceAPI.loadHackerspaceAPI : SpaceAPI.loadHackerspaceAPIFromWeb)(url)
    }
    
    static func loadHackerspaceAPI(_ url: String) -> Future<[String : JSONDecoder], NSError> {
        let p = Promise<[String : JSONDecoder], NSError>()
        DispatchQueue.global().async {
            let cache = Shared.dataCache
            cache.fetch(URL: URL(string: url)!)
                .onSuccess { data in
                    if let dict = JSONDecoder(data).dictionary {
                        p.success(dict)
                    } else {
                        p.failure(NSError(domain: "JSON parsing error: \(JSONDecoder(data).description)", code: 126, userInfo: nil))
                    }
                }.onFailure({ (err: Error?) in
                    p.failure(NSError(domain: "cache fetch error: \(String(describing: err?.localizedDescription))", code: -888, userInfo: nil))
                })
        }
        return p.future
    }
    
    static func loadHackerspaceAPIFromWeb(_ url: String) -> Future<[String : JSONDecoder], NSError> {
        let p = Promise<[String: JSONDecoder], NSError>()
        DispatchQueue.global().async {
            do {
                let req = try HTTP.GET(url)
                req.start { response in
                    if let err = response.error {
                        p.failure(err)
                    } else {
                        Shared.dataCache.set(value: response.data, key: url)
                        if let dict = JSONDecoder(response.data).dictionary {
                            p.success(dict)
                        } else {
                            p.failure(NSError(domain: "HTTP GET data cast", code: 123, userInfo: nil))
                        }
                    }
                }
            } catch {
                p.failure(NSError(domain: "HTTP GET request failed", code: 124, userInfo: nil))
            }
        }
        return p.future
    }
    
    static func getParsedHackerspace(_ url: String, name: String) -> Future<ParsedHackerspaceData, NSError> {
        return  loadHackerspace(url, fromCache: true).map {parseHackerspaceDataModel(json: $0, name: name, url: url)}.flatMap { parsed -> Result<ParsedHackerspaceData, NSError> in
            switch parsed {
            case .some(let p): return Result(value: p)
            case .none : return Result(error: NSError(domain: "parse Error", code: -1, userInfo: nil))
            }
        }
        
    }
    
    static func getHackerspaceLocation(_ url: String) -> Future<SpaceLocation?, NSError> {
        return loadHackerspaceAPI(url).map(extractLocationInfo)
    }
    
    static func tupleFutureToFutureOfTuple<T,U>(_ t: (Future<T, NSError>, Future<U, NSError>)) -> Future<(T,U), NSError> {
        return t.0.zip(t.1)
    }
    
    static func listTupleToListFuture(_ list: [(Future<String, NoError>, Future<[String : JSONDecoder], NoError>)]) -> Future<[(String, [String: JSONDecoder])], NoError> {
        let m: [Future<(String, [String: JSONDecoder]), NoError>] = list.map { (tuple: (Future<String, NoError>, Future<[String : JSONDecoder], NoError>)) -> Future<(String, [String: JSONDecoder]), NoError> in
            tuple.0.zip(tuple.1)}
        return m.sequence()
    }
    
    /*!
     @brief converts dictionary of url into list of futures
     
     @discussion This function takes a dictionnary of name to urls as strings and maps it to a list of tuples containing the key of the dictionary as a non-failing future and the value as a future of a JSON object which is a dictionary from String to JSONDecoder
     
     @param  Dictionary of strings representing [name : url]
     
     @return list of tuple representing the name and the result of the queried url as a future. [(F<name>, F<JSON>)]
     */
    fileprivate static func dictToFutureQuery(_ dictionary: [String : String]) -> [Future<(String, [String : JSONDecoder])?, NoError>] {
        return dictionary.map { (key, value) in
            let result = FutureUtils.futureToOptional(SpaceAPI.loadHackerspaceAPI(value))
            return result.map { (r: [String : JSONDecoder]?) -> (String, [String : JSONDecoder])? in r.flatMap {(key, $0)}}
        }
    }
    
    fileprivate static func arrayFutureToFlatFutureArray(_ dict: [String : String]) -> Future<[(String, [String : JSONDecoder])], NoError> {
        return FutureUtils.flattenOptionalFuture • dictToFutureQuery § dict
    }
    
    static func loadAllSpacesAPI(_ fromCache: Bool = true) -> Future<[(String, [String: JSONDecoder])], NSError> {
        let api = fromCache ? loadAPI() : loadAPIFromWeb()
        return api.flatMap { (dict: [String : String]) -> Future<[(String, [String: JSONDecoder])], NSError> in
            self.arrayFutureToFlatFutureArray(dict).promoteError()
        }
    }
    
    static func loadAllSpaceAPIAsDict(_ fromCache: Bool = true) -> Future<[String : [String : JSONDecoder]], NSError> {
        return loadAllSpacesAPI(fromCache).map(tuplesAsDict)
    }
    
    static func getHackerspaceLocations(_ fromCache: Bool = true) -> Future<[SpaceLocation?], NSError> {
        return loadAllSpacesAPI(fromCache).map { (arr:[(String, [String : JSONDecoder])]) -> [SpaceLocation?] in
            return arr.map { (tuple:(String, [String : JSONDecoder])) -> SpaceLocation? in SpaceAPI.extractLocationInfo(tuple.1) }
        }
    }
    
    static func extractIsSpaceOpen(_ json: [String: JSONDecoder]) -> Bool {
        return json["state"]?.dictionary?["open"]?.bool ?? false
    }
    
    static func extractName(_ json: [String: JSONDecoder]) -> String? {
        return json[SpaceAPIConstants.APIname.rawValue]?.string
    }
    
    ///returns the location from a json file, returns nil if unable to parse
    static func extractLocationInfo(_ json: [String: JSONDecoder]) -> SpaceLocation? {
        let location = json[SpaceAPIConstants.APIlocation.rawValue]?.dictionary
        let name = self.extractName(json)
        return location.flatMap { l in name.flatMap { n in parseLocationObject(l, withName: n) } }
    }
}
