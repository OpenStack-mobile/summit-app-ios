//
//  GeneralScheduleTableViewCell.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 8/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

class GeneralScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var eventTitleLabel : UILabel!
    @IBOutlet weak var timeAndPlaceLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
