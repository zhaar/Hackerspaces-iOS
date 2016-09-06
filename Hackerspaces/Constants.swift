//
//  Constants.swift
//  Hackerspaces
//
//  Created by zephyz on 29/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation

enum SpaceAPIConstants : String {
    case SpaceAPI = "https://spaceapi.net/directory.json"
    case FIXMEAPI = "https://spaceapi.fixme.ch/directory.json"
    case customAPIPrefix = "ext_"
    case APIlocation = "location"
    case APIversion = "api"
    case APIname = "space"
    case APIlogo = "logo"
    case APIurl = "url"
    case APIstate = "state"
    case APIcontact = "contact"
    case APIreport = "issue_report_channels"
}

enum ParseErrorType {
    static let errorCode = -1
    static let errorMessage = "Parse error"
}

enum HTTPGetCastError {
    static let errorCode = 123
    static let errorMessage = "HTTP GET data cast"
}

struct UIConstants {
    static let AnnotationViewReuseIdentifier = "spaceLocation"
    static let SpaceIsOpenMark = "⚫︎"
    static let favoriteHSCellReuseIdentifier = "FavoriteHSCell"
    static let showHSSearch = "ShowHackerspaceFromSearch"
    static let showHSMap = "ShowHackerspaceFromMap"
    static let showHSFavorite = "ShowHackerspaceFromFavoriteList"
    static let showHSResult = "ShowhackerspaceFromResult"
    static let hackerspaceViewShortcut = "moe.zephyz.hackerspaces.hackerspace_view_shortcut"
    static let searchViewShortcut = "moe.zephyz.hackerspaces.search_shortcut"
}