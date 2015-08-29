//
//  HackerspaceAPIFunctions.swift
//  Hackerspaces
//
//  Created by zephyz on 24/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import Swiftz
import JSONJoy
import SwiftHTTP
import BrightFutures
import MapKit
import Haneke

struct SpaceAPIConstants {
    static let API = "http://spaceapi.net/directory.json"
    static let customAPIPrefix = "ext_"
    static let APIlocation = "location"
    static let APIversion = "api"
    static let APIname = "space"
    static let APIlogo = "logo"
    static let APIurl = "url"
    static let APIstate = "state"
    static let APIcontact = "contact"
    static let APIreport = "issue_report_channels"
}

struct SpaceAPI {
    
    static func loadAPI() -> Future<[String : String], NSError> {
        let p = Promise<[String: String], NSError>()
        Queue.global.async {
            let cache = Shared.dataCache
            cache.fetch(URL: NSURL(string: SpaceAPIConstants.API)!).onSuccess { data in
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
                    p.failure(error!)
            }
        }
        return p.future
    }
    
    static func loadAPIFromWeb() -> Future<[String : String], NSError> {
        let p = Promise<[String: String], NSError>()
        Queue.global.async {
            let req = HTTPTask()
            req.GET(SpaceAPIConstants.API, parameters: nil) { (response: HTTPResponse) in
                if let data = response.responseObject as? NSData {
                    Shared.dataCache.set(value: data, key: SpaceAPIConstants.API)
                    if let dict = JSONDecoder(data).dictionary {
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
                } else {
                    p.failure(NSError(domain: "HTTP request data cast error", code: 125, userInfo: nil))
                }
            }
        }
        return p.future
    }
    
    static func loadHackerspaceAPI(url: String) -> Future<[String : JSONDecoder], NSError> {
        let p = Promise<[String : JSONDecoder], NSError>()
        Queue.global.async {
            let cache = Shared.dataCache
            cache.fetch(URL: NSURL(string: url)!).onSuccess { data in
                if let dict = JSONDecoder(data).dictionary{
                    p.success(dict)
                } else {
                    p.failure(NSError(domain: "HTTP request json cast error: \(JSONDecoder(data).description)", code: 126, userInfo: nil))
                }
            }.onFailure { error in
                    p.failure(error!)
            }
        }
        return p.future
    }
    
    static func loadHackerspaceAPIFromWeb(url: String) -> Future<[String : JSONDecoder], NSError> {
        let p = Promise<[String: JSONDecoder], NSError>()
        Queue.global.async {
            let req = HTTPTask()
            req.GET(url, parameters: nil) {(response: HTTPResponse) in
                if let err = response.error {
                    p.failure(err)
                } else if let data = response.responseObject as? NSData {
                    Shared.dataCache.set(value: data, key: url)
                    if let dict = JSONDecoder(data).dictionary {
                        p.success(dict)
                    } else {
                        p.failure(NSError(domain: "HTTP GET data cast", code: 123, userInfo: nil))
                    }
                } else {
                    p.failure(NSError(domain: "HTTP GET response cast", code: 124, userInfo: nil))
                }
            }
        }
        return p.future
    }
    
    static func loadHackerspaceAPINoError(url: String) -> Future<Result<[String : JSONDecoder]>, NoError> {
        return FutureUtils.futureToResult(loadHackerspaceAPI(url))
    }
    
    static func getHackerspaceLocation(url: String) -> Future<SpaceLocation?, NSError> {
        return loadHackerspaceAPI(url).map { self.extractLocationInfo($0) }
    }
    
    static func tupleFutureToFutureOfTuple<T,U>(t: (Future<T, NSError>, Future<U, NSError>)) -> Future<(T,U), NSError> {
        return t.0.zip(t.1)
    }
    
    static func listTupleToListFuture(list: [(Future<String, NoError>, Future<[String : JSONDecoder], NoError>)]) -> Future<[(String, [String: JSONDecoder])], NoError> {
        let m: [Future<(String, [String: JSONDecoder]), NoError>]  = list.map { (tuple: (Future<String, NoError>, Future<[String : JSONDecoder], NoError>)) -> Future<(String, [String: JSONDecoder]), NoError> in
        tuple.0.zip(tuple.1)}
        return BrightFutures.sequence(m)
    }
    
    /*!
    @brief converts dictionary of url into list of futures
    
    @discussion This function takes a dictionnary of name to url as strings and maps it to a list of tuples containing the key of the dictionary as a non-failing future and the value as a future of a JSON object which is a dictionary from String to JSONDecoder
    
    @param  Dictionary of strings representing [name : url]
    
    @return list of tuple representing the name and the result of the queried url as a future. [(F<name>, F<JSON>)]
    */
    private static func dictToFutureQuery(dictionary: [String : String]) -> [Future<(String, [String : JSONDecoder])?, NoError>] {
        return map(dictionary) { (key, value) in
            let t = (future(key), SpaceAPI.loadHackerspaceAPI(value))
            let s = future(key).zip(FutureUtils.futureToOptional(t.1))
            let r = s.map { (tuple: (String, [String : JSONDecoder]?)) -> (String, [String : JSONDecoder])? in tuple.1 == nil ? nil : (tuple.0, tuple.1!)}
            return r
        }
    }
    
    private static func arrayFutureToFlatFutureArray(dict: [String : String]) -> Future<[(String, [String : JSONDecoder])], NoError> {
        return FutureUtils.flattenOptionalFuture(dictToFutureQuery(dict))
    }
    
    static func loadAllSpacesAPI(fromCache: Bool = true) -> Future<[(String, [String: JSONDecoder])], NSError> {
        return (fromCache ? loadAPI() : loadAPIFromWeb()).flatMap { (dict: [String : String]) -> Future<[(String, [String: JSONDecoder])], NSError> in
            promoteError(self.arrayFutureToFlatFutureArray(dict))
        }
    }
    
    static func loadAllSpaceAPIAsDict(fromCache: Bool = true) -> Future<[String : [String : JSONDecoder]], NSError> {
        return loadAllSpacesAPI(fromCache: fromCache).map { Dictionary($0) }
    }
    
    static func getHackerspaceOpens(fromCache: Bool = true) -> Future<[String : Bool], NSError> {
        return loadAllSpaceAPIAsDict(fromCache: fromCache).map { (dict: [String : [String : JSONDecoder]]) in
            let r = dict.map { (key, value) in (key, SpaceAPI.extractIsSpaceOpen(value))}
            return r
        }
    }
    
    static func getHackerspaceLocations(fromCache: Bool = true) -> Future<[SpaceLocation?], NSError> {
        return loadAllSpacesAPI(fromCache: fromCache).map { (arr:[(String, [String : JSONDecoder])]) -> [SpaceLocation?] in
            let r = arr.map { (tuple:(String, [String : JSONDecoder])) -> SpaceLocation? in SpaceAPI.extractLocationInfo(tuple.1) }
            return r
        }
    }
    
    static func extractIsSpaceOpen(json: [String: JSONDecoder]) -> Bool {
        return json["state"]?.dictionary?["open"]?.bool ?? false
    }
    
    static func extractName(json: [String: JSONDecoder]) -> String {
        return json[SpaceAPIConstants.APIname]!.string!
    }
    
    ///returns the location from a json file, returns nil if unable to parse
    static func extractLocationInfo(json: [String: JSONDecoder]) -> SpaceLocation? {
        let location = json[SpaceAPIConstants.APIlocation]?.dictionary
        let lat = location?["lat"]?.number >>- {CLLocationDegrees($0)}
        let lon = location?["lon"]?.number >>- {CLLocationDegrees($0)}
        let loc = lat >>- {la in lon >>- { lo in CLLocationCoordinate2D(latitude: la, longitude: lo)}}
        return loc >>- {SpaceLocation(name: self.extractName(json), address: location?["address"]?.string, location: $0)}
    }
}