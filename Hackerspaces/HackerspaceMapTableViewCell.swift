
//
//  HackerspaceMapTableViewCell.swift
//  Hackerspaces
//
//  Created by zephyz on 21/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit
import MapKit

class HackerspaceMapTableViewCell: UITableViewCell {

    @IBOutlet weak var map: MKMapView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
