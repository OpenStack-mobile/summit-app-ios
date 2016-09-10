//
//  LoadSummitDataViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/9/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit

@objc(OSSTVLoadSummitDataViewController)
final class LoadSummitDataViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var gestureRecognizer: UITapGestureRecognizer!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(menuTap))
        gestureRecognizer.allowedPressTypes = [UIPressType.Menu.rawValue as NSNumber]
        self.view.addGestureRecognizer(gestureRecognizer)
        
        loadData()
    }
    
    // MARK: - Actions
    
    @IBAction @objc private func menuTap(sender: UITapGestureRecognizer) {
        
        
    }
    
    // MARK: - Private Methods
    
    private func loadData() {
        
        Store.shared.summit { [weak self] (response) in
            
            guard let controller = self else { return }
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.showErrorAlert((error as NSError).localizedDescription, retryHandler: { controller.loadData() })
                    
                case .Value:
                    
                    controller.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
}

extension UIViewController {
    
    func loadSummitData() {
        
        let storyboard = UIStoryboard(name: "Loading", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! LoadSummitDataViewController
        
        self.presentViewController(viewController, animated: true, completion: nil)
    }
}