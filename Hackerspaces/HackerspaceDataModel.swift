//
//  HackerspaceDataModel.swift
//  Hackerspaces
//
//  Created by zephyz on 29/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation

struct HackerspaceDataModel {
    let api: String
    let name: String
    let logoURL: String
    let location: LocationObject
    let contact: ContactObject
    let issue_report_channel: [String]
    let cam: [String]?
    let spaceFed: SpaceFedObject?
    let events: [eventObject]?
    let projects: String?
    //missing
    //let sensors: 
    //let feeds:
    //let cache
    //let 
}

struct LocationObject {
    let address: String?
    let latitude: Float
    let longitude: Float
}

struct StateObject {
    let open: Bool
    let lastChange: Int?
    let trigger_person: String?
    let message: String?
    let icon: IconObject?
}

struct IconObject {
    let openURL: String
    let closedURL: String
}

struct ContactObject {
    let phone: String?
    let sip: String?
    let keyMasters: [MemberObject]?
    let ircURL: String?
    let twitterHandle: String?
    let facebook: String?
    let googlePlus: String?
    let identica: String?
    let foursquareID: String?
    let email: String?
    let mailingList: String?
    let jabber: String?
    let issue_mail: String?
}

struct MemberObject {
    let name: String?
    let irc_nick: String?
    let phone: String?
    let email: String?
    let twitterHandle: String?
}

struct SpaceFedObject {
    let spacenet: Bool
    let spacesaml: Bool
    let spacephone: Bool
}

struct eventObject {
    let name: String
    let type: String
    let time: Int
    let extra: String?
}