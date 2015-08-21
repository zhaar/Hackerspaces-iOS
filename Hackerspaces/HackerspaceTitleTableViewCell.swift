//
//  HackerspaceTitleTableViewCell.swift
//  Hackerspaces
//
//  Created by zephyz on 21/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit

class HackerspaceTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var hackerspaceTitle: UILabel!
    @IBOutlet weak var hackerspaceStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        println("custom cell nib")
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
