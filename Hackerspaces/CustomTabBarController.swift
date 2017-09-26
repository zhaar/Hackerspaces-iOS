//
//  CustomTabBarController.swift
//  Hackerspaces
//
//  Created by zephyz on 08/08/16.
//  Copyright © 2016 Fixme. All rights reserved.
//

import UIKit
import BrightFutures
import Result
import Swiftz

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let favoriteTableViewIndex = 0
    let searchTableViewIndex = 2

    func preferencesDataSource() -> Future<[(String, SharedData.HackerspaceAPIURL)], SpaceAPIError> {

        return Future(value: SharedData.favoritesDictionary())
            .promoteError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        tabBarController(self, didSelect: (self.viewControllers?[0])!)
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let nav = viewController as? UINavigationController
        let hackerspacesLists = nav?.childViewControllers.flatMap {$0 as? HackerspaceBaseTableViewController}
        switch hackerspacesLists?.first {
        case let vc? as FavoriteHackerspaceTableViewController?:
            vc.dataSource = preferencesDataSource
            vc.refreshCustomEndpoints()
            vc.refreshHackerspaces()
        case let vc? :
            vc.dataSource = { SpaceAPI.loadHackerspaceList(fromCache: false) }
        case .none:
            break
        }

    }
}
