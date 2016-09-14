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
import JSONWrapper

struct SpaceAPI {

    private static func parseAPI(data: Data) -> [String: String]? {
        let parsed = JSONObject.parse(fromData: data)?.asObject
        let api = parsed.map { $0.flatMap { t in t.value.asString.map { (t.key, $0) } } }
        return api.map(tuplesAsDict)
    }

    ///Returns a future containing a dictionary of names and endpoints of all hackerspaces using the SpaceAPI
    static private func loadAPIFromCache() -> Future<[String : String], SpaceAPIError> {
        let p = Promise<[String: String], SpaceAPIError>()
        DispatchQueue.global().async {
            let cache = Shared.dataCache
            cache.fetch(URL: URL(string: SpaceAPIConstants.FIXMEAPI.rawValue)!)
                .onSuccess { data in
                    if let api = parseAPI(data: data) {
                        p.success(api)
                    } else {
                        p.failure(SpaceAPIError.dataCastError(data: data))
                    }
                }.onFailure { error in
                    p.failure(SpaceAPIError.unknownError(error: error!))
            }
        }
        return p.future
    }

    static private func loadAPIFromWeb() -> Future<[String : String], SpaceAPIError> {
        let p = Promise<[String: String], SpaceAPIError>()
        DispatchQueue.global().async {
            do {
                let req = try HTTP.GET(SpaceAPIConstants.FIXMEAPI.rawValue)
                req.start { response in
                    Shared.dataCache.set(value: response.data, key: SpaceAPIConstants.FIXMEAPI.rawValue)
                    if let api = parseAPI(data: response.data) {
                        p.success(api)
                    } else {
                        p.failure(SpaceAPIError.dataCastError(data: response.data))
                    }
                }
            } catch let err {
                p.failure(SpaceAPIError.httpRequestError(error: err))
            }
        }
        return p.future
    }

    static func loadHackerspaceList(fromCache: Bool) -> Future<[String: String], SpaceAPIError> {
        return fromCache ? loadAPIFromCache() : (loadAPIFromWeb().recoverWith { _ in print("loading from web failed, loading from cache"); return loadAPIFromCache() })
    }

    static private func loadHackerspaceDataFromCache(url: String) -> Future<[String : JSONValue], SpaceAPIError> {
        let p = Promise<[String : JSONValue], SpaceAPIError>()
        DispatchQueue.global().async {
            let cache = Shared.dataCache

            cache.fetch(URL: URL(string: url)!)
                .onSuccess { data in
                    if let dict = JSONObject.parse(fromData: data)?.asObject {
                        p.success(dict)
                    } else {
                        p.failure(SpaceAPIError.dataCastError(data: data))
                    }
                }
                .onFailure { (err: Error?) in
                    p.failure(SpaceAPIError.unknownError(error: err!))
            }
        }
        return p.future
    }

    static private func loadHackerspaceDataFromWeb(url: String) -> Future<[String : JSONValue], SpaceAPIError> {
        let p = Promise<[String: JSONValue], SpaceAPIError>()
        DispatchQueue.global().async {
            do {
                let req = try HTTP.GET(url)
                req.start { response in
                    if let err = response.error {
                        p.failure(SpaceAPIError.unknownError(error: err))
                    } else {
                        Shared.dataCache.set(value: response.data, key: url)
                        if let dict = JSONObject.parse(fromData: response.data)?.asObject {
                            p.success(dict)
                        } else {
                            p.failure(SpaceAPIError.dataCastError(data: response.data))
                        }
                    }
                }
            } catch let err {
                p.failure(SpaceAPIError.httpRequestError(error: err))
            }
        }
        return p.future
    }
    
    static func loadHackerspaceData(url: String, fromCache: Bool = true) -> Future<[String : JSONValue], SpaceAPIError> {
        return (fromCache ? SpaceAPI.loadHackerspaceDataFromCache : SpaceAPI.loadHackerspaceDataFromWeb)(url)
    }

    static func parseHackerspace(json: [String : JSONValue], url: String, name: String) -> Result<ParsedHackerspaceData, SpaceAPIError>{
        return parseHackerspaceDataModel(json: json, name: name, url: url).map(Result.init(value:)) ?? Result(error: SpaceAPIError.parseError(json.description))
    }

    static func getParsedHackerspace(url: String, name: String, fromCache cache: Bool = true) -> Future<ParsedHackerspaceData, SpaceAPIError> {
        return loadHackerspaceData(url: url, fromCache: cache).flatMap { parseHackerspace(json: $0, url: url, name: name) }
    }
}
