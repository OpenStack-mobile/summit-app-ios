//
//  LevelTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ILevelTableViewCell : class {
    var name: String! { get set }
}

class LevelTableViewCell: UITableViewCell, ILevelTableViewCell {
    var name: String!{
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    @IBOutlet weak var nameLabel : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}