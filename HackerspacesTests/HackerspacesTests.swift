//
//  HackerspacesTests.swift
//  HackerspacesTests
//
//  Created by zephyz on 05/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit
import XCTest

class HackerspacesTests: XCTestCase {

    func testJSONParsing() {
        // This is an example of a functional test case.
        let json = "{\"state\": {\"ext_duration\": 0, \"lastchange\": 1501290658.0, \"open\": false, \"message\": \"The space is closed.\", \"icon\": {\"open\": \"https://fixme.ch/sites/default/files/logo-open.png\", \"closed\": \"https://fixme.ch/sites/default/files/logo-closed.png\"}}, \"api\": \"0.13\", \"location\": {\"lat\": 46.532372, \"lon\": 6.591292, \"address\": \"Chemin du Closel 5, 1020 Renens, Switzerland\"}, \"space\": \"FIXME\", \"url\": \"https://fixme.ch\", \"logo\": \"https://fixme.ch/sites/default/files/Logo5_v3-mini.png\", \"feeds\": {\"blog\": {\"url\": \"https://fixme.ch/rss.xml\", \"type\": \"rss\"}, \"wiki\": {\"url\": \"https://fixme.ch/w/index.php?title=Special:RecentChanges&feed=atom\", \"type\": \"rss\"}, \"calendar\": {\"url\": \"https://www.google.com/calendar/ical/sruulkb8vh28dim9bcth8emdm4%40group.calendar.google.com/public/basic.ics\", \"type\": \"ical\"}}, \"issue_report_channels\": [\"email\", \"twitter\"], \"sensors\": {\"people_now_present\": [{\"unit\": \"device(s)\", \"value\": 0, \"description\": \"Number of devices in the DHCP range\"}], \"total_member_count\": [{\"unit\": \"premium members\", \"value\": 46}, {\"unit\": \"standard members\", \"value\": 65}, {\"unit\": \"total members\", \"value\": 111}]}, \"contact\": {\"wiki\": \"https://wiki.fixme.ch\", \"phone\": \"+41216220734\", \"facebook\": \"https://www.facebook.com/fixmehackerspace\", \"chat\": \"https://chat.fixme.ch\", \"ml\": \"hackerspace-lausanne@lists.saitis.net\", \"twitter\": \"@_fixme\", \"irc\": \"irc://freenode/#fixme\", \"email\": \"info@fixme.ch\", \"keymaster\": [\"+41797440880\"]}}"
        let dictionary = JSONDecoder.init(json).dictionary
        let parsed = parseHackerspaceDataModel(json: dictionary!, name: "fixme", url: "")
        XCTAssertNotNil(parsed)
        let data = parsed!
        XCTAssertEqual(data.name, "FIXME")
        XCTAssertEqual(data.state.open, false)
        XCTAssert(true, "Pass")
    }

}
