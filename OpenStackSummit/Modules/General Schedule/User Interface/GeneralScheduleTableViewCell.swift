//
//  GeneralScheduleTableViewCell.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 8/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
@objc
public protocol IGeneralScheduleTableViewCell : class {
    var eventTitle: String! { get set }
    var timeAndPlace: String! { get set }
}

class GeneralScheduleTableViewCell: UITableViewCell, IGeneralScheduleTableViewCell {
    var eventTitle: String!{
        get {
            return eventTitleLabel.text
        }
        set {
            eventTitleLabel.text = newValue
        }
    }
    
    var timeAndPlace: String!{
        get {
            return timeAndPlaceLabel.text
        }
        set {
            timeAndPlaceLabel.text = newValue
        }
    }
    
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
