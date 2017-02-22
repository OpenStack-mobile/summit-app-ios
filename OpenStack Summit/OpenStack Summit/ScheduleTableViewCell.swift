//
//  ScheduleCellViewTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    
    enum EventStatus {
        
        case none
        case saved
        case scheduled
    }
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var dateTimeLabel: UILabel!
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var trackLabel: UILabel!
    @IBOutlet private weak var statusImageView: UIImageView!
    
    // MARK: - Properties
    
    var eventStatus: EventStatus = .none {
        
        didSet {
            
            switch eventStatus {
                
            case .none:
                
                statusImageView.hidden = true
                statusImageView.image = nil
                
            case .saved:
                
                statusImageView.hidden = false
                statusImageView.image = R.image.contextMenuSaved()!
                
            case .scheduled:
                
                statusImageView.hidden = false
                statusImageView.image = R.image.contextMenuScheduleAdd()!
            }
        }
    }
    
    // MARK: - Loading
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
}
