//
//  MemberOrderConfirmViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

final class MemberOrderConfirmViewController: UIViewController, RevealViewController, MessageEnabledViewController, ShowActivityIndicatorProtocol, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var orderNumberText: UITextField!
    @IBOutlet weak var personPicker: UIPickerView!
    @IBOutlet weak var multipleAttendeesMatchingLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: - Properties
    
    private var attendees = [NonConfirmedAttendee]()
    
    private var orderNumber: String!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderNumberText.delegate = self
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(MemberOrderConfirmViewController.resignOnTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(singleTap)
        
        menuButton.target = self
        menuButton.action = #selector(MemberOrderConfirmViewController.menuButtonPressed(_:))
        
        self.title = "MY PROFILE"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let scrollPoint = CGPointMake(0, 0)
        scrollView.setContentOffset(scrollPoint, animated: false)
        registerKeyboardNotifications()
        showAttendeesSelector(false)
        orderNumberText.text = ""
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    // MARK: - IB Action
    
    @IBAction func confirmButtonPressed(sender: UIButton) {
        let row = personPicker.selectedRowInComponent(0)
        if row > 0 {
            self.selectAttendeeFromOrderList(row - 1)
        }
    }
    
    @IBAction func menuButtonPressed(sender: UIBarButtonItem) {
        orderNumberText.resignFirstResponder()
        revealViewController().revealToggle(sender)
    }
    
    @IBAction func resignOnTap(sender: AnyObject) {
        orderNumberText.resignFirstResponder()
    }
    
    // MARK: - Private Methods
    
    private func orderConfirm(orderNumber: String) {
        
        self.orderNumber = orderNumber
        
        self.showActivityIndicator()
        
        Store.shared.attendees(for: orderNumber) { [weak self] (response) in
            
            guard let controller = self else { return }
            
            defer { controller.hideActivityIndicator() }
            
            switch response {
                
            case let .Error(error):
                
                let code = (error as NSError).code
                
                switch code {
                    
                case 412:
                    
                    controller.showInfoMessage("Info", message: "This Order# has already been associated with another user. If you feel this is an error, please contact summitapp@openstack.org or enter a different Order #.")
                    
                case 404:
                    
                    controller.showInfoMessage("Info", message: "Order wasn\'t found. Please verify that you provided correct order # and try again.")
                    
                default:
                    
                    controller.showErrorMessage(error as NSError)
                }
                
            case let .Value(attendees):
                
                controller.attendees = attendees
                
                if (attendees.count == 0) {
                    controller.showInfoMessage("Info", message: "Order wasn\'t found. Please verify that you provided correct order # and try again.");
                }
                else if (attendees.count == 1) {
                    controller.selectAttendeeFromOrderList(0)
                }
                else if (attendees.count > 1) {
                    
                    controller.multipleAttendeesMatchingLabel.hidden = false
                    controller.personPicker.hidden = false
                    controller.personPicker.delegate = self
                    controller.personPicker.dataSource = self
                    
                    let scrollPoint = CGPointMake(0, controller.scrollView.contentSize.height - controller.scrollView.bounds.size.height + 40)
                    controller.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0)
                    controller.scrollView.setContentOffset(scrollPoint, animated: true)
                }
                
                controller.showAttendeesSelector(attendees.count > 0)
            }
        }
    }
    
    private func selectAttendeeFromOrderList(index: Int) {
        
        showActivityIndicator()
        
        let summit = SummitManager.shared.summit.value
        
        let nonConfirmedSummitAttendee = attendees[index]
        
        Store.shared.selectAttendee(from: orderNumber, externalAttendee: nonConfirmedSummitAttendee.identifier, summit: summit) { [weak self] (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                guard let controller = self else { return }
                
                controller.hideActivityIndicator()
                
                switch response {
                    
                case let .Some(error):
                    
                    let code = (error as NSError).code
                    
                    switch code {
                        
                    case 412:
                        
                        controller.showInfoMessage("Info", message: "This Order# has already been associated with another user. If you feel this is an error, please contact summitapp@openstack.org or enter a different Order #.")
                        
                    case 404:
                        
                        controller.showInfoMessage("Info", message: "Order wasn\'t found. Please verify that you provided correct order # and try again.")
                        
                    default:
                        
                        controller.showErrorMessage(error)
                    }
                    
                case .None:
                    
                    Store.shared.currentMember(for: summit) { (response) in
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            
                            switch response {
                                
                            case let .Error(error):
                                
                                controller.showErrorMessage(error)
                                
                            case .Value:
                                
                                controller.showAttendeesSelector(false)
                                AppDelegate.shared.menuViewController.showEvents()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func showAttendeesSelector(show: Bool) {
        scrollView.scrollEnabled = show
        personPicker.hidden = !show
        multipleAttendeesMatchingLabel.hidden = !show
        confirmButton.hidden = !show
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        orderNumberText.resignFirstResponder()
        if !orderNumberText.text!.isEmpty {
            self.orderConfirm(orderNumberText.text!)
        }
        return true
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return attendees.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return attendees[row].name
    }
    
    // MARK: - Notifications
    
    private func registerKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemberOrderConfirmViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemberOrderConfirmViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unregisterKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var viewRect = view.frame
        viewRect.size.height -= keyboardSize.height
        if CGRectContainsPoint(viewRect, orderNumberText.frame.origin) {
            let scrollPoint = CGPointMake(0, orderNumberText.frame.origin.y - keyboardSize.height + 40)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
        let scrollPoint = CGPointMake(0, 0)
        scrollView.setContentOffset(scrollPoint, animated: true)
    }
}
