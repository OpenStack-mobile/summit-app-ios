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
import Haneke
import Predicate

@objc(OSSTVSpeakerDetailViewController)
final class SpeakerDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var tableView: UITableView!
    
    @IBOutlet private(set) weak var pictureImageView: UIImageView!
    
    // MARK: - Properties
    
    var speaker: Identifier!
    
    var entityController: EntityController<Speaker>!
    
    private var speakerCache: Speaker!
    
    private var data = [Detail]()
    
    private var eventsPredicate: Predicate!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 20
        
        pictureImageView.layer.cornerRadius = pictureImageView.frame.size.width / 2
        pictureImageView.clipsToBounds = true
        
        configureController()
    }
    
    // MARK: - Private Methods
    
    private func configureController() {
        
        assert(self.speaker != nil, "No speaker set")
        
        let context = Store.shared.managedObjectContext
        
        self.entityController = EntityController(identifier: self.speaker, entity: SpeakerManagedObject.self, context: context)
        
        self.entityController.event.updated = updateUI
        
        //eventsPredicate = NSPredicate(format: "ANY presentation.speakers.id == %@", NSNumber(value: Int64(self.speaker)))
        eventsPredicate = (#keyPath(EventManagedObject.presentation.speakers.id)).any(in: [self.speaker])
        
        guard let speaker = try! Speaker.find(self.speaker, context: context)
            else { fatalError("Invalid Speaker \(self.speaker)") }
        
        self.updateUI(speaker)
    }
    
    private func updateUI(_ speaker: Speaker) {
        
        self.title = speaker.name
        
        self.speakerCache = speaker
        
        pictureImageView.hnk_setImageFromURL(speaker.picture.environmentScheme, placeholder: #imageLiteral(resourceName: "generic-user-avatar"))
        
        data = []
        
        if speaker.twitter != nil {
            
            data.append(.twitter)
        }
        
        if speaker.irc != nil {
            
            data.append(.irc)
        }
        
        let eventCount = try! Store.shared.managedObjectContext.count(EventManagedObject.self, predicate: eventsPredicate)
        
        data.append(.sessions(eventCount))
        
        if speaker.biography != nil {
            
            data.append(.biography)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = self.data[indexPath.row]
        
        switch data {
            
        case .twitter:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpeakerTwitterCell", for: indexPath) as! DetailImageTableViewCell
            
            cell.titleLabel.text = speakerCache.twitter
            
            return cell
            
        case .irc:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpeakerIRCCell", for: indexPath) as! DetailImageTableViewCell
            
            cell.titleLabel.text = speakerCache.irc
            
            return cell
            
        case .biography:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpeakerBiographyCell", for: indexPath)
            
            if let data = speakerCache.biography?.data(using: String.Encoding.utf8),
                let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                
                cell.textLabel!.text = attributedString.string
                
            } else {
                
                cell.textLabel!.text = "Invalid HTML."
            }
            
            return cell
            
        case let .sessions(eventCount):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpeakerEventsCell", for: indexPath) as! DetailImageTableViewCell
            
            cell.titleLabel.text = "\(eventCount) " + "\(eventCount == 1 ? "session" : "sessions")"
            
            return cell
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case "showSpeakerEvents":
            
            let eventsViewController = segue.destination as! EventsViewController
            
            eventsViewController.predicate = eventsPredicate
            
            eventsViewController.title = speakerCache.name
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}

// MARK: - Supporting Types

private extension SpeakerDetailViewController {
    
    enum Detail {
        
        case twitter
        case irc
        case sessions(Int)
        case biography
    }
}
