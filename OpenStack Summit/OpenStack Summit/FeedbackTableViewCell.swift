//
//  MyFeedbackTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Cosmos

final class FeedbackTableViewCell: UITableViewCell {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var eventNameLabel: UILabel!
    @IBOutlet private(set) weak var ownerLabel: UILabel!
    @IBOutlet private(set) weak var reviewLabel: UILabel!
    @IBOutlet private(set) weak var dateLabel: UILabel!
    @IBOutlet private(set) weak var rateView: CosmosView!
    
    @IBOutlet private(set) weak var rateViewWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Accessors
    
    var eventName: String! {
        get {
            return eventNameLabel.text
        }
        set {
            eventNameLabel.text = newValue
        }
    }
    
    var owner: String!{
        get {
            return ownerLabel.text
        }
        set {
            ownerLabel.text = newValue
        }
    }
    
    var rate: Double{
        get {
            return rateView.rating
        }
        set {
            rateView.rating = newValue
            rateViewWidthConstraint.constant = CGFloat(17*newValue) + 5.0
        }
    }
    
    var review: String!{
        get {
            return reviewLabel.text
        }
        set {
            reviewLabel.text = newValue
            reviewLabel.sizeToFit()
        }
    }
    
    var date: String!{
        get {
            return dateLabel.text
        }
        set {
            dateLabel.text = newValue
        }
    }
    
    // MARK: - Loading
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rateView.settings.updateOnTouch = false
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    // MARK: - Selection
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
