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

    enum HTTPError: Error {
        case notOK(HTTPStatusCode)
        case requestError(Error)
        case unknownError
    }

    enum CacheError: Error {
        case notFound(key: String, error: Error?)
    }

    static private func httpRequest(url: String) -> Future<Data, HTTPError> {
        let p = Promise<Data, HTTPError>()
        DispatchQueue.global().async {

            do {
                let req = try HTTP.GET(url)
                req.start { response in
                    Shared.dataCache.set(value: response.data, key: url)
                    if case HTTPStatusCode.ok.rawValue? = response.statusCode {
                        p.success(response.data)
                    } else if let r = response.statusCode, let code = HTTPStatusCode.init(rawValue: r) {
                        p.failure(.notOK(code))
                    } else if let err = response.error {
                        p.failure(.requestError(err))
                    } else {
                        p.failure(.unknownError)
                    }
                }
            } catch let err {
                p.failure(.requestError(err))
            }
        }
        return p.future
    }

    static private func loadFromCache(key: String) -> Future<Data, CacheError> {
        let p = Promise<Data, CacheError>()
        DispatchQueue.global().async {
            Shared.dataCache.fetch(key: key)
                .onSuccess(p.success)
                .onFailure { error in
                    p.failure(CacheError.notFound(key: key, error: error))
            }
        }
        return p.future
    }

    private static func parseAPI(data: Data) -> [String: String]? {
        let parsed = JSONObject.parse(fromData: data)?.asObject
        let api = parsed.map { $0.flatMap { t in t.value.asString.map { (t.key, $0) } } }
        return api.map(tuplesAsDict)
    }

    ///Returns a future containing a dictionary of names and endpoints of all hackerspaces using the SpaceAPI
    static private func loadAPIFromCache() -> Future<[String : String], SpaceAPIError> {
        return loadFromCache(key: SpaceAPIConstants.FIXMEAPI.rawValue)
            .mapError({SpaceAPIError.unknownError(error: $0)})
            .flatMap { (data: Data) -> Result<[String : String], SpaceAPIError> in
                parseAPI(data: data) |=> .dataCastError(data: data)
        }
    }

    static func loadAPIFromWeb() -> Future<[String : String], SpaceAPIError> {
        return httpRequest(url: SpaceAPIConstants.FIXMEAPI.rawValue)
            .mapError { SpaceAPIError.httpRequestError(error: $0) }
            .flatMap { (data: Data) -> Result<[String: String], SpaceAPIError> in
                return parseAPI(data: data) |=> SpaceAPIError.dataCastError(data: data)
        }
    }

    static func loadHackerspaceList(fromCache: Bool) -> Future<[String: String], SpaceAPIError> {
        return fromCache ? loadAPIFromCache() : (loadAPIFromWeb().recoverWith { _ in print("loading from web failed, loading from cache"); return loadAPIFromCache() })
    }

    static private func loadHackerspaceDataFromCache(url: String) -> Future<[String : JSONValue], SpaceAPIError> {
        return loadFromCache(key: url).mapError { SpaceAPIError.unknownError(error: $0) }
            .flatMap({ (data: Data) -> Result<[String : JSONValue], SpaceAPIError> in
            JSONObject.parse(fromData: data)?.asObject |=> .dataCastError(data: data)
        })
    }

    static private func loadHackerspaceDataFromWeb(url: String) -> Future<[String : JSONValue], SpaceAPIError> {

        return httpRequest(url: url)
            .mapError { SpaceAPIError.httpRequestError(error: $0) }
            .flatMap({ (data: Data) -> Result<[String : JSONValue], SpaceAPIError> in
                return JSONObject.parse(fromData: data)?.asObject |=> SpaceAPIError.dataCastError(data: data)
            })
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
