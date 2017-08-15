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
import JSONWrapper

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

func parseHackerspaceDataModel(json: [String: JSONValue], name apiName: String, url: String) -> ParsedHackerspaceData? {

    if
        let apiVersion = json[SpaceAPIConstants.APIversion.rawValue]?.asString,
        let name = json[SpaceAPIConstants.APIname.rawValue]?.asString,
        let logo = json[SpaceAPIConstants.APIlogo.rawValue]?.asString,
        let websiteURL = json[SpaceAPIConstants.APIurl.rawValue]?.asString,
        let state = json[SpaceAPIConstants.APIstate.rawValue]?.asObject >>- parseStateObject,
        let location = json[SpaceAPIConstants.APIlocation.rawValue]?.asObject >>- { loc in
            name >>- { n in parseLocationObject(loc, withName: n) } },
        let contact = json[SpaceAPIConstants.APIcontact.rawValue]?.asObject >>- parseContactObject,
        let reportChannel = json[SpaceAPIConstants.APIreport.rawValue]?.asArray >>-  parseReportChannel {

        return ParsedHackerspaceData(apiVersion: apiVersion,
                                     apiEndpoint: url,
                                     apiName: apiName,
                                     name: name,
                                     logoURL: logo,
                                     websiteURL: websiteURL,
                                     state: state,
                                     location: location,
                                     contact: contact,
                                     issue_report_channel: reportChannel)
    } else { return nil }

}

private func parseStateObject(_ state: [String: JSONValue]) -> StateObject {

    let o = state[JSONKeys.open]
    var isOpen: Bool? = o?.asBool
    isOpen = isOpen ?? (o?.asInt.map(==1))
    isOpen = isOpen ?? (o?.asString.map({ $0 == JSONKeys.open || $0 == "1" }))
    let open = isOpen ?? false
    let lastChange = state[JSONKeys.lastchange]?.asInt
    let trigger = state[JSONKeys.trigger_person]?.asString
    let icon = state[JSONKeys.icon]?.asObject.flatMap(parseIconObject)
    let message = state[JSONKeys.message]?.asString
    return StateObject(open: open, lastChange: lastChange, trigger_person: trigger, message: message, icon: icon)
}

private func parseIconObject(_ icon: [String : JSONValue]) -> IconObject? {

    guard let open = icon[JSONKeys.open]?.asString,
        let closed = icon[JSONKeys.closed]?.asString else { return nil }

    return IconObject(openURL: open, closedURL: closed)

}

func parseLocationObject(_ location: [String : JSONValue], withName name: String) -> SpaceLocation? {
    let lat = location[JSONKeys.lat]?.asFloat >>- CLLocationDegrees.init
    let lon = location[JSONKeys.lon]?.asFloat >>- CLLocationDegrees.init
    let loc = lat >>- { la in lon >>- { lo in CLLocationCoordinate2D(latitude: la, longitude: lo) } }
    let addr = location[JSONKeys.address]?.asString
    return loc >>- { SpaceLocation(name: name, address: addr, location: $0) }
}

private func parseContactObject(_ contact: [String: JSONValue]) -> ContactObject {
    let keymasters = contact[JSONKeys.keymasters]?.asArray >>- parseKeymasters
    return ContactObject(phone: contact[JSONKeys.phone]?.asString,
                         sip: contact[JSONKeys.sip]?.asString,
                         keyMasters: keymasters,
                         ircURL: contact[JSONKeys.irc]?.asString,
                         twitterHandle: contact[JSONKeys.twitter]?.asString,
                         facebook: contact[JSONKeys.facebook]?.asString,
                         googlePlus: contact[JSONKeys.google]?.asObject?[JSONKeys.plus]?.asString,
                         identica: contact[JSONKeys.identica]?.asString,
                         foursquareID: contact[JSONKeys.foursquare]?.asString,
                         email: contact[JSONKeys.email]?.asString,
                         mailingList: contact[JSONKeys.ml]?.asString,
                         jabber: contact[JSONKeys.jabber]?.asString,
                         issue_mail: contact[JSONKeys.issue_mail]?.asString)
}

private func parseKeymasters(_ keymasters: [JSONValue]) -> [MemberObject] {
    let members: [MemberObject?] =  keymasters.map { $0.asObject.map(parseMember) }
    return Array(members.joined())
}

private func parseMember(_ member: [String: JSONValue]) -> MemberObject {
    return MemberObject(name: member[JSONKeys.name]?.asString,
                        irc_nick: member[JSONKeys.irc_nick]?.asString,
                        phone: member[JSONKeys.phone]?.asString,
                        email: member[JSONKeys.email]?.asString,
                        twitterHandle: member[JSONKeys.twitter]?.asString)
}

private func parseReportChannel(_ channels: [JSONValue]) -> [String] {
    return channels.flatMap { $0.asString }
}

