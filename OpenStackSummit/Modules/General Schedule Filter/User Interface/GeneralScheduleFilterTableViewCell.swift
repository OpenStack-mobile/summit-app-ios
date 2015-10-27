//
//  GeneralScheduleFilterTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IGeneralScheduleFilterTableViewCell {
    var name: String! { get set }
    var isOptionSelected: Bool { get set }
}

class GeneralScheduleFilterTableViewCell: UITableViewCell, IGeneralScheduleFilterTableViewCell {
    var name: String! {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    var isOptionSelected: Bool {
        get {
            return !selectedLabel.hidden
        }
        set {
            selectedLabel.hidden = !newValue
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}    
