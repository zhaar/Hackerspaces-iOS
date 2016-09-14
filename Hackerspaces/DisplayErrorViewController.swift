//
//  DisplayErrorViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 14/09/16.
//  Copyright © 2016 Fixme. All rights reserved.
//

import UIKit

class DisplayErrorViewController: UIViewController {

    func prepare(message: String) {
        self.message = message
    }
    
    var message: String?
    
    @IBOutlet weak var errorTextField: UITextView! {
        didSet {
            errorTextField.text = message
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Error details"
    }
    
}
