//
//  AddTeamMemberViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/10/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import CoreSummit
import JGProgressHUD

final class AddTeamMemberViewController: UITableViewController, MessageEnabledViewController, ActivityViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet fileprivate weak var selectedMemberCell: SelectTeamMemberTableViewCell!
    
    @IBOutlet fileprivate weak var adminPermissionCell: UITableViewCell!
    
    @IBOutlet fileprivate weak var readPermissionCell: UITableViewCell!
    
    @IBOutlet fileprivate weak var writePermissionCell: UITableViewCell!
    
    @IBOutlet fileprivate weak var doneBarButtonItem: UIBarButtonItem!
    
    // MARK: - Properties
    
    var team: Identifier!
    
    fileprivate(set) var permission: TeamPermission? {
        
        didSet { if isViewLoaded { configureView() } }
    }
    
    fileprivate(set) var member: Member? {
        
        didSet { if isViewLoaded { configureView() } }
    }
    
    fileprivate lazy var permissionCells: [UITableViewCell] = [self.adminPermissionCell,
                                                           self.readPermissionCell,
                                                           self.writePermissionCell]
    
    fileprivate var teamCache: Team!
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .dark)
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: AnyObject? = nil) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: AnyObject? = nil) {
        
        guard let permission = self.permission,
            let member = self.member
            else { fatalError("Member or permission not selected") }
        
        self.showActivityIndicator()
        
        Store.shared.add(member: member.identifier, to: team, permission: permission) { (response) in
            
            OperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                controller.dismissActivityIndicator()
                
                switch response {
                    
                case let .error(error):
                    
                    controller.showErrorMessage(error as NSError)
                    
                case .Value:
                    
                    controller.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    fileprivate func configureView() {
        
        guard let team = try! Team.find(self.team, context: Store.shared.managedObjectContext)
            else { fatalError("Team not present") }
        
        self.teamCache = team
        
        // configure member cell
        
        if let selectedMember = self.member {
            
            self.selectedMemberCell.selectMemberLabel.isHidden = true
            self.selectedMemberCell.nameLabel.text = selectedMember.name
            self.selectedMemberCell.titleLabel.text = selectedMember.title ?? selectedMember.twitter ?? selectedMember.irc
            self.selectedMemberCell.pictureURL = selectedMember.pictureURL
            
        } else {
            
            self.selectedMemberCell.pictureURL = ""
        }
        
        self.selectedMemberCell.selectMemberLabel.hidden = self.member != nil
        self.selectedMemberCell.nameLabel.hidden = self.member == nil
        self.selectedMemberCell.titleLabel.hidden = self.member == nil
        
        // configure permission cells
        
        permissionCells.forEach { $0.accessoryType = .none }
        
        if let selectedPermission = self.permission {
            
            let cell = self.cell(for: selectedPermission)
            
            cell.accessoryType = .Checkmark
        }
        
        // enable `Done` button
        self.doneBarButtonItem.enabled = self.member != nil && self.permission != nil
    }
    
    fileprivate func cell(for permission: TeamPermission) -> UITableViewCell {
        
        switch permission {
        case .admin: return adminPermissionCell
        case .read:  return readPermissionCell
        case .write: return writePermissionCell
        }
    }
    
    fileprivate func permission(for cell: UITableViewCell) -> TeamPermission {
        
        switch cell {
        case adminPermissionCell: return .admin
        case readPermissionCell: return .read
        case writePermissionCell: return .write
        default: fatalError("Unknown cell: \(cell)")
        }
    }
    
    // MARK: - SearchMembersViewControllerDelegate
    
    fileprivate func searchMembersViewController(_ searchMembersViewController: SearchMembersViewController, didSelect member: Member) {
        
        guard teamCache.permission(for: member.identifier) == nil
            else { return }
        
        self.member = member
        
        self.navigationController!.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath)
            else { return }
        
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
            
        case .member:
            
            // show member picker
            
            let searchMembersViewController = R.storyboard.member.searchMembersViewController()!
            
            searchMembersViewController.selectedMember = { [weak self] in self?.searchMembersViewController($0.0, didSelect: $0.1) }
            
            self.show(searchMembersViewController, sender: self)
            
        case .permission:
            
            // select permission
            
            self.permission = self.permission(for: cell)
        }
    }
}

// MARK: - Supporting Types

private extension AddTeamMemberViewController {
    
    enum Section: Int {
        
        case member
        case permission
    }
}

final class SelectTeamMemberTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate(set) weak var nameLabel : UILabel!
    @IBOutlet fileprivate(set) weak var titleLabel : UILabel!
    @IBOutlet fileprivate weak var pictureImageView: UIImageView!
    @IBOutlet fileprivate(set) weak var selectMemberLabel: UILabel!
    
    var pictureURL: String = "" {
        
        didSet {
            
            let picUrlInternal: String
            
            picUrlInternal = pictureURL.replacingOccurrences(of: "https", with: "http", options: NSString.CompareOptions.literal, range: nil)
            
            if (!picUrlInternal.isEmpty) {
                let placeholder = R.image.genericUserAvatar()!
                pictureImageView.hnk_setImageFromURL(Foundation.URL(string: picUrlInternal)!, placeholder: placeholder)
            }
            else {
                pictureImageView.image = R.image.genericUserAvatar()!
            }
            pictureImageView.layer.cornerRadius = pictureImageView.frame.size.width / 2
            pictureImageView.clipsToBounds = true;
        }
    }
}
