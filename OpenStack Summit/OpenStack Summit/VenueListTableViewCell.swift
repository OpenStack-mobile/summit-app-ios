//
//  VenueListTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

protocol VenueListTableViewCellProtocol: class {
    
    var name: String { get set }
    var address: String { get set }
}

final class VenueListTableViewCell: UITableViewCell, VenueListTableViewCellProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var addressLabel: UILabel!
    
    // MARK: - Accessors
    
    var name: String {
        
        get { return nameLabel.text ?? "" }
        set { nameLabel.text = newValue }
    }
    
    var address: String {
        get { return addressLabel.text ?? "" }
        set { addressLabel.text = newValue }
    }
}
