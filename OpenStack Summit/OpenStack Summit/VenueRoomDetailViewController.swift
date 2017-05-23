//
//  VenueRoomDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

final class VenueRoomDetailViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var capacityLabel: UILabel!
    @IBOutlet private(set) weak var pictureImageView: UIImageView!
    
    // MARK: - Properties
    
    var venueRoom: Identifier!
    
    // MARK: - Accessors
    
    private(set) var name: String {
        get {
            return nameLabel.text ?? ""
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    private(set) var capacity: Int {
        get {
            return Int(capacityLabel.text!) ?? 0
        }
        set {
            capacityLabel.text = String(newValue)
        }
    }
    
    private(set) var picture: URL? {
        
        didSet {
            
            if let url = picture {
                pictureImageView.hnk_setImageFromURL(url.environmentScheme)
            }
            else {
                pictureImageView.image = nil
            }
        }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(venueRoom != nil, "Venue room not set")
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        guard let venueRoom = try! VenueRoom.find(self.venueRoom, context: Store.shared.managedObjectContext)
            else { fatalError("Invalid identifier \(self.venueRoom!)") }
        
        self.name = venueRoom.name
        self.capacity = venueRoom.capacity ?? 0
    }
}
