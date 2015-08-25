//
//  HackerspaceAPIFunctions.swift
//  Hackerspaces
//
//  Created by zephyz on 24/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
//import Swiftz
import JSONJoy
import SwiftHTTP
import BrightFutures

struct SpaceAPIConstants {
    static let API = "spaceapi.net/directory.json"
    static let customAPIPrefix = "ext_"
}


struct HackerspaceAPI {
    
//    var spaceAPI = [String: String]()
    
//    static func reloadAPI() {
//        let request = HTTPTask()
//        request.GET(SpaceAPIConstants.API, parameters: nil, completionHandler: {(response: HTTPResponse) in
//            dispatch_async(dispatch_get_main_queue()) {
//                if let err = response.error {
//                    println("error: \(err.localizedDescription)")
//                } else if let data = response.responseObject as? NSData {
//                    if let dict = JSONDecoder(data).dictionary {
//                        let keys = dict.keys.array
//                        keys.foreach { key in  dict[key]?.string >>- { spaceAPI[key] = $0 }}
//                    }
//                }
//                println(self.spaceAPI.description)
//            }
//        })
//    }
    
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
                        p.failure(NSError(domain: "HTTP request format error", code: 125, userInfo: nil))
                    }
                } else {
                    p.failure(NSError(domain: "HTTP request format error", code: 125, userInfo: nil))
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
    
//    func reload() {
//        let request = HTTPTask()
//        request.GET("https://fixme.ch/cgi-bin/spaceapi.py", parameters: nil) {(response: HTTPResponse) in
//            dispatch_async(dispatch_get_main_queue()) {
//                if let err = response.error {
//                    println("error: \(err.localizedDescription)")
//                } else if let data = response.responseObject as? NSData {
//                    if let dict = JSONDecoder(data).dictionary {
//                        for (k,v) in dict {
////                            self.generalInfo[k] = v
//                        }
////                        self.navigationController?.navigationBar.topItem?.title = dict["space"]?.string
//                    }
////                    self.tableView.reloadData()
//                }
//            }
//        }
//    }
    
}