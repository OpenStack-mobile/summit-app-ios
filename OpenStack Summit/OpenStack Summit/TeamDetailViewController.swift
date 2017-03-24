//
//  TeamDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/8/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit
import SwiftFoundation
import JGProgressHUD

final class TeamDetailViewController: UITableViewController, NSFetchedResultsControllerDelegate, UITextFieldDelegate, MessageEnabledViewController, ActivityViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) var addMemberBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private(set) weak var nameTextField: UITextField!
    
    // MARK: - Properties
    
    var team: Identifier!
    
    private var entityController: EntityController<Team>!
    
    private var teamCache: Team!
    
    private var canEdit = false
    
    private var data = [(Section, [Cell])]()
    
    private static let dateFormatter: NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter
    }()
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .Dark)
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup table view
        tableView.registerNib(R.nib.peopleTableViewCell)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        // setup entityController
        entityController = EntityController(identifier: team,
                                            entity: TeamManagedObject.self,
                                            context: Store.shared.managedObjectContext)
        
        entityController.event.updated = { [weak self] in self?.configureView($0) }
        
        entityController.event.deleted = { [weak self] in self?.wasDeleted() }
        
        entityController.enabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // fetch from server
        if Reachability.connected {
            
            self.refresh()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject? = nil) {
        
        Store.shared.fetch(team: team) { (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                controller.refreshControl?.endRefreshing()
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.showErrorMessage(error as NSError)
                    
                case .Value: break // entity controller will update
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView(team: Team) {
        
        guard let memberID = Store.shared.authenticatedMember?.identifier
            else { fatalError("Not logged in") }
        
        let userPermission = team.permission(for: memberID)
        
        self.teamCache = team
        
        self.canEdit = userPermission == .admin
        
        self.nameTextField.text = team.name
        
        self.nameTextField.userInteractionEnabled = canEdit
        
        self.navigationItem.rightBarButtonItem = canEdit ? addMemberBarButtonItem : nil
        
        self.data.removeAll()
        
        // description
        
        var descriptionSection = [Cell]()
        
        if (canEdit || team.descriptionText?.isEmpty ?? true == false) {
            
            descriptionSection.append(.description(team.descriptionText))
        }
        
        descriptionSection += [.created(team.created), .updated(team.updated)]
        
        self.data.append((.description, descriptionSection))
        
        // owner
        self.data.append((.owner, [.owner(team.owner)]))
        
        // members
        let members = team.members
            .sort()
            .filter { $0.member.identifier != team.owner.identifier }
            .map { Cell.member($0) }
        
        if members.isEmpty == false {
            
            self.data.append((.members, members))
        }
        
        let invitations = team.invitations
            .sort()
            .filter { $0.invitee.identifier != memberID }
            .map { Cell.invitation($0) }
        
        if invitations.isEmpty == false {
            
            self.data.append((.invitations, invitations))
        }
        
        if canEdit {
            
            self.data.append((.delete, [.delete]))
        }
        
        self.tableView.reloadData()
    }
    
    private subscript (indexPath: NSIndexPath) -> Cell {
        
        let section = self.data[indexPath.section]
        
        let rows = section.1
        
        return rows[indexPath.row]
    }
    
    private func wasDeleted() {
        
        /** Presents an alert controller with the specified completion handlers.  */
        func showAlert(localizedText: String, okHandler: (() -> ())? = nil, retryHandler: (()-> ())? = nil) {
            
            let alert = UIAlertController(title: nil,
                                          message: localizedText,
                                          preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                
                okHandler?()
                
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            // optionally add retry button
            
            if retryHandler != nil {
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: "Retry"), style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                    
                    retryHandler!()
                    
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
            }
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        showAlert("Team was deleted", okHandler: { self.navigationController?.popToRootViewControllerAnimated(true) })
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.data.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = self.data[section]
        
        let rows = section.1
        
        return rows.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellData = self[indexPath]
        
        switch cellData {
            
        case let .description(description):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.teamDetailTextFieldTableViewCell, forIndexPath: indexPath)!
            
            cell.textField.placeholder = "Description"
            
            cell.textField.text = description
            
            cell.userInteractionEnabled = canEdit
            
            return cell
            
        case let .created(created):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.teamDetailLabelTableViewCell, forIndexPath: indexPath)!
            
            cell.textLabel!.text = "Created"
            
            cell.detailTextLabel!.text = TeamDetailViewController.dateFormatter.stringFromDate(created.toFoundation())
            
            return cell
            
        case let .updated(updated):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.teamDetailLabelTableViewCell, forIndexPath: indexPath)!
            
            cell.textLabel!.text = "Last Modified"
            
            cell.detailTextLabel!.text = TeamDetailViewController.dateFormatter.stringFromDate(updated.toFoundation())
            
            return cell
            
        case let .member(teamMember):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.peopleTableViewCell, forIndexPath: indexPath)!
            
            cell.name = teamMember.member.name
            cell.pictureURL = teamMember.member.pictureURL
            cell.title = teamMember.permission.rawValue.lowercaseString.capitalizedString
            
            return cell
            
        case let .owner(member):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.peopleTableViewCell, forIndexPath: indexPath)!
            
            cell.name = member.name
            cell.pictureURL = member.pictureURL
            cell.title = member.title ?? member.twitter ?? member.irc
            
            return cell
            
        case let .invitation(invitation):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.peopleTableViewCell, forIndexPath: indexPath)!
            
            cell.name = invitation.invitee.name
            cell.pictureURL = invitation.invitee.pictureURL
            cell.title = invitation.permission.rawValue.lowercaseString.capitalizedString
            
            return cell
            
        case .delete:
            
            return tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.teamDetailDeleteTableViewCell, forIndexPath: indexPath)!
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let section = self.data[section].0
        
        switch section {
            
        case .description: return nil
            
        case .owner: return "Owner"
            
        case .members: return "Members"
            
        case .invitations: return "Pending Invitations"
            
        case .delete: return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cellData = self[indexPath]
        
        switch cellData {
            
        case let .member(teamMember):
            
            let memberProfileDetailVC = R.storyboard.member.personDetailViewController()!
            
            memberProfileDetailVC.profile = .member(teamMember.member.identifier)
            
            showViewController(memberProfileDetailVC, sender: self)
            
        case let .owner(member):
            
            let memberProfileDetailVC = R.storyboard.member.personDetailViewController()!
            
            memberProfileDetailVC.profile = .member(member.identifier)
            
            showViewController(memberProfileDetailVC, sender: self)
            
        case let .invitation(invitation):
            
            let memberProfileDetailVC = R.storyboard.member.personDetailViewController()!
            
            memberProfileDetailVC.profile = .member(invitation.invitee.identifier)
            
            showViewController(memberProfileDetailVC, sender: self)
            
        case .delete:
            
            showActivityIndicator()
            
            Store.shared.delete(team: team) { (response) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                    
                    guard let controller = self else { return }
                    
                    controller.dismissActivityIndicator()
                    
                    if let error = response {
                        
                        controller.showErrorMessage(error as NSError)
                    }
                }
            }
            
        default: break
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        let cellData = self[indexPath]
        
        switch cellData {
            
        case .member:
            
            return canEdit ? .Delete : .None
            
        default:
            
            return .None
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let cellData = self[indexPath]
        
        if editingStyle == .Delete {
            
            switch cellData {
                
            case let .member(teamMember):
                
                showActivityIndicator()
                
                Store.shared.remove(member: teamMember.identifier, from: team) { (response) in
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                        
                        guard let controller = self else { return }
                        
                        controller.dismissActivityIndicator()
                        
                        if let error = response {
                            
                            controller.showErrorMessage(error as NSError)
                        }
                    }
                }
                
            default: break
                
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField === self.nameTextField {
            
            let newName = self.nameTextField.text ?? ""
            
            let description = teamCache.descriptionText
            
            showActivityIndicator()
            
            Store.shared.update(team: team, name: newName, description: description) { (response) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                    
                    guard let controller = self else { return }
                    
                    controller.dismissActivityIndicator()
                    
                    if let error = response {
                        
                        controller.showErrorMessage(error as NSError)
                        
                    }
                }
            }
            
            return false
        }
        
        // table view cell text field
        let pointInTable = textField.convertPoint(textField.bounds.origin, toView: self.tableView)
        if let indexPath = self.tableView.indexPathForRowAtPoint(pointInTable) {
            
            let cellData = self[indexPath]
            
            switch cellData {
                
            case .description:
                
                let name = teamCache.name
                
                let newDescription = textField.text
                
                showActivityIndicator()
                
                Store.shared.update(team: team, name: name, description: newDescription) { (response) in
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                        
                        guard let controller = self else { return }
                        
                        controller.dismissActivityIndicator()
                        
                        if let error = response {
                            
                            controller.showErrorMessage(error as NSError)
                        }
                    }
                }
                
                return false
                
            default: break
            }
        }
        
        return true
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case R.segue.teamDetailViewController.addMember.identifier:
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let addTeamMemberViewController = navigationController.topViewController as! AddTeamMemberViewController
            
            addTeamMemberViewController.team = self.team
            
        default: fatalError("Unknown segue")
        }
    }
}

// MARK: - Supporting Types

private extension TeamDetailViewController {
    
    enum Section {
        
        case description
        case owner
        case members
        case invitations
        case delete
    }
    
    enum Cell {
        
        case description(String?)
        case created(Date)
        case updated(Date)
        case owner(Member)
        case member(TeamMember)
        case invitation(TeamInvitation)
        case delete
    }
}

final class TeamDetailTextFieldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
}
