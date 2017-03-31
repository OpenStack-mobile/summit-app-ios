//
//  FeedbackViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 3/29/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftFoundation
import CoreSummit
import Cosmos
import JGProgressHUD

final class FeedbackViewController: UIViewController, MessageEnabledViewController, ActivityViewController, UITextViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var titleLabel: UILabel!
    
    @IBOutlet private(set) weak var ratingView: CosmosView!
    
    @IBOutlet private(set) weak var reviewTextView: UITextView!
    
    @IBOutlet private(set) weak var sendButton: Button!
    
    @IBOutlet private(set) weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var completion: (FeedbackViewController -> ())?
    
    var event: Identifier = 0 {
        
         didSet { if isViewLoaded() { configureView() } }
    }
    
    private var mode: Mode = .new
    
    private let placeHolderText = "Write a Review..."
    
    private let minimumBottomSpace: CGFloat = 100
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .Dark)
    
    // MARK: - Loading
    
    deinit {
        
        if isViewLoaded() {
            
            unregisterKeyboardNotifications()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ratingView.rating = 0
        
        configureView()
        
        registerKeyboardNotifications()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return [.Portrait]
    }
    
    // MARK: - Actions
    
    @IBAction func close(sender: AnyObject? = nil) {
        
        completion?(self)
    }
    
    @IBAction func send(sender: AnyObject? = nil) {
        
        guard Reachability.connected
            else { showErrorMessage(Error.reachability); return }
        
        // get new values
        
        let rate = Int(ratingView.rating)
        
        let review = reviewTextView.text != placeHolderText ? reviewTextView.text : ""
        
        // validate
        
        let validationErrorText: String?
        if rate == 0 {
            validationErrorText = "You must provide a rate using stars at the top"
        }
        else if review.characters.count > 500 {
            validationErrorText = "Review exceeded 500 characters limit"
        }
        else {
            validationErrorText = nil
        }
        
        if let errorMessage = validationErrorText {
            
            let error = NSError(domain: errorMessage, code: 7001, userInfo: nil)
            showErrorMessage(error)
            return
        }
        
        guard let _ = Store.shared.authenticatedMember
            else { return } // FIXME: handle user not logged in?
        
        // send request
        
        showActivityIndicator()
        
        let summit = SummitManager.shared.summit.value
                
        switch mode {
            
        case .new:
            
            Store.shared.addFeedback(summit, event: event, rate: rate, review: review) { [weak self] (response) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    
                    guard let controller = self else { return }
                    
                    controller.dismissActivityIndicator()
                    
                    switch response {
                        
                    case let .Error(error):
                        
                        controller.showErrorMessage(error)
                        
                    case .Value:
                        
                        controller.close()
                    }
                }
            }
            
        case .edit:
            
            Store.shared.editFeedback(summit, event: event, rate: rate, review: review)  { [weak self] (error) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    
                    guard let controller = self else { return }
                    
                    controller.dismissActivityIndicator()
                    
                    switch error {
                        
                    case let .Some(error):
                        
                        controller.showErrorMessage(error)
                        
                    case .None:
                        
                        controller.close()
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        if let feedbackManagedObject = Store.shared.authenticatedMember?.feedback(for: self.event) {
            
            mode = .edit
            
            let feedback = Feedback(managedObject: feedbackManagedObject)
            
            let event = Event(managedObject: feedbackManagedObject.event)
            
            configureView(with: event, feedback: feedback)
            
        } else {
            
            mode = .new
            
            guard let eventManagedObject = try! EventManagedObject.find(self.event, context: Store.shared.managedObjectContext)
                else { fatalError("Invalid event \(self.event)") }
            
            let event = Event(managedObject: eventManagedObject)
            
            configureView(with: event)
        }
    }
    
    private func configureView(with event: Event, feedback: Feedback? = nil) {
        
        self.titleLabel.text = event.name
        
        self.ratingView.rating = Double(feedback?.rate ?? 0)
        
        self.reviewTextView.text = feedback?.review ?? placeHolderText
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        reviewTextView.textColor = UIColor.blackColor()
        
        if reviewTextView.text == placeHolderText  {
            reviewTextView.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if reviewTextView.text == "" {
            reviewTextView.text = placeHolderText
            reviewTextView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text.characters.count == 1 {
            if let _ = text.rangeOfCharacterFromSet(.newlineCharacterSet(), options: .BackwardsSearch) {
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
    
    // MARK: - Notifications
    
    @objc private func registerKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardDidShow),
                                                         name: UIKeyboardDidShowNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardWillHide),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
    }
    
    @objc private func unregisterKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func keyboardDidShow(notification: NSNotification) {
        
        let userInfo: NSDictionary = notification.userInfo!
        var keyboardRect = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue
        keyboardRect = view.convertRect(keyboardRect, fromView: nil)
        
        let visibleHeight = self.view.frame.size.height - keyboardRect.size.height
        bottomViewHeightConstraint.constant = visibleHeight
        view.updateConstraints()
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        
        bottomViewHeightConstraint.constant = minimumBottomSpace
        view.updateConstraints()
    }
}

// MARK: - Supporting Files

extension FeedbackViewController {
    
    enum Mode {
        
        case new
        case edit
    }
}
