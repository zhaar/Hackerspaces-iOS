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
        return parseHackerspaceDataModel(json: json, name: name, url: url).map(Result.init(value:)) ?? Result(error: SpaceAPIError.parseError(json))
    }

    static func getParsedHackerspace(url: String, name: String, fromCache cache: Bool = true) -> Future<ParsedHackerspaceData, SpaceAPIError> {
        return loadHackerspaceData(url: url, fromCache: cache).flatMap { parseHackerspace(json: $0, url: url, name: name) }
    }
}


//<<<<<<< HEAD
//

//
//
//    static func getHackerspaceLocation(_ url: String) -> Future<SpaceLocation?, NSError> {
//        return loadHackerspaceAPI(url).map(extractLocationInfo)
//    }
//
//    static func tupleFutureToFutureOfTuple<T,U>(_ t: (Future<T, NSError>, Future<U, NSError>)) -> Future<(T,U), NSError> {
//        return t.0.zip(t.1)
//    }
//
//    static func listTupleToListFuture(_ list: [(Future<String, NoError>, Future<[String : JSONValue], NoError>)]) -> Future<[(String, [String: JSONValue])], NoError> {
//        let m: [Future<(String, [String: JSONValue]), NoError>] = list.map { (tuple: (Future<String, NoError>, Future<[String : JSONValue], NoError>)) -> Future<(String, [String: JSONValue]), NoError> in
//            tuple.0.zip(tuple.1)}
//        return m.sequence()
//    }
//
//    /*!
//     @brief converts dictionary of url into list of futures
//
//     @discussion This function takes a dictionnary of name to urls as strings and maps it to a list of tuples containing the key of the dictionary as a non-failing future and the value as a future of a JSON object which is a dictionary from String to JSONValue
//
//     @param  Dictionary of strings representing [name : url]
//
//     @return list of tuple representing the name and the result of the queried url as a future. [(F<name>, F<JSON>)]
//     */
//    fileprivate static func dictToFutureQuery(_ dictionary: [String : String]) -> [Future<(String, [String : JSONValue])?, NoError>] {
//        return dictionary.map { (key, value) in
//            let result = FutureUtils.futureToOptional(SpaceAPI.loadHackerspaceAPI(value))
//            return result.map { (r: [String : JSONValue]?) -> (String, [String : JSONValue])? in r.flatMap {(key, $0)}}
//        }
//    }
//
//    fileprivate static func arrayFutureToFlatFutureArray(_ dict: [String : String]) -> Future<[(String, [String : JSONValue])], NoError> {
//        return FutureUtils.flattenOptionalFuture • dictToFutureQuery § dict
//    }
//
//    static func loadAllSpacesAPI(_ fromCache: Bool = true) -> Future<[(String, [String: JSONValue])], NSError> {
//        let api = fromCache ? loadAPI() : loadAPIFromWeb()
//        return api.flatMap { (dict: [String : String]) -> Future<[(String, [String: JSONValue])], NSError> in
//            self.arrayFutureToFlatFutureArray(dict).promoteError()
//        }
//    }
//
//    static func loadAllSpaceAPIAsDict(_ fromCache: Bool = true) -> Future<[String : [String : JSONValue]], NSError> {
//        return loadAllSpacesAPI(fromCache).map(tuplesAsDict)
//    }
//
//    static func getHackerspaceLocations(_ fromCache: Bool = true) -> Future<[SpaceLocation?], NSError> {
//        return loadAllSpacesAPI(fromCache).map { (arr:[(String, [String : JSONValue])]) -> [SpaceLocation?] in
//            return arr.map { (tuple:(String, [String : JSONValue])) -> SpaceLocation? in SpaceAPI.extractLocationInfo(tuple.1) }
//        }
//    }
//
//    static func extractIsSpaceOpen(_ json: [String: JSONValue]) -> Bool {
//        return json["state"]?.asObject?["open"]?.asBool ?? false
//    }
//
//    static func extractName(_ json: [String: JSONValue]) -> String? {
//        return json[SpaceAPIConstants.APIname.rawValue]?.asString
//    }
//
//    ///returns the location from a json file, returns nil if unable to parse
//    static func extractLocationInfo(_ json: [String: JSONValue]) -> SpaceLocation? {
//        let location = json[SpaceAPIConstants.APIlocation.rawValue]?.asObject
//        let name = self.extractName(json)
//        return location.flatMap { l in name.flatMap { n in parseLocationObject(l, withName: n) } }
//    }
//}
//=======
//
//    static func parseHackerspace(json: [String : JSONDecoder], url: String, name: String) -> Result<ParsedHackerspaceData, SpaceAPIError>{
//        switch parseHackerspaceDataModel(json, name: name, url: url) {
//            case .Some(let p): return Result(value: p)
//            case .None : return Result(error: SpaceAPIError.ParseError)
//        }
//    }
//
//    static func getParsedHackerspace(url: String, name: String, fromCache cache: Bool = true) -> Future<ParsedHackerspaceData, SpaceAPIError> {
//        return loadHackerspaceData(url, fromCache: cache).flatMap { dict in parseHackerspace(dict, url: url, name: name)}
//
//    }
//}
//>>>>>>> errors handled by enum, clean up unnecessary code
