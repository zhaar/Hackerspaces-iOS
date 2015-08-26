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

class SpaceLocation {
    let name: String
    let address: String?
    let location: CLLocationCoordinate2D
    init(name: String, address: String?, location: CLLocationCoordinate2D) {
        self.name = name
        self.location = location
        self.address = address
    }
}


//extension SpaceLocation : MKAnnotation {
//    var coordinate: CLLocationCoordinate2D {
//        return self.location
//    }
//    var title: String {
//        return self.name
//    }
//    var subtitle: String = ""
//}

func fromListToFuture<T,U>(list: [Future<T,U>]) -> Future<[T], U> {
    return BrightFutures.sequence(list)
}

struct SpaceAPI {
    
    static func loadAPI() -> Future<[String : String], NSError> {
        let p = Promise<[String: String], NSError>()
        Queue.global.async {
            let req = HTTPTask()
            req.GET(SpaceAPIConstants.API, parameters: nil) { (response: HTTPResponse) in
                if let data = response.responseObject as? NSData {
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
                } else {
                    p.failure(NSError(domain: "HTTP request data cast error", code: 125, userInfo: nil))
                }
            }
        }
        return p.future
    }
    
    static func loadHackerspaceAPI(url: String) -> Future<[String : JSONDecoder], NSError> {
        let p = Promise<[String: JSONDecoder], NSError>()
        Queue.global.async {
            let req = HTTPTask()
            req.GET(url, parameters: nil) {(response: HTTPResponse) in
                if let err = response.error {
                    p.failure(err)
                } else if let data = response.responseObject as? NSData {
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
    
    static func isSpaceOpen(json: [String: JSONDecoder]) -> Bool {
        return json["state"]?.dictionary?["open"]?.bool ?? false
    }
    
    static func extractName(json: [String: JSONDecoder]) -> String {
        return json[SpaceAPIConstants.APIname]!.string!
    }
    
    static func extractLocationInfo(json: [String: JSONDecoder]) -> SpaceLocation? {
        let location = json[SpaceAPIConstants.APIlocation]?.dictionary
        let lat = location?["lat"]?.number >>- {CLLocationDegrees($0)}
        let lon = location?["lon"]?.number >>- {CLLocationDegrees($0)}
        let loc = lat >>- {la in lon >>- { lo in CLLocation(latitude: la, longitude: lo)}}
        return loc >>- {SpaceLocation(name: self.extractName(json), address: location?["address"]?.string, location: $0)}
    }
    
    static func getHackerspaceLocation(url: String) -> Future<SpaceLocation?, NSError> {
        return loadHackerspaceAPI(url).map { self.extractLocationInfo($0) }
    }
    
    static func getHackerspaceLocations() -> Future<[SpaceLocation?], NSError> {
        let apiLinks = loadAPI().map { $0.values.array }
        let hackerspaceJSONs = apiLinks.flatMap { url in BrightFutures.sequence(url.map(self.loadHackerspaceAPI)) }
        return hackerspaceJSONs.map { $0.map(self.extractLocationInfo) }
    }
}