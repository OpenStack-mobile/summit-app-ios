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
    var unselectedColor: UIColor? { get set }
    var selectedColor: UIColor? { get set }
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
            nameLabel.textColor = newValue ? getSelectedColor() : getUnselectedColor() // UIColor.whiteColor() : UIColor.lightGrayColor()
        }
    }
    
    var unselectedColor: UIColor? {
        get {
            return unselectedColorInternal
        }
        set {
            unselectedColorInternal = newValue
        }
    }

    var selectedColor: UIColor? {
        get {
            return selectedColorInternal
        }
        set {
            selectedColorInternal = newValue
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var optionSelectedImage: UIImageView!

    var unselectedColorInternal:UIColor?
    var selectedColorInternal:UIColor?
    
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
    
    func getSelectedColor() -> UIColor? {
        return (selectedColorInternal != nil) ? selectedColorInternal : UIColor.whiteColor()
    }
    
    func getUnselectedColor() -> UIColor? {
        return (unselectedColorInternal != nil) ? unselectedColorInternal : UIColor.lightGrayColor()
    }
    
}