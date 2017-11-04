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
        guard let n = endpointName.text, !n.isEmpty else {
            self.displayAlert(alertTitle: R.string.localizable.custom_Endpoint(),
                              message: R.string.localizable.customNameCantBeEmpty(),
                              buttonTitle: nil)
            return
        }
        guard let u = endpointURL.text, !u.isEmpty else {
            self.displayAlert(alertTitle: R.string.localizable.custom_Endpoint(),
                              message: R.string.localizable.customURLCantBeEmpty(),
                              buttonTitle: nil)
            return
        }
        confirm(n, u)
        self.navigationController?.popViewController(animated: true)
    }

    var confirm: (String, String) -> () = { _,_  in fatalError("confirmation call back not set") }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = Theme.conditionalBackgroundColor
        endpointName.text = presetName
        endpointURL.text = presetURL
    }
}
