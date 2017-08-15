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
    static let mockAPIResponse = ["open": openEndpoint, "closed": closedEndpoint]
    static let openHackerspaceAPI = ParsedHackerspaceData.init(apiVersion: "0.13",
                                                               apiEndpoint: openEndpoint,
                                                               apiName: "open",
                                                               name: "Open Hackerspace",
                                                               logoURL: "", websiteURL: "",
                                                               state: StateObject(open: true, lastChange: nil, trigger_person: nil, message: "The space is open", icon: nil),
                                                               location: SpaceLocation.init(name: "Open Hackerspace", address: nil, location: CLLocationCoordinate2D.init(latitude: 0, longitude: 0)),
                                                               contact: ContactObject.init(),
                                                               issue_report_channel: [])
    static let closedHackerspaceAPI = ParsedHackerspaceData.init(apiVersion: "0.13",
                                                               apiEndpoint: openEndpoint,
                                                               apiName: "closed",
                                                               name: "Closed Hackerspace",
                                                               logoURL: "", websiteURL: "",
                                                               state: StateObject(open: false, lastChange: nil, trigger_person: nil, message: "The space is closed", icon: nil),
                                                               location: SpaceLocation.init(name: "Closed Hackerspace", address: nil, location: CLLocationCoordinate2D.init(latitude: 10, longitude: 10)),
                                                               contact: ContactObject.init(),
                                                               issue_report_channel: [])
    static let mockHackerspaceData = [openEndpoint : openHackerspaceAPI.asJSON.asObject!,
                                      closedEndpoint: closedHackerspaceAPI.asJSON.asObject!]
}
