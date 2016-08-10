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
        setDataSourceForView(self.viewControllers?[0], dataSource: {_ in future(SharedData.sharedInstance.favoritesDictionary).promoteError()})
    }
    
    func setDataSourceForView(nav: UIViewController?, dataSource: () -> Future<[String: String], NSError>) {
        if let n = nav as? UINavigationController {
            let s = n.childViewControllers.map {$0 as? HackerspaceBaseTableViewController}.filter {$0 != nil}[0]
            if let searchVC = s {
                searchVC.dataSource = dataSource
            }
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        switch self.viewControllers?.indexOf(viewController) {
            case .Some(0): setDataSourceForView(self.viewControllers?[0], dataSource: {_ in future(SharedData.sharedInstance.favoritesDictionary).promoteError()})
            case .Some(2): setDataSourceForView(self.viewControllers?[2], dataSource: SpaceAPI.loadAPIFromWeb)
            case _: ()
        }
    }
    
    
}
