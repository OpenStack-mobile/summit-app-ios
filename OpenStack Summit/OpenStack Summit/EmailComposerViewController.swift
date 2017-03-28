//
//  Email.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/07/17.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

protocol EmailComposerViewController: class, MFMailComposeViewControllerDelegate {
    
    func sendEmail(to email: String)
}

extension EmailComposerViewController {
    
    func sendEmail(to email: String) {
        
        guard let viewController = self as? UIViewController
            else { fatalError("Not a view controller") }
        
        guard MFMailComposeViewController.canSendMail() else {
            
            viewController.showErrorAlert("Cannot send mail. Please configure your email in Settings.")
            
            return
        }
        
        let composerVC = MFMailComposeViewController()
        
        composerVC.setToRecipients([email])
        
        composerVC.mailComposeDelegate = self
        
        viewController.presentViewController(composerVC, animated: true, completion: nil)
    }
}
