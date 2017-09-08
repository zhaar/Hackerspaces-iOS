//
//  UIUtils.swift
//  Hackerspaces
//
//  Created by zephyz on 08.09.17.
//  Copyright © 2017 Fixme. All rights reserved.
//

import UIKit

extension UIViewController {


    /// Display an alert in the current view controller
    ///
    /// - parameters:
    ///   - alertTitle: The title of the alert
    ///   - message: The message of the alert
    ///   - alertStyle: The style that should be used to display the alert (optional)
    ///   - buttonTitle: The title of the confirmation button
    ///   - buttonStyle: The style of the confirmation button (optional)
    ///   - confirmed: The callback when the confirmation button is pushed (optional)
    ///   - canceled: The callback when the cancel button is push (optional)
    ///   - dismissed: The callback when the alert is dismissed (optional)
    func displayAlert(alertTitle: String?,
                      alertStyle preferredStyle: UIAlertControllerStyle = .alert,
                      message: String?,
                      buttonTitle button: String,
                      buttonStyle style: UIAlertActionStyle = .default,
                      confirmed onclick: ((UIAlertAction) -> ())? = nil,
                      canceled oncancel: ((UIAlertAction) -> ())? = nil,
                      dismissed callback: (() -> ())? = nil) -> () {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: button, style: style, handler: onclick))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: oncancel))
        self.present(alert, animated: true, completion: callback)
    }
}
