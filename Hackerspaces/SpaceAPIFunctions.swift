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
import Result
import MapKit
import Haneke

struct SpaceAPI {
    
    ///Returns a future containing a dictionary of names and endpoints of all hackerspaces using the SpaceAPI
    static private func loadAPIFromCache() -> Future<[String : String], SpaceAPIError> {
        let p = Promise<[String: String], SpaceAPIError>()
        Queue.global.async {
            let cache = Shared.dataCache
            cache.fetch(URL: NSURL(string: SpaceAPIConstants.FIXMEAPI.rawValue)!).onSuccess { data in
                if let dict = JSONDecoder(data).dictionary {
                    var api = [String : String]()
                    for key in dict.keys {
                        if let value = dict[key]?.string {
                            api[key] = value
                        }
                    }
                    p.success(api)
                } else {
                    p.failure(SpaceAPIError.DataCastError(data: data))
                }
            }.onFailure { error in
                p.failure(SpaceAPIError.UnknownError(error: error!))
            }
        }
        return p.future
    }
    
    static private func loadAPIFromWeb() -> Future<[String : String], SpaceAPIError> {
        let p = Promise<[String: String], SpaceAPIError>()
        Queue.global.async {
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
                        p.failure(SpaceAPIError.DataCastError(data: response.data))
                    }
                }
            } catch let err {
                p.failure(SpaceAPIError.HTTPRequestError(error: err))
            }
        }
        return p.future
    }
    
    static func loadHackerspaceList(fromCache fromCache: Bool) -> Future<[String: String], SpaceAPIError> {
        return fromCache ? loadAPIFromCache() : (loadAPIFromWeb().recoverWith { _ in loadAPIFromCache()})
    }
    
    typealias URL = String
    static func loadHackerspaceData(url: String, fromCache: Bool = true) -> Future<[URL : JSONDecoder], SpaceAPIError> {
        return (fromCache ? SpaceAPI.loadHackerspaceDataFromCache : SpaceAPI.loadHackerspaceDataFromWeb)(url)
    }
    
    static private func loadHackerspaceDataFromCache(url: String) -> Future<[String : JSONDecoder], SpaceAPIError> {
        let p = Promise<[String : JSONDecoder], SpaceAPIError>()
        Queue.global.async {
            let cache = Shared.dataCache
            cache.fetch(URL: NSURL(string: url)!).onSuccess { data in
                if let dict = JSONDecoder(data).dictionary{
                    p.success(dict)
                } else {
                    p.failure(SpaceAPIError.DataCastError(data: data))
                }
            }.onFailure { error in
                p.failure(SpaceAPIError.UnknownError(error: error!))
            }
        }
        return p.future
    }
    
    static private func loadHackerspaceDataFromWeb(url: String) -> Future<[String : JSONDecoder], SpaceAPIError> {
        let p = Promise<[String: JSONDecoder], SpaceAPIError>()
        Queue.global.async {
            do {
                let req = try HTTP.GET(url)
                req.start { response in
                    if let err = response.error {
                        p.failure(SpaceAPIError.UnknownError(error: err))
                    } else {
                        Shared.dataCache.set(value: response.data, key: url)
                        if let dict = JSONDecoder(response.data).dictionary {
                            p.success(dict)
                        } else {
                            p.failure(SpaceAPIError.DataCastError(data: response.data))
                        }
                    }
                }
            } catch let err {
                p.failure(SpaceAPIError.HTTPRequestError(error: err))
            }
        }
        return p.future
    }
    
    static func parseHackerspace(json: [String : JSONDecoder], url: String, name: String) -> Result<ParsedHackerspaceData, SpaceAPIError>{
        switch parseHackerspaceDataModel(json, name: name, url: url) {
            case .Some(let p): return Result(value: p)
            case .None : return Result(error: SpaceAPIError.ParseError(json: JSONDecoder(json).print()))
        }
    }
    
    static func getParsedHackerspace(url: String, name: String, fromCache cache: Bool = true) -> Future<ParsedHackerspaceData, SpaceAPIError> {
        return loadHackerspaceData(url, fromCache: cache).flatMap { dict in parseHackerspace(dict, url: url, name: name)}
        
    }
}