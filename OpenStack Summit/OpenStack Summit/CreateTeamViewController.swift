//
//  CreateTeamViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/5/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftFoundation
import CoreSummit

final class CreateTeamViewController: UITableViewController, ShowActivityIndicatorProtocol, MessageEnabledViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    // MARK: - Properties
    
    var completion: (done: (CreateTeamViewController) -> (), cancel: (CreateTeamViewController) -> ())?
    
    // MARK: - Actions
    
    @IBAction func cancel(sender: AnyObject? = nil) {
        
        self.completion?.cancel(self)
    }
    
    @IBAction func done(sender: AnyObject? = nil) {
        
        let name = self.nameTextField.text ?? ""
        
        let description = self.descriptionTextField.text ?? ""
        
        showActivityIndicator()
        
        Store.shared.create(team: name, description: description) { (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                controller.hideActivityIndicator()
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.showErrorMessage(error as NSError)
                    
                case .Value:
                    
                    controller.completion?.done(controller)
                }
            }
        }
    }
}
