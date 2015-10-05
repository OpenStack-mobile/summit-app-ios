//
//  PeopleTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var titleLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
