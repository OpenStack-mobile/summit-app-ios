//
//  GeneralScheduleFilterTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/20/15.
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
            return !optionSelectedImage.hidden
        }
        set {
            optionSelectedImage.hidden = !newValue
            nameLabel.font = newValue ? UIFont.boldSystemFontOfSize(15) : UIFont.systemFontOfSize(15)
            nameLabel.textColor = newValue ? UIColor.whiteColor() : UIColor.lightGrayColor()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var optionSelectedImage: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bgColorView = UIView()
        bgColorView.backgroundColor = contentView.backgroundColor
        selectedBackgroundView = bgColorView
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}