//
//  FeedbackEditViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftSpinner
import Cosmos

@objc
public protocol IFeedbackEditViewController: MessageEnabledViewController {
    
    var rate: Int { get set }
    var review: String! { get set }
    
    func showCreateFeedback()
    func showEditFeedback(feedback: FeedbackDTO)
    func showActivityIndicator()
    func hideActivityIndicator()
}

class FeedbackEditViewController: BaseViewController, IFeedbackEditViewController, UITextViewDelegate {
    
    var presenter: IFeedbackEditPresenter!
    @IBOutlet weak var reviewTextArea: UITextView!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var rate: Int {
        get {
            return Int(rateView.rating)
        }
        set {
            rateView.rating = Double(newValue)
        }
    }
    
    var review: String {
        get {
            return reviewTextArea.text != placeHolderText ? reviewTextArea.text : ""
        }
        set {
            reviewTextArea.text = newValue
        }
    }
    
    var placeHolderText = "Add your review (up to 500 characters)"
    
    override func viewDidLoad() {
        navigationItem.title = "FEEDBACK"
        super.viewDidLoad()
        reviewTextArea.delegate = self
        
        sendButton.layer.cornerRadius = 10
        reviewTextArea.returnKeyType = UIReturnKeyType.Done
    }
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewLoad()
        reviewTextArea.text = placeHolderText
        reviewTextArea.textColor = UIColor.lightGrayColor()
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    func registerKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardDidShow(notification: NSNotification) {
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
    
    func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showCreateFeedback() {
        
    }

    func showEditFeedback(feedback: FeedbackDTO) {
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func showActivityIndicator() {
        SwiftSpinner.show("Please wait...")
    }
    
    func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
    @IBAction func sendFeedback(sender: AnyObject) {
        presenter.saveFeedback()
    }
}
