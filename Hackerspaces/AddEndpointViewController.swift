//
//  AddEndpointViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 24.09.17.
//  Copyright © 2017 Fixme. All rights reserved.
//

import UIKit

class AddEndpointViewController: UIViewController {

    @IBOutlet var endpointName: UITextField!
    @IBOutlet var endpointURL: UITextField!
    @IBAction func confirmAdd(sender: UIButton) {
        guard let n = endpointName.text else {
            return print("name can't be empty")
        }
        guard let u = endpointURL.text else {
            return print("url can't be empty")
        }
        SharedData.addCustomEndpoint(name:n, url: u)
        self.navigationController?.popViewController(animated: true)
    }

}
