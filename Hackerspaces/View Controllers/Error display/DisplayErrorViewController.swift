//
//  DisplayErrorViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 14/09/16.
//  Copyright © 2016 Fixme. All rights reserved.
//

import UIKit

struct QAMessage: CustomStringConvertible {
    let question: String
    let answer: String
    var description: String {
        return """
        \(R.string.localizable.questionIndicator()): \(question)
        \(R.string.localizable.answerIndicator()): \(answer)
        """
    }
}

let questions = [QAMessage(question: R.string.localizable.cannotFindHSQuestion(),
                           answer: R.string.localizable.cannotFindHSAnswer()),
                 QAMessage(question: R.string.localizable.howToAddHSQuestion(),
                           answer: R.string.localizable.howToAddHSAnswer()),
                 QAMessage(question: R.string.localizable.reportBugQuestion(),
                           answer: R.string.localizable.reportBugAnswer())]


class DisplayErrorViewController: UIViewController {

    func prepare(message: String, title: String = "FAQ") {
        self.message = message
        self.navigationItem.title = title
    }
    
    var message: String = questions.map { $0.description }.joined(separator: "\n\n")

    
    @IBOutlet weak var errorTextField: UITextView! {
        didSet {
            errorTextField.text = message
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = Theme.conditionalBackgroundColor
    }
}
