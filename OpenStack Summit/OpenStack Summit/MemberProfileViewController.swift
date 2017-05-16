//
//  MemberProfileViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/20/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import KTCenterFlowLayout
import CoreSummit

final class MemberProfileViewController: RevealTabStripViewController, ContextMenuViewController {
    
    // MARK: - Properties
    
    let profile: PersonIdentifier
    
    lazy var memberProfileDetailViewController: PersonDetailViewController = {
        
        let memberProfileDetailViewController = R.storyboard.member.personDetailViewController()!
        
        memberProfileDetailViewController.profile = self.profile
        
        return memberProfileDetailViewController
    }()
    
    var contextMenu: ContextMenu { return memberProfileDetailViewController.contextMenu }
    
    // MARK: - Initialization
    
    init(profile: PersonIdentifier = PersonIdentifier()) {
        
        self.profile = profile
        
        super.init(nibName: nil, bundle: nil) // not created from NIB
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // try to get name
        
        switch profile {
            
        case let .speaker(identifier):
            
            if let person = try! Speaker.find(identifier, context: Store.shared.managedObjectContext) {
                
                self.title = person.name.uppercased()
            }
            
        case let .member(identifier):
            
            if let person = try! Member.find(identifier, context: Store.shared.managedObjectContext) {
                
                self.title = person.name.uppercased()
            }
            
        case .currentUser:
            
            break
        }
        
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
        
        addContextMenuBarButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadPagerTabStripView()
    }
    
    // MARK: - RevealTabStripViewController
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var childViewControllers = [UIViewController]()
        
        childViewControllers.append(memberProfileDetailViewController)
        
        if case let .speaker(identifier) = profile {
            
            let speakerPresentationsViewController = R.storyboard.schedule.speakerPresentationsViewController()!
            
            // set speaker ID
            speakerPresentationsViewController.speaker = identifier
            
            childViewControllers.append(speakerPresentationsViewController)
        }
        
        return childViewControllers
    }
}
