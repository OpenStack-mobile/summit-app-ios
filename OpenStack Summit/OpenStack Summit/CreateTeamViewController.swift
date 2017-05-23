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
import Foundation
import CoreSummit
import JGProgressHUD

final class CreateTeamViewController: UITableViewController, ActivityViewController, MessageEnabledViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var nameTextField: UITextField!
    
    @IBOutlet private(set) weak var descriptionTextField: UITextField!
    
    // MARK: - Properties
    
    var completion: (done: (CreateTeamViewController) -> (), cancel: (CreateTeamViewController) -> ())?
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .dark)
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: AnyObject? = nil) {
        
        self.completion?.cancel(self)
    }
    
    @IBAction func done(_ sender: AnyObject? = nil) {
        
        let name = self.nameTextField.text ?? ""
        
        let description = self.descriptionTextField.text ?? ""
        
        showActivityIndicator()
        
        Store.shared.create(team: name, description: description) { (response) in
            
            OperationQueue.main.addOperation { [weak self] in
                
                guard let controller = self else { return }
                
                controller.dismissActivityIndicator()
                
                switch response {
                    
                case let .error(error):
                    
                    controller.showErrorMessage(error as NSError)
                    
                case .value:
                    
                    controller.completion?.done(controller)
                }
            }
        }
    }
}
