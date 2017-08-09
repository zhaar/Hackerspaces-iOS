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

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let favoriteTableViewIndex = 0
    let searchTableViewIndex = 2

    let preferencesDataSource: () -> Future<[String: SharedData.HackerspaceAPIURL], SpaceAPIError> = {

        Future(value: SharedData.favoritesDictionary())
            .promoteError()
            .onSuccess(callback: SharedData.updateIconShortcuts)
    }

    func getHackerspaceTableFromViewController(_ viewController: UIViewController?) -> HackerspaceBaseTableViewController? {

        if let nav = viewController as? UINavigationController {
            return nav.childViewControllers.map {$0 as? HackerspaceBaseTableViewController}.filter {$0 != nil}[0]
        } else {
            return nil
        }
    }

    func setDataSourceForView(_ viewController: UIViewController?, dataSource: @escaping () -> Future<[String: String], SpaceAPIError>) {

        getHackerspaceTableFromViewController(viewController)?.dataSource = dataSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setDataSourceForView(self.viewControllers?[0], dataSource: preferencesDataSource)
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch self.viewControllers?.index(of: viewController) {
        case .some(favoriteTableViewIndex): setDataSourceForView(self.viewControllers?[favoriteTableViewIndex], dataSource: preferencesDataSource)
        case .some(searchTableViewIndex): setDataSourceForView(self.viewControllers?[searchTableViewIndex], dataSource: {_ in SpaceAPI.loadHackerspaceList(fromCache: false) })
        case _: ()
        }
    }
}
