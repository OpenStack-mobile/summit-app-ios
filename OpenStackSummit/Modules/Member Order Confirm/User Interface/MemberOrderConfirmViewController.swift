//
//  MemberOrderConfirmViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import SwiftSpinner

@objc
protocol IMemberOrderConfirmViewController: IMessageEnabledViewController{
    func showActivityIndicator()
    func hideActivityIndicator()
    func setSummitAttendees(attendees: [NamedDTO])
    func showAttendeesSelector(show: Bool)
}

class MemberOrderConfirmViewController: RevealViewController, IMemberOrderConfirmViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var orderNumberText: UITextField!
    @IBOutlet weak var personPicker: UIPickerView!
    @IBOutlet weak var multipleAttendeesMatchingLabel: UILabel!
    
    var presenter : IMemberOrderConfirmPresenter!
    var attendees: [NamedDTO]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderNumberText.delegate = self
        
        let singleTap = UITapGestureRecognizer(target: self, action: "resignOnTap:")
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(singleTap)
        
        menuButton.target = self
        menuButton.action = Selector("menuButtonPressed:")
        
        navigationController?.navigationBar.topItem?.title = "MY PROFILE"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
        orderNumberText.text = ""
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    func registerKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var viewRect = view.frame
        viewRect.size.height -= keyboardSize.height
        if CGRectContainsPoint(viewRect, orderNumberText.frame.origin) {
            let scrollPoint = CGPointMake(0, orderNumberText.frame.origin.y - keyboardSize.height)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
        let scrollPoint = CGPointMake(0, 0)
        scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    func showActivityIndicator() {
        SwiftSpinner.showWithDelay(0.5, title: "Please wait...")
    }
    
    func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
    func menuButtonPressed(sender: UIBarButtonItem) {
        orderNumberText.resignFirstResponder()
        revealViewController().revealToggle(sender)
    }
    
    func resignOnTap(sender: AnyObject) {
        orderNumberText.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        orderNumberText.resignFirstResponder()
        if !orderNumberText.text!.isEmpty {
            presenter.orderConfirm(orderNumberText.text!)            
        }
        return true
    }
    
    func setSummitAttendees(attendees: [NamedDTO]) {
        self.attendees = [ NamedDTO() ]
        self.attendees.appendContentsOf(attendees)
        if attendees.count > 0 {
            multipleAttendeesMatchingLabel.hidden = false
            personPicker.hidden = false
            personPicker.delegate = self
            personPicker.dataSource = self
        }
    }
    
    func showAttendeesSelector(show: Bool) {
        personPicker.hidden = !show
        multipleAttendeesMatchingLabel.hidden = !show
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return attendees.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return attendees[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            presenter.selectAttendeeFromOrderList(row - 1)
        }
    }
}