extension ParsedHackerspaceData: JSONValueConvertible {
    var asJSON: JSONValue {
        return JSONValue.object([
            SpaceAPIConstants.APIversion.rawValue: .string(self.apiVersion),
            SpaceAPIConstants.APIname.rawValue: .string(self.name),
            SpaceAPIConstants.APIlogo.rawValue: .string(self.logoURL),
            SpaceAPIConstants.APIurl.rawValue: .string(self.websiteURL),
            SpaceAPIConstants.APIstate.rawValue: self.state.asJSON,
            SpaceAPIConstants.APIlocation.rawValue: self.location.toLocation.asJSON,
            SpaceAPIConstants.APIcontact.rawValue: self.contact.asJSON,
            SpaceAPIConstants.APIreport.rawValue: .array(self.issue_report_channel.map({$0.asJSON}))
            ])
    }
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

extension LocationObject: JSONValueConvertible {
    var asJSON: JSONValue {
        return JSONValue.object([JSONKeys.lat: .float(self.latitude),
                                 JSONKeys.lon: .float(self.longitude),
                                 JSONKeys.address: self.address.map {.string($0)} ?? .null])
    }
}

struct StateObject {
    let open: Bool
    let lastChange: Int?
    let trigger_person: String?
    let message: String?
    let icon: IconObject?
}

extension StateObject: JSONValueConvertible {
    var asJSON: JSONValue {
        return JSONValue.object([JSONKeys.open: .bool(self.open),
                                 JSONKeys.lastchange: self.lastChange.map({JSONValue.float(Float($0))}) ?? .null,
                                 JSONKeys.trigger_person: self.trigger_person.map {JSONValue.string($0)} ?? .null,
                                 JSONKeys.message: self.message.map {.string($0)} ?? .null,
                                 JSONKeys.icon: self.icon?.asJSON ?? .null])
    }
}

struct IconObject {
    let openURL: String
    let closedURL: String
}

extension IconObject: JSONValueConvertible {
    var asJSON: JSONValue {
        return JSONValue.object([JSONKeys.open: .string(self.openURL),
                                 JSONKeys.closed: .string(self.closedURL)])
    }
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
    init(phone: String? = nil,
         sip: String? = nil,
         keyMasters: [MemberObject]? = nil,
         ircURL: String? = nil,
         twitterHandle: String? = nil,
         facebook: String? = nil,
         googlePlus: String? = nil,
         identica: String? = nil,
         foursquareID: String? = nil,
         email: String? = nil,
         mailingList: String? = nil,
         jabber: String? = nil,
         issue_mail: String? = nil
        ) {
        self.phone = phone
        self.sip = sip
        self.keyMasters = keyMasters
        self.ircURL = ircURL
        self.twitterHandle = twitterHandle
        self.facebook = facebook
        self.googlePlus = googlePlus
        self.identica = identica
        self.foursquareID = foursquareID
        self.email = email
        self.mailingList = mailingList
        self.jabber = jabber
        self.issue_mail = issue_mail
    }
}

extension ContactObject: JSONValueConvertible {
    var asJSON: JSONValue {
        let fields: [(String, JSONValue)?] = [
            phone.map { (JSONKeys.phone, .string($0)) },
                      sip.map { (JSONKeys.sip, .string($0)) },
                      keyMasters.map { (JSONKeys.keymasters, .array($0.map({$0.asJSON}))) },
                      ircURL.map { (JSONKeys.irc, .string($0)) },
                      twitterHandle.map { (JSONKeys.twitter, .string($0)) },
                      facebook.map { (JSONKeys.facebook, $0.asJSON) },
                      googlePlus.map { (JSONKeys.google, $0.asJSON) },
                      identica.map { (JSONKeys.identica, $0.asJSON) },
                      foursquareID.map { (JSONKeys.foursquare, $0.asJSON) },
                      email.map { (JSONKeys.email, $0.asJSON) },
                      mailingList.map { (JSONKeys.ml, $0.asJSON) },
                      jabber.map { (JSONKeys.jabber, $0.asJSON) },
                      issue_mail.map { (JSONKeys.issue_mail, $0.asJSON) }
            ]
        return .object(tuplesAsDict(fields.flatMap(identity)))
    }
}

struct MemberObject {
    let name: String?
    let irc_nick: String?
    let phone: String?
    let email: String?
    let twitterHandle: String?
}

extension MemberObject: JSONValueConvertible {
    var asJSON: JSONValue {
        let values = [JSONKeys.name: name,
                      JSONKeys.irc_nick: irc_nick,
                      JSONKeys.phone: phone,
                      JSONKeys.email: email,
                      JSONKeys.twitter: twitterHandle].mapMaybe({value in value.flatMap({$0.asJSON})})
        return JSONValue.object(values)
    }
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
