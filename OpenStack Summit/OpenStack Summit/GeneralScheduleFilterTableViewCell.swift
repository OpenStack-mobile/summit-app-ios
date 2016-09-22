//
//  GeneralScheduleFilterTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

final class GeneralScheduleFilterTableViewCell: UITableViewCell {
    
    private static let extraPadding: CGFloat = 5
    
    // MARK: - IB Outlet
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var optionSelectedImage: UIImageView!
    @IBOutlet weak var nameLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabelVerticalConstraint: NSLayoutConstraint!
    
    // MARK: - Accessors
    
    var name: String {
        
        get { return nameLabel.text ?? "" }
        
        set { nameLabel.text = newValue }
    }
    
    var isOptionSelected: Bool {
        
        get { return !optionSelectedImage.hidden }
        
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
            nameLabelLeadingConstraint.constant = 63
        }
    }
    
    // MARK: - Loading
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleView.hidden = true
        selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: - Methods
    
    func addTopExtraPadding() {
        
        nameLabelVerticalConstraint.constant = GeneralScheduleFilterTableViewCell.extraPadding
    }
    
    func addBottomExtraPadding() {
        
        nameLabelVerticalConstraint.constant = -GeneralScheduleFilterTableViewCell.extraPadding
    }
}