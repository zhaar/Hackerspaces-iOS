
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

private func parseAPI(data: Data) -> [(String, String)]? {
    return try? Array<(String, String)>.initDictionary(JSONDecoder().decode([String: String].self, from: data))
}

private func parseAsDict(data: Data) -> [String: Data]? {
    return try? JSONDecoder().decode([String: Data].self, from: data)
}

typealias HSData = Data

/// namespace for all space api methods
enum SpaceAPI { }

//MARK: - helper functions for automatically loading from cache or network
extension SpaceAPI {
    static func loadHackerspaceList(fromCache: Bool) -> Future<[(String, String)], SpaceAPIError> {
        
        if Testing.isTestingUI() {
            return Future.init(value: Testing.mockAPIResponse).promoteError()
        } else if fromCache {
            return loadAPIFromCache().recoverWith { _ in
                print("loading from cache failed, loading from web")
                return loadAPIFromWeb()
            }
        } else {
            return loadAPIFromWeb().recoverWith { _ in
                print("loading from web failed, loading from cache")
                return loadAPIFromCache()
            }
        }
    }

    static private func loadHackerspaceData(url: String, fromCache: Bool = true) -> Future<HSData, SpaceAPIError> {
        if let response = get(Testing.mockHackerspaceData, key: url), Testing.isTestingUI() {
            return Future(value: response).promoteError()
        }
        return (fromCache ? SpaceAPI.loadHackerspaceDataFromCache : SpaceAPI.loadHackerspaceDataFromWeb)(url)
    }

    static private func parseHackerspace(json: HSData, url: String, name: String) -> Result<ParsedHackerspaceData, SpaceAPIError>{
        return parseHackerspaceDataModel(json: json, name: name, url: url) |=> .parseError(json.description)
    }

    static func getParsedHackerspace(url: String, name: String, fromCache cache: Bool = true) -> Future<ParsedHackerspaceData, SpaceAPIError> {
        return loadHackerspaceData(url: url, fromCache: cache).flatMap { parseHackerspace(json: $0, url: url, name: name) }
    }
}

//MARK: - Network requests
extension SpaceAPI {

    enum HTTPError: Error {
        case notOK(HTTPStatusCode)
        case requestError(Error)
        case unknownError
        case urlError(String)
    }

    static private func httpRequest(url: String, timeout: Int = 5) -> Future<Data, HTTPError> {
        let p = Promise<Data, HTTPError>()
        DispatchQueue.global().async {

            if let urlStr = URL(string: url) {
                let req = URLRequest.init(url: urlStr, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: TimeInterval(timeout))
                HTTP.init(req).start { response in
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
            } else {
                p.failure(.urlError(url))
            }
        }
        return p.future
    }

    static fileprivate func loadHackerspaceDataFromWeb(url: String) -> Future<HSData, SpaceAPIError> {
        return httpRequest(url: url)
            .mapError(SpaceAPIError.httpRequestError)
    }

    static fileprivate func loadAPIFromWeb() -> Future<[(String, String)], SpaceAPIError> {
        return httpRequest(url: SpaceAPIConstants.FIXMEAPI.rawValue)
            .mapError(SpaceAPIError.httpRequestError)
            .flatMap { (data: Data) -> Result<[(String, String)], SpaceAPIError> in
                return parseAPI(data: data) |=> SpaceAPIError.dataCastError(data: data)
        }
    }
}

//MARK: - Loading from cache
extension SpaceAPI {

    enum CacheError: Error {
        case notFound(key: String, error: Error?)
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

    static fileprivate func loadHackerspaceDataFromCache(url: String) -> Future<HSData, SpaceAPIError> {
        return loadFromCache(key: url).mapError(SpaceAPIError.unknownError)
    }

    ///Returns a future containing a dictionary of names and endpoints of all hackerspaces using the SpaceAPI
    static fileprivate func loadAPIFromCache() -> Future<[(String, String)], SpaceAPIError> {
        return loadFromCache(key: SpaceAPIConstants.FIXMEAPI.rawValue)
            .mapError({SpaceAPIError.unknownError(error: $0)})
            .flatMap { (data: Data) -> Result<[(String, String)], SpaceAPIError> in
                parseAPI(data: data) |=> .dataCastError(data: data)
        }
    }
}
