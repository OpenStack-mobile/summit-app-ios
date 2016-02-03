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
    var circleColor: UIColor? { get set }
    var isOptionSelected: Bool { get set }
    func addTopExtraPadding()
    func addBottomExtraPadding()
}

class GeneralScheduleFilterTableViewCell: UITableViewCell, IGeneralScheduleFilterTableViewCell {
    
    let halfExtraPadding: CGFloat = 6
    
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
            
            if newValue {
                 nameLabel.alpha = 1
            }
            else {
                nameLabel.alpha = 0.5
            }
        }
    }

    var circleColor: UIColor? {
        didSet {
            circleView.hidden = false
            circleView.backgroundColor = circleColor
            nameLabelLeadingToCircleConstrain.active = true
            nameLabelLeadingToContainerConstrain.active = false
        }
    }
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var optionSelectedImage: UIImageView!
    @IBOutlet weak var nameLabelVerticalConstrain: NSLayoutConstraint!
    @IBOutlet weak var nameLabelLeadingToCircleConstrain: NSLayoutConstraint!
    @IBOutlet weak var nameLabelLeadingToContainerConstrain: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        circleView.hidden = true
        selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func addTopExtraPadding() {
        nameLabelVerticalConstrain.constant = halfExtraPadding
    }
    
    func addBottomExtraPadding() {
        nameLabelVerticalConstrain.constant = -halfExtraPadding
    }
}