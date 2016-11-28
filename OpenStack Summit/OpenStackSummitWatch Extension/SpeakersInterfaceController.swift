//
//  SpeakersInferfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class SpeakersInterfaceController: WKInterfaceController {
    
    static let identifier = "Speakers"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var searchButton: WKInterfaceButton!
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    @IBOutlet weak var emptyLabel: WKInterfaceLabel!
    
    // MARK: - Properties
    
    private(set) var speakers = [Speaker]() {
        
        didSet { updateUI() }
    }
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // disable speaker search for selected speakers
        if let speakers = (context as? Context<[Speaker]>)?.value {
            
            searchButton.setHidden(true)
            
            self.speakers = speakers
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        updateUserActivity(AppActivity.screen.rawValue, userInfo: [AppActivityUserInfo.screen.rawValue: AppActivityScreen.speakers.rawValue], webpageURL: nil)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Actions
    
    @IBAction func search(sender: WKInterfaceButton) {
        
        presentTextInputControllerWithSuggestionsForLanguage({ self.autosuggestions(for: $0) }, allowedInputMode: .Plain) { (input) in
            
            guard let inputText = input as? [String]
                else { return }
            
            // search for speakers
            self.speakers = Store.shared.cache!.speakers.filter {
                
                for string in inputText {
                    
                    if $0.name.containsString(string) {
                        
                        return true
                    }
                }
                
                return false
            }
        }
    }
    
    // MARK: - Segue
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
        let speaker = speakers[rowIndex]
        
        return Context(speaker)
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        emptyLabel.setHidden(speakers.isEmpty == false)
        
        tableView.setNumberOfRows(speakers.count, withRowType: SpeakerCellController.identifier)
        
        for (index, speaker) in speakers.enumerate() {
            
            let cell = tableView.rowControllerAtIndex(index) as! SpeakerCellController
            
            cell.nameLabel.setText(speaker.name)
            cell.titleLabel.setText(speaker.title)
        }
    }
    
    /// Provide suggestions for the following language (e.g. `en-US`).
    private func autosuggestions(for language: String) -> [String] {
        
        #if DEBUG
        return ["Zhao", "Ben"]
        #else
        
        /*
        let firstNames = Store.shared.cache!.speakers.map({ $0.firstName })
        
        let lastNames = Store.shared.cache!.speakers.map({ $0.lastName })
        
        return firstNames + lastNames
        */
        
        return []
        
        #endif
    }
}

// MARK: - Supporting Types

final class SpeakerCellController: NSObject {
    
    static let identifier = "SpeakerCell"
    
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
}
