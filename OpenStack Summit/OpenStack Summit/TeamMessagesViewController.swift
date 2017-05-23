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
import Predicate
import Haneke
import SlackTextViewController

final class TeamMessagesViewController: SLKTextViewController, NSFetchedResultsControllerDelegate, MessageEnabledViewController {
    
    // MARK: - Properties
    
    var team: Identifier! {
        
        didSet { if isViewLoaded { configureView() } }
    }
    
    // MARK: - Properties
    
    private(set) var sending = false
    
    private var fetchedResultsController: NSFetchedResultsController<TeamMessageManagedObject>!
    
    private lazy var placeholderMemberImage = #imageLiteral(resourceName: "generic-user-avatar")
    
    // MARK: - Loading
    
    deinit {
        
        stopNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNotifications()
        
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.isInverted = true
        self.textInputbar.autoHideRightButton = true
        self.textInputbar.maxCharCount = 256
        self.textInputbar.counterStyle = .split
        self.textInputbar.counterPosition = .top
        self.textView.placeholder = "Message"
        self.tableView!.separatorStyle = .none
        self.tableView!.register(MessageTableViewCell.classForCoder(), forCellReuseIdentifier: MessengerCellIdentifier)
        
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PushNotificationManager.shared.teamMessageAlertFilter = team
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        PushNotificationManager.shared.teamMessageAlertFilter = nil
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        guard let teamID = self.team
            else { fatalError("View controller not configured") }
        
        guard let teamManagedObject = try! TeamManagedObject.find(teamID, context: Store.shared.managedObjectContext)
            else { fatalError("Team not in cache") }
        
        self.title = teamManagedObject.name
        
        //let predicate = NSPredicate(format: "team == %@", teamManagedObject)
        let predicate: Predicate = #keyPath(TeamMessageManagedObject.team.id) == teamID
        
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(TeamMessageManagedObject.id), ascending: false)]
        
        self.fetchedResultsController = NSFetchedResultsController(TeamMessage.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: sortDescriptors,
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController!.performFetch()
        
        self.tableView!.reloadData()
    }
    
    private subscript (indexPath: IndexPath) -> TeamMessage {
        
        let managedObject = self.fetchedResultsController!.object(at: indexPath)
        
        return TeamMessage(managedObject: managedObject)
    }
    
    private subscript (data indexPath: IndexPath) -> (name: String, body: String, image: URL?) {
        
        let message = self[indexPath]
        
        let name: String
        
        let imageURL: URL?
        
        switch message.from {
            
        case let .identifier(identifier):
            
            name = "Member \(identifier)"
            
            imageURL = nil
            
        case let .value(member):
            
            name = member.name
            
            imageURL = member.picture
        }
        
        return (name, message.body, imageURL)
    }
    
    private func configure(cell: MessageTableViewCell, at indexPath: IndexPath) {
        
        let managedObject = self.fetchedResultsController.object(at: indexPath)
        
        let messageData = self[data: indexPath]
        
        cell.indexPath = indexPath
        cell.usedForMessage = true
        
        cell.titleLabel.text = messageData.name
        cell.bodyLabel.text = messageData.body
        
        cell.thumbnailView.image = placeholderMemberImage
        
        if let url = messageData.image {
            
            let _ = Shared.imageCache.fetch(URL: url, failure: nil, success: { [weak self] (image) in
                
                OperationQueue.main.addOperation { [weak self] in
                    
                    guard let controller = self else { return }
                    
                    // cell hasnt changed
                    guard indexPath == controller.fetchedResultsController.indexPath(forObject: managedObject)
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
    
    @objc private func textInputbarDidMove(_ notification: Foundation.Notification) {
        
        
    }
    
    // MARK: Notifications
    
    private func registerNotifications() {
        
        NotificationCenter.default.addObserver(self.tableView!, selector: #selector(UITableView.reloadData), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textInputbarDidMove), name: NSNotification.Name.SLKTextInputbarDidMove, object: nil)
    }
    
    private func stopNotifications() {
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self.tableView!)
    }
    
    // MARK: - Overriden Methods
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        
        return .plain
    }
    
    override func ignoreTextInputbarAdjustment() -> Bool {
        return super.ignoreTextInputbarAdjustment()
    }
    
    override func forceTextInputbarAdjustment(for responder: UIResponder?) -> Bool {
        
        guard let _ = responder as? UIAlertController else {
            // On iOS 9, returning YES helps keeping the input view visible when the keyboard if presented from another app when using multi-tasking on iPad.
            return UIDevice.current.userInterfaceIdiom == .pad
        }
        return true
    }
    
    override func canPressRightButton() -> Bool {
        
        return sending == false
    }
    
    override func didPressRightButton(_ sender: Any?) {
        
        self.sending = true
        
        Store.shared.send(self.textView.text, to: team) { [weak self] (response) in
            
            OperationQueue.main.addOperation {
                
                guard let controller = self else { return }
                
                controller.sending = false
                
                switch response {
                    
                case let .error(error):
                    
                    controller.showErrorMessage(error)
                    
                case .value:
                    
                    break
                }
            }
        }
        
        super.didPressRightButton(sender)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MessengerCellIdentifier, for: indexPath) as! MessageTableViewCell
        
        configure(cell: cell, at: indexPath)
        
        let message = self[indexPath]
        
        // mark notification as read
        PushNotificationManager.shared.unreadTeamMessages.value.remove(message.identifier)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let messageData = self[data: indexPath]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        
        let pointSize = MessageTableViewCell.defaultFontSize()
        
        let attributes = [
            NSFontAttributeName : UIFont.systemFont(ofSize: pointSize),
            NSParagraphStyleAttributeName : paragraphStyle
        ]
        
        var width = tableView.frame.width-kMessageTableViewCellAvatarHeight
        width -= 25.0
        
        let titleBounds = (messageData.name as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        let bodyBounds = messageData.body.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.tableView!.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.tableView!.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            
            if let insertIndexPath = newIndexPath {
                self.tableView!.insertRows(at: [insertIndexPath], with: .fade)
            }
        case .delete:
            
            if let deleteIndexPath = indexPath {
                self.tableView!.deleteRows(at: [deleteIndexPath], with: .fade)
            }
        case .update:
            if let updateIndexPath = indexPath,
                let cell = self.tableView!.cellForRow(at: updateIndexPath) as! MessageTableViewCell? {
                
                self.configure(cell: cell, at: updateIndexPath)
            }
        case .move:
            
            if let deleteIndexPath = indexPath {
                self.tableView!.deleteRows(at: [deleteIndexPath], with: .fade)
            }
            
            if let insertIndexPath = newIndexPath {
                self.tableView!.insertRows(at: [insertIndexPath], with: .fade)
            }
        }
    }
}
