//
//  ContextMenuViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/26/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit

protocol ContextMenuViewController: class {
    
    var contextMenu: ContextMenu { get }
}

extension ContextMenuViewController {
    
    func addContextMenuBarButtonItem() {
        
        guard let viewController = self as? UIViewController
            else { fatalError("\(self) is not a view controller") }
        
        let barButtonItem = UIBarButtonItem(image: R.image.contextMenu(), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UIViewController.showControllerContextMenu))
        
        viewController.navigationItem.rightBarButtonItem = barButtonItem
    }
}

private extension UIViewController {
    
    @objc func showControllerContextMenu(sender: UIBarButtonItem) {
        
        guard let contextMenuViewController = self as? ContextMenuViewController
            else { fatalError("\(self) is not a ContextMenuViewController") }
        
        let contextMenu = contextMenuViewController.contextMenu
        
        self.show(contextMenu: contextMenu, sender: .barButtonItem(sender))
    }
}

extension UIViewController {
    
    func show(contextMenu contextMenu: ContextMenu, sender: PopoverPresentingView) {
        
        let menuViewController: UIViewController
        
        if contextMenu.shareItems.isEmpty {
            
            let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            contextMenu.actions.forEach { (action) in
                
                let action = UIAlertAction(title: action.title, style: .Default, handler: { [weak self] _ in
                
                    switch action.handler {
                        
                    case let .modal(handler):
                        
                        let viewController = handler { _ in
                            
                            self?.dismissViewControllerAnimated(true, completion: nil)
                        }
                        
                        self?.present(viewController: viewController, sender: sender)
                        
                    case let .background(handler):
                        
                        alertViewController.dismissViewControllerAnimated(true, completion: { handler { _ in } })
                    }
                })
                
                alertViewController.addAction(action)
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in })
            
            alertViewController.addAction(cancel)
            
            menuViewController = alertViewController
            
        } else {
            
            var activites = [UIActivity]()
            
            activites += contextMenu.actions.map { ContextMenuActionActivity(action: $0) }
            
            let activityViewController = UIActivityViewController(activityItems: contextMenu.shareItems, applicationActivities: activites)
            
            if contextMenu.systemActions == false {
                
                activityViewController.excludedActivityTypes = [UIActivityTypeAddToReadingList,
                                                                UIActivityTypeOpenInIBooks]
            }
            
            menuViewController = activityViewController
        }
        
        self.present(viewController: menuViewController, sender: sender)
    }
}

struct ContextMenu {
    
    var actions = [Action]()
    
    var shareItems = [AnyObject]()
    
    var systemActions = true
}

extension ContextMenu {
    
    struct Action {
        
        let activityType: String
        
        let image: (() -> UIImage)?
        
        let title: String
        
        let handler: Handler
        
        enum Handler {
            
            case modal((Bool -> ()) -> UIViewController)
            case background((Bool -> ()) -> ())
        }
    }
}

// MARK: - UIActivity

@objc final class ContextMenuActionActivity: UIActivity {
    
    let action: ContextMenu.Action
    
    init(action: ContextMenu.Action) {
        
        self.action = action
        
        super.init()
    }
    
    override class func activityCategory() -> UIActivityCategory {
        
        return .Action
    }
    
    override func activityType() -> String? {
        
        return action.activityType
    }
    
    override func activityTitle() -> String? {
        
        return action.title
    }
    
    override func activityImage() -> UIImage? {
        
        return action.image?()
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        
        return true
    }
    
    override func activityViewController() -> UIViewController? {
        
        switch action.handler {
            
        case let .modal(handler):
            
            return handler({ [weak self] in self?.activityDidFinish($0) })
            
        case .background:
            
            return nil
        }
    }
    
    override func performActivity() {
        
        switch action.handler {
            
        case .modal: super.performActivity()
            
        case let .background(handler):
            
            handler({ [weak self] in self?.activityDidFinish($0) })
        }
    }
}

final class OpenInSafariActivity: UIActivity {
    
    private var url: NSURL!
    
    override class func activityCategory() -> UIActivityCategory {
        
        return .Action
    }
    
    override func activityType() -> String? {
        
        return "\(self.dynamicType)"
    }
    
    override func activityTitle() -> String? {
        
        return "Open in Safari"
    }
    
    override func activityImage() -> UIImage? {
        
        return R.image.openInSafariActivity()!
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        
        return url(from: activityItems) != nil
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        
        self.url = url(from: activityItems)!
    }
    
    override func performActivity() {
        
        let completed = UIApplication.sharedApplication().openURL(self.url)
        
        self.activityDidFinish(completed)
    }
    
    private func url(from activityItems: [AnyObject]) -> NSURL? {
        
        return activityItems.firstMatching({ (item) in
            
            if let url = item as? NSURL where UIApplication.sharedApplication().canOpenURL(url) {
                
                return true
                
            } else {
                
                return false
            }
            
        }) as! NSURL?
    }
}

final class CopyLinkActivity: UIActivity {
    
    private var url: NSURL!
    
    override class func activityCategory() -> UIActivityCategory {
        
        return .Action
    }
    
    override func activityType() -> String? {
        
        return "\(self.dynamicType)"
    }
    
    override func activityTitle() -> String? {
        
        return "Copy Link"
    }
    
    override func activityImage() -> UIImage? {
        
        return R.image.openInSafariActivity()!
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        
        return url(from: activityItems) != nil
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        
        self.url = url(from: activityItems)!
    }
    
    override func performActivity() {
        
        UIPasteboard.generalPasteboard().string = self.url.absoluteString ?? ""
        
        self.activityDidFinish(true)
    }
    
    private func url(from activityItems: [AnyObject]) -> NSURL? {
        
        return activityItems.firstMatching({ (item) in
            
            if let url = item as? NSURL where UIApplication.sharedApplication().canOpenURL(url) {
                
                return true
                
            } else {
                
                return false
            }
            
        }) as! NSURL?
    }
}
