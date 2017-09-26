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

    var presetName: String?
    var presetURL: String?

    @IBAction func confirmAdd(sender: UIButton) {
        guard let n = endpointName.text else {
            return print("name can't be empty")
        }
        guard let u = endpointURL.text else {
            return print("url can't be empty")
        }
        confirm(n, u)
        self.navigationController?.popViewController(animated: true)
    }

    var confirm: (String, String) -> () = { (newName, newURL) in
        SharedData.addCustomEndpoint(name: newName, url: newURL)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = Theme.conditionalBackgroundColor
        endpointName.text = presetName
        endpointURL.text = presetURL
    }
}
