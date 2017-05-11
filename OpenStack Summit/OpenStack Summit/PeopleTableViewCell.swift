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
        
        
    }
    
    // MARK: - Selection
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Accessors
    
    var isModerator: Bool {
        get {
            return !moderatorLabel.isHidden
        }
        set {
            moderatorLabel.isHidden = !newValue
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
            titleLabel.isHidden = (newValue ?? "").isEmpty
        }
    }
    
    var pictureURL: String = "" {
        
        didSet {
            
            let picUrlInternal: String
            
            picUrlInternal = pictureURL.replacingOccurrences(of: "https", with: "http", options: NSString.CompareOptions.literal, range: nil)
            
            if (!picUrlInternal.isEmpty) {
                let placeholder = R.image.genericUserAvatar()!
                pictureImageView.hnk_setImageFromURL(URL(string: picUrlInternal)!, placeholder: placeholder)
            }
            else {
                pictureImageView.image = R.image.genericUserAvatar()!
            }
            pictureImageView.layer.cornerRadius = pictureImageView.frame.size.width / 2
            pictureImageView.clipsToBounds = true;
        }
    }
}
