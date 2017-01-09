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

final class TeamDetailViewController: UITableViewController, NSFetchedResultsControllerDelegate, UITextFieldDelegate, MessageEnabledViewController, ShowActivityIndicatorProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var nameTextField: UITextField!
    
    // MARK: - Properties
    
    var team: Identifier!
    
    private var entityController: EntityController<Team>!
    
    private var teamCache: Team!
    
    private var data = [Section: [Cell]]()
    
    private static let dateFormatter: NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter
    }()
    
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
        
        // fetch from server
        self.refresh()
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
        
        self.teamCache = team
        
        self.nameTextField.text = team.name
        
        self.data.removeAll()
        
        self.data[.description] = [.description(team.descriptionText),
                                   .created(team.created),
                                   .updated(team.updated)]
        
        self.data[.owner] = [.member(team.owner, nil)]
        
        self.data[.members] = team.members
            .sort()
            .filter({ $0.member.identifier != team.owner.identifier }) // filter owner from members list
            .map { .member($0.member, $0.permission) }
        
        self.data[.delete] = [.delete]
        
        self.tableView.reloadData()
    }
    
    private subscript (indexPath: NSIndexPath) -> Cell {
        
        let section = Section(rawValue: indexPath.section)!
        
        let rows = self.data[section]!
        
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
        
        return Section.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = Section(rawValue: section)!
        
        let rows = self.data[section]!
        
        return rows.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellData = self[indexPath]
        
        switch cellData {
            
        case let .description(description):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.teamDetailTextFieldTableViewCell, forIndexPath: indexPath)!
            
            cell.textField.placeholder = "Description"
            
            cell.textField.text = description
            
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
            
        case let .member(member, permission):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.peopleTableViewCell, forIndexPath: indexPath)!
            
            cell.name = member.name
            cell.pictureURL = member.pictureURL
            cell.title = permission?.rawValue ?? ""
            
            return cell
            
        case .delete:
            
            return tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.teamDetailDeleteTableViewCell, forIndexPath: indexPath)!
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cellData = self[indexPath]
        
        switch cellData {
            
        case let .member(member, _):
            
            let memberProfileDetailVC = R.storyboard.member.memberProfileDetailViewController()!
            
            memberProfileDetailVC.profile = .member(member.identifier)
            
            showViewController(memberProfileDetailVC, sender: self)
            
        case .delete:
            
            showActivityIndicator()
            
            Store.shared.delete(team: team) { (response) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                    
                    guard let controller = self else { return }
                    
                    controller.hideActivityIndicator()
                    
                    if let error = response {
                        
                        controller.showErrorMessage(error as NSError)
                        
                    } else {
                        
                        // entity controller will manage
                    }
                }
            }
            
        default: break
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let section = Section(rawValue: section)!
        
        switch section {
            
        case .description: return nil
            
        case .owner: return "Owner"
            
        case .members: return self.data[.members]!.isEmpty ? nil : "Members"
            
        case .delete: return nil
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField === self.nameTextField {
            
            let newName = self.nameTextField.text ?? ""
            
            let description = teamCache.descriptionText
            
            showActivityIndicator()
            
            Store.shared.update(team: team, name: newName, description: description, completion: { (response) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                    
                    guard let controller = self else { return }
                    
                    controller.hideActivityIndicator()
                    
                    if let error = response {
                        
                        controller.showErrorMessage(error as NSError)
                        
                    } else {
                        
                        // do nothing, entity controller will update
                    }
                }
            })
            
            return false
        }
        
        return true
    }
}

// MARK: - Supporting Types

private extension TeamDetailViewController {
    
    enum Section: Int {
        
        static let count = 4
        
        case description
        case owner
        case members
        case delete
    }
    
    enum Cell {
        
        case description(String?)
        case created(Date)
        case updated(Date)
        case member(Member, TeamPermission?)
        case delete
    }
}

final class TeamDetailTextFieldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
}
