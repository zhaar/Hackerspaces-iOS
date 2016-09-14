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

enum SpaceAPIError: Error {
    case parseError(String)
    case dataCastError(data: Data)
    case unknownError(error: Error)
    case httpRequestError(error: Error)
}

enum UIConstants: String {
    case AnnotationViewReuseIdentifier = "spaceLocation"
    case SpaceIsOpenMark = "⚫︎"
    case favoriteHSCellReuseIdentifier = "FavoriteHSCell"
    case showHSSearch = "ShowHackerspaceFromSearch"
    case showHSMap = "ShowHackerspaceFromMap"
    case showHSFavorite = "ShowHackerspaceFromFavoriteList"
    case showHSResult = "ShowhackerspaceFromResult"
    case hackerspaceViewShortcut = "moe.zephyz.hackerspaces.hackerspace_view_shortcut"
    case searchViewShortcut = "moe.zephyz.hackerspaces.search_shortcut"
    case showErrorDetail = "ShowErrorDetail"
}
