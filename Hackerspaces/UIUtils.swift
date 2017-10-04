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

extension UIColor {

    static let darkBackground = UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.0)
    static let darkTint = UIColor(red:0.25, green:0.62, blue:0.64, alpha:1.0)
    static let themeWhite = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
    static let themeGray = UIColor(red:0.3, green:0.3, blue:0.3, alpha:1.0)
    static let staticTableBackground = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
    static let defaultBlueTint = UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
}

enum Theme {

    static func enableDarkMode() {
        print("enabling dark mode")
        UINavigationBar.appearance().barTintColor = UIColor.darkBackground
        UINavigationBar.appearance().tintColor = UIColor.darkTint
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.themeWhite]
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.themeWhite]
        }
        UITabBar.appearance().barTintColor = UIColor.darkBackground
        UITabBar.appearance().tintColor = UIColor.darkTint
        UITableView.appearance().backgroundColor = UIColor.darkBackground
        UITableView.appearance().sectionIndexBackgroundColor  = UIColor.darkBackground
        UILabel.appearance().textColor = UIColor.themeWhite
        UITableViewCell.appearance().backgroundColor = UIColor.darkBackground
        UITextView.appearance().backgroundColor = UIColor.darkBackground
        UITextView.appearance().tintColor = UIColor.darkTint
        UITextView.appearance().textColor = UIColor.themeWhite
        UIApplication.shared.statusBarStyle = .lightContent
        UITextField.appearance().backgroundColor = UIColor.darkBackground
        UITextField.appearance().textColor = UIColor.themeWhite
        UIButton.appearance().tintColor = UIColor.darkTint
        UITableView.appearance().separatorColor = UIColor.gray
    }

    static func enableClearMode() {
        print("enabling clear mode")
        UINavigationBar.appearance().barTintColor = nil
        UINavigationBar.appearance().tintColor = nil
        UINavigationBar.appearance().titleTextAttributes = [:]
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [:]
        }
        UITabBar.appearance().barTintColor = nil
        UITabBar.appearance().tintColor = nil
        UITableView.appearance().backgroundColor = UIColor.white
        UITableView.appearance().sectionIndexBackgroundColor  = nil
        UILabel.appearance().textColor = UIColor.black
        UITableViewCell.appearance().backgroundColor = UIColor.white
        UITextView.appearance().backgroundColor = UIColor.white
        UITextView.appearance().tintColor = nil
        UITextView.appearance().textColor = nil
        UIApplication.shared.statusBarStyle = .default
        UITextField.appearance().backgroundColor = UIColor.white
        UITextField.appearance().textColor = UIColor.black
        UIButton.appearance().tintColor = UIColor.defaultBlueTint
        UITableView.appearance().separatorColor = UIColor(red: 214/255, green: 213/255, blue: 217/255, alpha: 1.0)


    }

    static public var conditionalBackgroundColor: UIColor {
        return SharedData.isInDarkMode() ? UIColor.darkBackground : UIColor.white
    }

    static public var conditionalForegroundColor: UIColor {
        return SharedData.isInDarkMode() ? UIColor.themeWhite : UIColor.black
    }

    static public var conditionalTintColor: UIColor {
        return SharedData.isInDarkMode() ? UIColor.darkTint : UIColor.defaultBlueTint
    }

    static func redrawAll() {
        for window in UIApplication.shared.windows {
            for view in window.subviews {
                view.removeFromSuperview()
                window.addSubview(view)
            }
        }
    }
}

