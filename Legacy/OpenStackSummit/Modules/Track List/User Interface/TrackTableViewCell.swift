//
//  TrackTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit


public class TrackTableViewCell: UITableViewCell {
    
    public var name: String! {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    @IBOutlet public weak var nameLabel : UILabel!

    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
