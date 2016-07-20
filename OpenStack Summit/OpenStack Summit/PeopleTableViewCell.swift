//
//  PeopleTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Haneke

final class PeopleTableViewCell: UITableViewCell {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var moderatorLabel: UILabel!
    @IBOutlet private weak var nameLabel : UILabel!
    @IBOutlet private weak var titleLabel : UILabel!
    @IBOutlet private weak var pictureImageView: UIImageView!
    
    // MARK: - Loading
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = contentView.backgroundColor
        selectedBackgroundView = bgColorView
    }
    
    // MARK: - Selection
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Accessors
    
    var isModerator: Bool {
        get {
            return !moderatorLabel.hidden
        }
        set {
            moderatorLabel.hidden = !newValue
        }
    }
    
    var name: String!{
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    var title: String!{
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var pictureURL: String = "" {
        
        didSet {
            
            let picUrlInternal: String
            
            #if DEBUG
                picUrlInternal = pictureURL.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
            #else
                picUrlInternal = pictureURL
            #endif

            if (!picUrlInternal.isEmpty) {
                let placeholder = UIImage(named: "generic-user-avatar")
                pictureImageView.hnk_setImageFromURL(NSURL(string: picUrlInternal)!, placeholder: placeholder)
            }
            else {
                pictureImageView.image = UIImage(named: "generic-user-avatar")
            }
            pictureImageView.layer.cornerRadius = pictureImageView.frame.size.width / 2
            pictureImageView.clipsToBounds = true;
        }
    }
}
