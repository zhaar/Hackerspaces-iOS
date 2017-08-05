//
//  HackerspaceDataModel.swift
//  Hackerspaces
//
//  Created by zephyz on 29/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import Swiftz
import MapKit

enum JSONKeys {
    static let open = "open"
    static let closed = "closed"
    static let lastchange = "lastchange"
    static let trigger_person = "trigger_person"
    static let icon = "icon"
    static let message = "message"
    //location
    static let lat = "lat"
    static let lon = "lon"
    static let address = "address"
    //contact
    static let keymasters = "keymasters"
    static let phone = "phone"
    static let sip = "sip"
    static let irc = "irc"
    static let twitter = "twitter"
    static let facebook = "facebook"
    static let google = "google"
    static let plus = "plus"
    static let identica = "identica"
    static let foursquare = "foursquare"
    static let email = "email"
    static let ml = "ml"
    static let jabber = "jabber"
    static let issue_mail = "issue_mail"
    //member
    static let name = "name"
    static let irc_nick = "irc_nick"
}

func parseHackerspaceDataModel(json: [String: JSONDecoder], name apiName: String, url: String) -> ParsedHackerspaceData? {

    if
        let apiVersion = json[SpaceAPIConstants.APIversion.rawValue]?.string,
        let name = SpaceAPI.extractName(json),
        let logo = json[SpaceAPIConstants.APIlogo.rawValue]?.string,
        let websiteURL = json[SpaceAPIConstants.APIurl.rawValue]?.string,
        let state = json[SpaceAPIConstants.APIstate.rawValue]?.dictionary >>- parseStateObject,
        let location = json[SpaceAPIConstants.APIlocation.rawValue]?.dictionary >>- { loc in name >>- {n in parseLocationObject(loc, withName: n) } },
        let contact = json[SpaceAPIConstants.APIcontact.rawValue]?.dictionary >>- parseContactObject,
        let reportChannel = json[SpaceAPIConstants.APIreport.rawValue]?.array >>-  parseReportChannel {

        return ParsedHackerspaceData(apiVersion: apiVersion,
                                     apiEndpoint: url,
                                     apiName: apiName,
                                     name: name,
                                     logoURL: logo,
                                     websiteURL: websiteURL,
                                     state: state, location: location,
                                     contact: contact,
                                     issue_report_channel: reportChannel)
    } else { return nil }

}

private func parseStateObject(_ state: [String: JSONDecoder]) -> StateObject {
    let o = state[JSONKeys.open]
    var isOpen: Bool? = o?.bool
    isOpen = isOpen ?? (o?.number == 1)
    isOpen = isOpen ?? (o?.string == JSONKeys.open)
    let open = isOpen ?? false
    let lastChange = state[JSONKeys.lastchange]?.number
    let trigger = state[JSONKeys.trigger_person]?.string
    let icon = state[JSONKeys.icon]?.dictionary.flatMap(parseIconObject)
    let message = state[JSONKeys.message]?.string
    return StateObject(open: open, lastChange: lastChange?.intValue, trigger_person: trigger, message: message, icon: icon)
}

private func parseIconObject(_ icon: [String : JSONDecoder]) -> IconObject? {

    guard let open = icon[JSONKeys.open]?.string,
        let closed = icon[JSONKeys.closed]?.string else { return nil }

    return IconObject(openURL: open, closedURL: closed)

}

func parseLocationObject(_ location: [String : JSONDecoder], withName name: String) -> SpaceLocation? {
    let lat = location[JSONKeys.lat]?.number >>- CLLocationDegrees.init
    let lon = location[JSONKeys.lon]?.number >>- CLLocationDegrees.init
    let loc = lat >>- {la in lon >>- { lo in CLLocationCoordinate2D(latitude: la, longitude: lo)}}
    let addr = location[JSONKeys.address]?.string
    return loc >>- {SpaceLocation(name: name, address: addr, location: $0)}
}

private func parseContactObject(_ contact: [String: JSONDecoder]) -> ContactObject {
    let keymasters = contact[JSONKeys.keymasters]?.array >>- parseKeymasters
    return ContactObject(phone: contact[JSONKeys.phone]?.string,
                         sip: contact[JSONKeys.sip]?.string,
                         keyMasters: keymasters,
                         ircURL: contact[JSONKeys.irc]?.string,
                         twitterHandle: contact[JSONKeys.twitter]?.string,
                         facebook: contact[JSONKeys.facebook]?.string,
                         googlePlus: contact[JSONKeys.google]?.dictionary?[JSONKeys.plus]?.string,
                         identica: contact[JSONKeys.identica]?.string,
                         foursquareID: contact[JSONKeys.foursquare]?.string,
                         email: contact[JSONKeys.email]?.string,
                         mailingList: contact[JSONKeys.ml]?.string,
                         jabber: contact[JSONKeys.jabber]?.string,
                         issue_mail: contact[JSONKeys.issue_mail]?.string)
}

private func parseKeymasters(_ keymasters: [JSONDecoder]) -> [MemberObject] {
    let members: [MemberObject?] =  keymasters.map {$0.dictionary.map(parseMember)}
    return Array(members.joined())
}

private func parseMember(_ member: [String: JSONDecoder]) -> MemberObject {
    return MemberObject(name: member[JSONKeys.name]?.string,
                        irc_nick: member[JSONKeys.irc_nick]?.string,
                        phone: member[JSONKeys.phone]?.string,
                        email: member[JSONKeys.email]?.string,
                        twitterHandle: member[JSONKeys.twitter]?.string)
}

private func parseReportChannel(_ channels: [JSONDecoder]) -> [String] {
    return channels.flatMap { $0.string }
}

struct ParsedHackerspaceData {
    let apiVersion: String
    let apiEndpoint: String
    let apiName: String
    let name: String
    let logoURL: String
    let websiteURL: String
    let state: StateObject
    let location: SpaceLocation
    let contact: ContactObject
    let issue_report_channel: [String]
    let cam: [String]? = nil
    let spaceFed: SpaceFedObject? = nil
    let events: [eventObject]? = nil
    let projects: String? = nil
    var apiInfo: (name: String, url: String) {
        return (name: apiName, url: apiEndpoint)
    }
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
