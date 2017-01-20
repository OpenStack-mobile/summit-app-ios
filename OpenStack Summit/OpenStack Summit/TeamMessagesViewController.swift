//
//  TeamMessagesViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit
import Haneke
import SlackTextViewController

final class TeamMessagesViewController: SLKTextViewController, NSFetchedResultsControllerDelegate, MessageEnabledViewController {
    
    // MARK: - Properties
    
    var team: Identifier! {
        
        didSet { if isViewLoaded() { configureView() } }
    }
    
    // MARK: - Properties
    
    private(set) var sending = false
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    private lazy var placeholderMemberImage = R.image.genericUserAvatar()!
    
    // MARK: - Loading
    
    deinit {
        
        stopNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNotifications()
        
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.inverted = true
        self.textInputbar.autoHideRightButton = true
        self.textInputbar.maxCharCount = 256
        self.textInputbar.counterStyle = .Split
        self.textInputbar.counterPosition = .Top
        self.textView.placeholder = "Message"
        self.tableView!.separatorStyle = .None
        self.tableView!.registerClass(MessageTableViewCell.classForCoder(), forCellReuseIdentifier: MessengerCellIdentifier)
        
        configureView()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        guard let teamManagedObject = try! TeamManagedObject.find(team, context: Store.shared.managedObjectContext)
            else { fatalError("Team not in cache") }
        
        self.title = teamManagedObject.name
        
        let predicate = NSPredicate(format: "team == %@", teamManagedObject)
        
        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        self.fetchedResultsController = NSFetchedResultsController(TeamMessage.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: sortDescriptors,
                                                                   sectionNameKeyPath: nil,
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController!.performFetch()
        
        self.tableView!.reloadData()
    }
    
    private subscript (indexPath: NSIndexPath) -> TeamMessage {
        
        let managedObject = self.fetchedResultsController!.objectAtIndexPath(indexPath) as! TeamMessageManagedObject
        
        return TeamMessage(managedObject: managedObject)
    }
    
    private subscript (data indexPath: NSIndexPath) -> (name: String, body: String, image: NSURL?) {
        
        let message = self[indexPath]
        
        let name: String
        
        let imageURL: NSURL?
        
        switch message.from {
            
        case let .identifier(identifier):
            
            name = "Member \(identifier)"
            
            imageURL = nil
            
        case let .value(member):
            
            name = member.name
            
            imageURL = NSURL(string: member.pictureURL.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil))
        }
        
        return (name, message.body, imageURL)
    }
    
    private func configure(cell cell: MessageTableViewCell, at indexPath: NSIndexPath) {
        
        let managedObject = self.fetchedResultsController.objectAtIndexPath(indexPath)
        
        let messageData = self[data: indexPath]
        
        cell.indexPath = indexPath
        cell.usedForMessage = true
        
        cell.titleLabel.text = messageData.name
        cell.bodyLabel.text = messageData.body
        
        cell.thumbnailView.image = placeholderMemberImage
        
        if let url = messageData.image {
            
            Shared.imageCache.fetch(URL: url, failure: nil, success: { [weak self] (image) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                    
                    guard let controller = self else { return }
                    
                    // cell hasnt changed
                    guard indexPath == controller.fetchedResultsController.indexPathForObject(managedObject)
                        && controller[data: indexPath].image == url
                        else { return }
                    
                    cell.thumbnailView.image = image
                }
            })
        }
        
        // Cells must inherit the table view's transform
        // This is very important, since the main table view may be inverted
        cell.transform = self.tableView!.transform
    }
    
    @objc private func textInputbarDidMove(notification: NSNotification) {
        
        
    }
    
    // MARK: Notifications
    
    private func registerNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self.tableView!, selector: #selector(UITableView.reloadData), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textInputbarDidMove), name: SLKTextInputbarDidMoveNotification, object: nil)
    }
    
    private func stopNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self.tableView!)
    }
    
    // MARK: - Overriden Methods
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        
        return .Plain
    }
    
    override func ignoreTextInputbarAdjustment() -> Bool {
        return super.ignoreTextInputbarAdjustment()
    }
    
    override func forceTextInputbarAdjustmentForResponder(responder: UIResponder?) -> Bool {
        
        guard let _ = responder as? UIAlertController else {
            // On iOS 9, returning YES helps keeping the input view visible when the keyboard if presented from another app when using multi-tasking on iPad.
            return UIDevice.currentDevice().userInterfaceIdiom == .Pad
        }
        return true
    }
    
    override func canPressRightButton() -> Bool {
        
        return sending == false
    }
    
    override func didPressRightButton(sender: AnyObject?) {
        
        self.sending = true
        
        Store.shared.send(self.textView.text, to: team) { [weak self] (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                guard let controller = self else { return }
                
                controller.sending = false
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.showErrorMessage(error)
                    
                case .Value: break
                }
            }
        }
        
        super.didPressRightButton(sender)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(MessengerCellIdentifier, forIndexPath: indexPath) as! MessageTableViewCell
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let messageData = self[data: indexPath]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        paragraphStyle.alignment = .Left
        
        let pointSize = MessageTableViewCell.defaultFontSize()
        
        let attributes = [
            NSFontAttributeName : UIFont.systemFontOfSize(pointSize),
            NSParagraphStyleAttributeName : paragraphStyle
        ]
        
        var width = tableView.frame.width-kMessageTableViewCellAvatarHeight
        width -= 25.0
        
        let titleBounds = (messageData.name as NSString).boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        
        let bodyBounds = messageData.body.boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        
        if messageData.body.characters.count == 0 {
            return 0
        }
        
        var height = titleBounds.height
        height += bodyBounds.height
        height += 40
        
        if height < kMessageTableViewCellMinimumHeight {
            height = kMessageTableViewCellMinimumHeight
        }
        
        return height
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.tableView!.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.tableView!.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            
            if let insertIndexPath = newIndexPath {
                self.tableView!.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: .Fade)
            }
        case .Delete:
            
            if let deleteIndexPath = indexPath {
                self.tableView!.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: .Fade)
            }
        case .Update:
            if let updateIndexPath = indexPath,
                let cell = self.tableView!.cellForRowAtIndexPath(updateIndexPath) as! MessageTableViewCell? {
                
                self.configure(cell: cell, at: updateIndexPath)
            }
        case .Move:
            
            if let deleteIndexPath = indexPath {
                self.tableView!.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: .Fade)
            }
            
            if let insertIndexPath = newIndexPath {
                self.tableView!.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: .Fade)
            }
        }
    }
}
