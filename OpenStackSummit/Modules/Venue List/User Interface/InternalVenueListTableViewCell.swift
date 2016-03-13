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
    var address: String! { get set }
}

class InternalVenueListTableViewCell: VenueListTableViewCell, IInternalVenueListTableViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    var backgroundImageUrl: String! {
        didSet {
            let picUrl = backgroundImageUrl.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
            backgroundImageView.hnk_setImageFromURL(NSURL(string: picUrl)!)
        }
    }
    
    var address: String! {
        didSet {
            addressLabel.text = address
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.hnk_setImageFromURL(NSURL(string: "http://devbranch.openstack.org/assets/summits/locations/images/im-1.jpg")!)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
