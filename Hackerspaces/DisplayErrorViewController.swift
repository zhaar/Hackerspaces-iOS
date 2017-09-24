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
    
    var message: String = """
Q: Why can't I find my local hackerspace in the list?
A: Only hackerspaces registered on the OpenSpace directory are visible. Your hackerspace needs to expose an API that conforms to the SpaceAPI.net format.

Q: How can I add my local hackerspace?
A: You will need a server that exposes a public API. Once your API is up and running you can register it's address at the OpenSpace directory  (https://github.com/fixme-lausanne/OpenSpaceDirectory) by making a pull request. Once the pull request is accepted your Hackerspace will be visible in the app. If you want to test your API inside the app before it's added to the Open Space DIrectory you can add it as a custom endpoint in the advanced settings. To enable advanced settings, pull the settings list and select "ok".

Q: Something is wrong with the app, what can I do?
A: You can communicate any issue with the app on the github repository at https://github.com/zhaar/Hackerspaces-iOS/issues. You can even issue pull requests to enable more functionalities.
"""
    
    @IBOutlet weak var errorTextField: UITextView! {
        didSet {
            errorTextField.text = message
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Error details"
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = Theme.conditionalBackgroundColor
    }
}
