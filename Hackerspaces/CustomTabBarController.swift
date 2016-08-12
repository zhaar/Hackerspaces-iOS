//
//  CustomTabBarController.swift
//  Hackerspaces
//
//  Created by zephyz on 08/08/16.
//  Copyright © 2016 Fixme. All rights reserved.
//

import UIKit
import BrightFutures

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let favoriteTableViewIndex = 0
    let searchTableViewIndex = 2
    let preferencesDataSource: () -> Future<[String: String], NSError> = {_ in future(SharedData.favoritesDictionary).onSuccess(callback: SharedData.updateIconShortcuts).promoteError()}
    
    func getHackerspaceTableFromViewController(viewController: UIViewController?) -> HackerspaceBaseTableViewController? {
        if let nav = viewController as? UINavigationController {
            return nav.childViewControllers.map {$0 as? HackerspaceBaseTableViewController}.filter {$0 != nil}[0]
        } else {
            return nil
        }
    }
    
    func setDataSourceForView(viewController: UIViewController?, dataSource: () -> Future<[String: String], NSError>) {
        getHackerspaceTableFromViewController(viewController)?.dataSource = dataSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setDataSourceForView(self.viewControllers?[0], dataSource: preferencesDataSource)
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        switch self.viewControllers?.indexOf(viewController) {
            case .Some(favoriteTableViewIndex): setDataSourceForView(self.viewControllers?[favoriteTableViewIndex], dataSource: preferencesDataSource)
            case .Some(searchTableViewIndex): setDataSourceForView(self.viewControllers?[searchTableViewIndex], dataSource: SpaceAPI.loadAPIFromWeb)
            case _: ()
        }
    }
    
    
}
