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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        func setDataSourceForView(nav: UIViewController?, dataSource: () -> Future<[String: String], NSError>) {
            if let n = nav as? UINavigationController {
                let s = n.childViewControllers[0] as? HackerspaceBaseTableViewController
                if let searchVC = s {
                    searchVC.dataSource = dataSource
                }
            }
        }
        switch self.viewControllers?.indexOf(viewController) {
            case .Some(1) : setDataSourceForView(self.viewControllers?[1], dataSource: future(SharedData.sharedInstance.favoritesDictionary).promoteError)
            case .Some(2) : setDataSourceForView(self.viewControllers?[2], dataSource: SpaceAPI.loadAPIFromWeb)
            case _: ()
        }
    }
    
    
}
