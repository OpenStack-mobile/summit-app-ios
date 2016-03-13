//
//  InternalVenueListTableViewCell.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 3/12/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IInternalVenueListTableViewCell: IVenueListTableViewCell {
    var backgroundImageUrl: String! { get set }
}

class InternalVenueListTableViewCell: VenueListTableViewCell, IInternalVenueListTableViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var backgroundImageUrl: String! {
        didSet {
            if backgroundImageUrl.isEmpty {
                backgroundImageView.image = nil
            }
            else {
                let picUrl = backgroundImageUrl.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
                backgroundImageView.hnk_setImageFromURL(NSURL(string: picUrl)!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundImageView.contentMode = .ScaleAspectFill
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
