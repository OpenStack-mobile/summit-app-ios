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
    
    @IBOutlet private weak var selectedMemberCell: SelectTeamMemberTableViewCell!
    
    @IBOutlet private weak var adminPermissionCell: UITableViewCell!
    
    @IBOutlet private weak var readPermissionCell: UITableViewCell!
    
    @IBOutlet private weak var writePermissionCell: UITableViewCell!
    
    @IBOutlet private weak var doneBarButtonItem: UIBarButtonItem!
    
    // MARK: - Properties
    
    var team: Identifier!
    
    private(set) var permission: TeamPermission? {
        
        didSet { if isViewLoaded { configureView() } }
    }
    
    private(set) var member: Member? {
        
        didSet { if isViewLoaded { configureView() } }
    }
    
    private lazy var permissionCells: [UITableViewCell] = [self.adminPermissionCell,
                                                           self.readPermissionCell,
                                                           self.writePermissionCell]
    
    private var teamCache: Team!
    
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
            
            OperationQueue.main.addOperation { [weak self] in
                
                guard let controller = self else { return }
                
                controller.dismissActivityIndicator()
                
                switch response {
                    
                case let .error(error):
                    
                    controller.showErrorMessage(error as NSError)
                    
                case .value:
                    
                    controller.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        guard let team = try! Team.find(self.team, context: Store.shared.managedObjectContext)
            else { fatalError("Team not present") }
        
        self.teamCache = team
        
        // configure member cell
        
        if let selectedMember = self.member {
            
            self.selectedMemberCell.selectMemberLabel.isHidden = true
            self.selectedMemberCell.nameLabel.text = selectedMember.name
            self.selectedMemberCell.titleLabel.text = selectedMember.title ?? selectedMember.twitter ?? selectedMember.irc
            self.selectedMemberCell.picture = selectedMember.picture
            
        } else {
            
            self.selectedMemberCell.picture = nil
        }
        
        self.selectedMemberCell.selectMemberLabel.isHidden = self.member != nil
        self.selectedMemberCell.nameLabel.isHidden = self.member == nil
        self.selectedMemberCell.titleLabel.isHidden = self.member == nil
        
        // configure permission cells
        
        permissionCells.forEach { $0.accessoryType = .none }
        
        if let selectedPermission = self.permission {
            
            let cell = self.cell(for: selectedPermission)
            
            cell.accessoryType = .checkmark
        }
        
        // enable `Done` button
        self.doneBarButtonItem.isEnabled = self.member != nil && self.permission != nil
    }
    
    private func cell(for permission: TeamPermission) -> UITableViewCell {
        
        switch permission {
        case .admin: return adminPermissionCell
        case .read:  return readPermissionCell
        case .write: return writePermissionCell
        }
    }
    
    private func permission(for cell: UITableViewCell) -> TeamPermission {
        
        switch cell {
        case adminPermissionCell: return .admin
        case readPermissionCell: return .read
        case writePermissionCell: return .write
        default: fatalError("Unknown cell: \(cell)")
        }
    }
    
    // MARK: - SearchMembersViewControllerDelegate
    
    private func searchMembersViewController(_ searchMembersViewController: SearchMembersViewController, didSelect member: Member) {
        
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
    
    @IBOutlet private(set) weak var nameLabel : UILabel!
    @IBOutlet private(set) weak var titleLabel : UILabel!
    @IBOutlet private weak var pictureImageView: UIImageView!
    @IBOutlet private(set) weak var selectMemberLabel: UILabel!
    
    fileprivate var picture: URL? {
        
        didSet {
            
            let placeholder = #imageLiteral(resourceName: "generic-user-avatar")
            
            if let url = picture {
                
                pictureImageView.hnk_setImageFromURL(url.environmentScheme, placeholder: placeholder)
                
            } else {
                
                pictureImageView.image = #imageLiteral(resourceName: "generic-user-avatar")
            }
            
            pictureImageView.layer.cornerRadius = pictureImageView.frame.size.width / 2
            pictureImageView.clipsToBounds = true
        }
    }
}
