//
//  SpeakerDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/11/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit
import RealmSwift
import Haneke

final class SpeakerDetailViewController: UITableViewController {
    
    // MARK: - Properties
    
    var speaker: PresentationSpeaker!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        assert(speaker != nil, "No speaker set")
        
        self.title = speaker.name
    }
}