//
//  TestingUtils.swift
//  Hackerspaces
//
//  Created by zephyz on 13.08.17.
//  Copyright © 2017 Fixme. All rights reserved.
//

import Foundation
import MapKit

public enum Testing {
    static public func isTestingUI() -> Bool {
        return ProcessInfo.processInfo.arguments.contains("UI-TESTING")
    }

    static let closedEndpoint = "closedHackerspaceAPIEndpoint"
    static let openEndpoint = "openHackerspaceAPIEndpoint"
    static let mockAPIResponse = [("open", openEndpoint), ("closed", closedEndpoint)]
    static let openHackerspaceAPI = HackerspaceData.init(api: "13.0",
                                                         space: "Open Hackerspace",
                                                         logo: "",
                                                         url: "",
                                                         location: LocationData.init(address: nil, lat: 0, lon: 0),
                                                         spacefed: nil,
                                                         cam: nil,
                                                         state: StateData(open: true, lastchange: nil, trigger_person: nil, message: "The space is open", icon: nil),
                                                         events: nil,
                                                         contact: ContactData.init())

    static let closedHackerspaceAPI = HackerspaceData.init(api: "13.0",
                                                           space: "Closed Hackerspace",
                                                           logo: "",
                                                           url: "",
                                                           location: LocationData.init(address: nil, lat: 0, lon: 0),
                                                           spacefed: nil,
                                                           cam: nil,
                                                           state: StateData(open: false, lastchange: nil, trigger_person: nil, message: "The space is closed", icon: nil),
                                                           events: nil,
                                                           contact: ContactData.init())

    static var  mockHackerspaceData: [(String, Data)] {
        let openEncoded = try! JSONEncoder().encode(openHackerspaceAPI)
        let closedEncoded = try! JSONEncoder().encode(closedHackerspaceAPI)

        return [(openEndpoint, openEncoded),
                (closedEndpoint, closedEncoded)]
    }
}
