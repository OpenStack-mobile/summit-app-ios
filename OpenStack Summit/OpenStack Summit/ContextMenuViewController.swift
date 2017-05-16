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
        
        let barButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "context-menu"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIViewController.showControllerContextMenu))
        
        viewController.navigationItem.rightBarButtonItem = barButtonItem
    }
}

private extension UIViewController {
    
    @objc func showControllerContextMenu(_ sender: UIBarButtonItem) {
        
        guard let contextMenuViewController = self as? ContextMenuViewController
            else { fatalError("\(self) is not a ContextMenuViewController") }
        
        let contextMenu = contextMenuViewController.contextMenu
        
        self.show(contextMenu: contextMenu, sender: .barButtonItem(sender))
    }
}

extension UIViewController {
    
    func show(contextMenu: ContextMenu, sender: PopoverPresentingView) {
        
        let menuViewController: UIViewController
        
        if contextMenu.shareItems.isEmpty {
            
            let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            contextMenu.actions.forEach { (action) in
                
                let action = UIAlertAction(title: action.title, style: .default, handler: { [weak self] _ in
                
                    switch action.handler {
                        
                    case let .modal(handler):
                        
                        let viewController = handler { _ in
                            
                            self?.dismiss(animated: true, completion: nil)
                        }
                        
                        self?.present(viewController: viewController, sender: sender)
                        
                    case let .background(handler):
                        
                        alertViewController.dismiss(animated: true, completion: { handler { _ in } })
                    }
                })
                
                alertViewController.addAction(action)
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
            
            alertViewController.addAction(cancel)
            
            menuViewController = alertViewController
            
        } else {
            
            var activites = [UIActivity]()
            
            activites += contextMenu.actions.map { ContextMenuActionActivity(action: $0) }
            
            let activityViewController = UIActivityViewController(activityItems: contextMenu.shareItems, applicationActivities: activites)
            
            if contextMenu.systemActions == false {
                
                activityViewController.excludedActivityTypes = [UIActivityType.addToReadingList,
                                                                UIActivityType.openInIBooks]
            }
            
            menuViewController = activityViewController
        }
        
        self.present(viewController: menuViewController, sender: sender)
    }
}

struct ContextMenu {
    
    var actions = [Action]()
    
    var shareItems = [Any]()
    
    var systemActions = true
}

extension ContextMenu {
    
    struct Action {
        
        let activityType: String
        
        let image: UIImage?
        
        let title: String
        
        let handler: Handler
        
        enum Handler {
            
            case modal((@escaping (Bool) -> ()) -> UIViewController)
            case background((@escaping (Bool) -> ()) -> ())
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
    
    override class var activityCategory : UIActivityCategory {
        
        return .action
    }
    
    override var activityType : UIActivityType {
        
        return UIActivityType(rawValue: action.activityType)
    }
    
    override var activityTitle : String? {
        
        return action.title
    }
    
    override var activityImage : UIImage? {
        
        return action.image
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        
        return true
    }
    
    override var activityViewController : UIViewController? {
        
        switch action.handler {
            
        case let .modal(handler):
            
            return handler({ [weak self] in self?.activityDidFinish($0) })
            
        case .background:
            
            return nil
        }
    }
    
    override func perform() {
        
        switch action.handler {
            
        case .modal: super.perform()
            
        case let .background(handler):
            
            handler({ [weak self] in self?.activityDidFinish($0) })
        }
    }
}

final class OpenInSafariActivity: UIActivity {
    
    private var url: URL!
    
    override class var activityCategory : UIActivityCategory {
        
        return .action
    }
    
    override var activityType : UIActivityType {
        
        return UIActivityType(rawValue: "\(type(of: self))")
    }
    
    override var activityTitle : String? {
        
        return "Open in Safari"
    }
    
    override var activityImage : UIImage? {
        
        return #imageLiteral(resourceName: "OpenInSafariActivity")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        
        return self.url(from: activityItems) != nil
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        
        self.url = self.url(from: activityItems)!
    }
    
    override func perform() {
        
        let completed = UIApplication.shared.openURL(self.url)
        
        self.activityDidFinish(completed)
    }
    
    private func url(from activityItems: [Any]) -> URL? {
        
        return activityItems.first(where: { (item) in
            
            if let url = item as? URL, UIApplication.shared.canOpenURL(url) {
                
                return true
                
            } else {
                
                return false
            }
            
        }) as! URL?
    }
}

final class CopyLinkActivity: UIActivity {
    
    private var url: URL!
    
    override class var activityCategory : UIActivityCategory {
        
        return .action
    }
    
    override var activityType : UIActivityType {
        
        return UIActivityType(rawValue: "\(type(of: self))")
    }
    
    override var activityTitle : String? {
        
        return "Copy Link"
    }
    
    override var activityImage : UIImage? {
        
        return #imageLiteral(resourceName: "OpenInSafariActivity")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        
        return self.url(from: activityItems) != nil
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        
        self.url = self.url(from: activityItems)!
    }
    
    override func perform() {
        
        UIPasteboard.general.string = self.url.absoluteString 
        
        self.activityDidFinish(true)
    }
    
    private func url(from activityItems: [Any]) -> URL? {
        
        return activityItems.first(where: { (item) in
            
            if let url = item as? NSURL, UIApplication.shared.canOpenURL(url as URL) {
                
                return true
                
            } else {
                
                return false
            }
            
        }) as! URL?
    }
}
