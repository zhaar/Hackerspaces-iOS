//
//  HackerspaceDataModel.swift
//  Hackerspaces
//
//  Created by zephyz on 29/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import JSONJoy
import Swiftz

func parseHackerspaceDataModel(json: [String: JSONDecoder]) -> HackerspaceDataModel? {
    let apiVersion = json[SpaceAPIConstants.APIversion.rawValue]?.string
    let name = SpaceAPI.extractName(json)
    let logo = json[SpaceAPIConstants.APIlogo.rawValue]?.string
    let websiteURL = json[SpaceAPIConstants.APIurl.rawValue]?.string
    let state = json[SpaceAPIConstants.APIstate.rawValue]?.dictionary >>- { parseStateObject($0) }
    let location = json[SpaceAPIConstants.APIlocation.rawValue]?.dictionary >>- { parseLocationObject($0) }
    let contact = json[SpaceAPIConstants.APIcontact.rawValue]?.dictionary >>- { parseContactObject($0) }
    let reportChannel = json[SpaceAPIConstants.APIreport.rawValue]?.array >>- { parseReportChannel($0) }
    if (apiVersion == nil) || (logo == nil) || (logo == nil) || (websiteURL == nil) || (location == nil) || (contact == nil) || (reportChannel == nil) || (state == nil){
        return nil
    } else {
        return HackerspaceDataModel(api: apiVersion!, name: name, logoURL: logo!, websiteURL: websiteURL!, state: state!, location: location!, contact: contact!, issue_report_channel: reportChannel!)
    }
}

private func parseStateObject(state: [String: JSONDecoder]) -> StateObject {
    let o = state["open"]
    var isOpen: Bool? = o?.bool
    isOpen = isOpen ?? (o?.number == 1)
    isOpen = isOpen ?? (o?.string == "open")
    let open = isOpen ?? false
    let lastChange = state["lastchange"]?.number
    let trigger = state["trigger_person"]?.string
    let icon = parseIconObject(state["icon"]?.dictionary)
    let message = state["message"]?.string
    return StateObject(open: open, lastChange: lastChange?.integerValue, trigger_person: trigger, message: message, icon: icon)
}

private func parseIconObject(icon: [String : JSONDecoder]?) -> IconObject? {
    return icon >>- { json in json["open"]?.string >>- { open in json["closed"]?.string >>- { closed in IconObject(openURL: open, closedURL: closed)}}}
}

private func parseLocationObject(location: [String : JSONDecoder]) -> LocationObject? {
    let lat = location["lat"]?.number
    let lon = location["lon"]?.number
    let addr = location["address"]?.string
    if lat == nil || lon == nil {
        return nil
    } else {
        return LocationObject(latitude: lat!.floatValue, longitude: lon!.floatValue, address: addr)
    }
}

private func parseContactObject(contact: [String: JSONDecoder]) -> ContactObject {
    let keymasters = contact["keymasters"]?.array >>- { parseKeymasters($0) }
    return ContactObject(phone: contact["phone"]?.string, sip: contact["sip"]?.string, keyMasters: keymasters, ircURL: contact["irc"]?.string, twitterHandle: contact["twitter"]?.string, facebook: contact["facebook"]?.string, googlePlus: contact["google"]?.dictionary?["plus"]?.string, identica: contact["identica"]?.string, foursquareID: contact["foursquare"]?.string, email: contact["email"]?.string, mailingList: contact["ml"]?.string, jabber: contact["jabber"]?.string, issue_mail: contact["issue_mail"]?.string)
}

private func parseKeymasters(keymasters: [JSONDecoder]) -> [MemberObject] {
    let members: [MemberObject?] =  keymasters.map {$0.dictionary.map(parseMember)}
    return Array(members.flatten())
}

private func parseMember(member: [String: JSONDecoder]) -> MemberObject {
    return MemberObject(name: member["name"]?.string, irc_nick: member["irc_nick"]?.string, phone: member["phone"]?.string, email: member["email"]?.string, twitterHandle: member["twitter"]?.string)
}

private func parseReportChannel(channels: [JSONDecoder]) -> [String] {
    return channels.map { json in
        json.string
        }.filter { $0 != nil }.map { $0! }
}

struct HackerspaceDataModel {
    let api: String
    let name: String
    let logoURL: String
    let websiteURL: String
    let state: StateObject
    let location: LocationObject
    let contact: ContactObject
    let issue_report_channel: [String]
    let cam: [String]? = nil
    let spaceFed: SpaceFedObject? = nil
    let events: [eventObject]? = nil
    let projects: String? = nil
    //missing
    //let sensors: 
    //let feeds:
    //let cache
    //let 
}

struct LocationObject {
    let latitude: Float
    let longitude: Float
    let address: String?
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