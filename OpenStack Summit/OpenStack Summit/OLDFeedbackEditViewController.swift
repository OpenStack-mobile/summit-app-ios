//
//  FeedbackEditViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Cosmos
import CoreSummit
import JGProgressHUD

final class FeedbackEditViewController: UIViewController, UITextViewDelegate, ActivityViewController, MessageEnabledViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var reviewTextArea: UITextView!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Properties
    
    var event: Identifier!
    
    private var eventCache: Event!
    
    private let placeHolderText = "Add your review (up to 500 characters)"
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .Dark)
    
    // MARK: - Accessors
    
    var rate: Int {
        get {
            
            // force view load
            let _ = self.view
            
            return Int(rateView.rating)
        }
        set {
            
            // force view load
            let _ = self.view
            
            rateView.rating = Double(newValue)
        }
    }
    
    private(set) var review: String {
        get {
            return reviewTextArea.text != placeHolderText ? reviewTextArea.text : ""
        }
        set {
            reviewTextArea.text = newValue
        }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBlankBackBarButtonItem()
        
        navigationItem.title = "RATE SESSION"
        reviewTextArea.delegate = self
        
        sendButton.layer.cornerRadius = 10
        reviewTextArea.returnKeyType = .Done
        
        guard let event = try! Event.find(self.event, context: Store.shared.managedObjectContext)
            else { fatalError("Invalid event \(self.event)") }
        
        self.eventCache = event
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reviewTextArea.text = placeHolderText
        reviewTextArea.textColor = UIColor.lightGrayColor()
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterKeyboardNotifications()
    }
    
    // MARK: - Actions
    
    @IBAction func sendFeedback(sender: AnyObject? = nil) {
        
        guard Reachability.connected
            else { showErrorMessage(Error.reachability); return }
        
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
        
        let summit = eventCache.summit
        
        Store.shared.addFeedback(summit, event: event, rate: rate, review: review) { [weak self] (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                guard let controller = self else { return }
                
                controller.dismissActivityIndicator()
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.showErrorMessage(error as NSError)
                    
                case .Value:
                    
                    controller.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        reviewTextArea.textColor = UIColor.blackColor()
        
        if(reviewTextArea.text == placeHolderText) {
            reviewTextArea.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if(reviewTextArea.text == "") {
            reviewTextArea.text = placeHolderText
            reviewTextArea.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text.characters.count == 1 {
            if let _ = text.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet(), options: NSStringCompareOptions.BackwardsSearch) {
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
    
    // MARK: - Notifications
    
    @objc private func registerKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedbackEditViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedbackEditViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @objc private func unregisterKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var viewRect = view.frame
        viewRect.size.height -= keyboardSize.height
        if CGRectContainsPoint(viewRect, reviewTextArea.frame.origin) {
            let scrollPoint = CGPointMake(0, reviewTextArea.frame.origin.y - keyboardSize.height)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}
