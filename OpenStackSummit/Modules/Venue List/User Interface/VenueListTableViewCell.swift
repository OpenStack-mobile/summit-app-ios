//
//  VenueListTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueListTableViewCell {
    var name: String! { get set }
}

class VenueListTableViewCell: UITableViewCell, IVenueListTableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var name: String! {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
