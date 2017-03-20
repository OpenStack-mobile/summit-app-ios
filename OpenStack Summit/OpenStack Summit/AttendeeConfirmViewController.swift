//
//  AttendeeConfirmViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 3/17/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SwiftFoundation
import CoreSummit
import JGProgressHUD

final class AttendeeConfirmViewController: UITableViewController, MessageEnabledViewController, ActivityViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // MARK: - Properties
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .Dark)
    
    private var input: Input = .orderNumber {
        
        didSet { configureView() }
    }
    
    private var cells = [Cell]()
    
    private var attendees = [NonConfirmedAttendee]() {
        
        didSet { configureView() }
    }
    
    private var selectedAttendee: NonConfirmedAttendee?
    
    private var orderNumber = ""
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        configureView()
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(sender: AnyObject? = nil) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addOrder(sender: AnyObject? = nil) {
        
        switch input {
            
        case .orderNumber:
            
            orderConfirm()
            
        case .nameSelection:
            
            selectAttendeeFromOrderList()
        }
    }
    
    // MARK: - Methods
    
    private func configureView() {
        
        let inputCell: Cell
        
        switch input {
        case .orderNumber: inputCell = .order
        case .nameSelection: inputCell = .selection
        }
        
        cells = [inputCell, .action]
        
        tableView.reloadData()
    }
    
    private func configure() {
        
        
    }
    
    private func orderConfirm() {
        
        self.showActivityIndicator()
        
        Store.shared.attendees(for: orderNumber) { [weak self] (response) in
            
            guard let controller = self else { return }
            
            defer { controller.dismissActivityIndicator() }
            
            switch response {
                
            case let .Error(error):
                
                let code = (error as NSError).code
                
                switch code {
                    
                case 412:
                    
                    controller.showInfoMessage("Info", message: "This Order# has already been associated with another user. If you feel this is an error, please contact summitapp@openstack.org or enter a different Order #.")
                    
                case 404:
                    
                    controller.showInfoMessage("Info", message: "Order wasn\'t found. Please verify that you provided correct order # and try again.")
                    
                default:
                    
                    controller.showErrorMessage(error)
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
                    
                }
                
                controller.showAttendeesSelector(attendees.count > 0)
            }
        }
    }
    
    private func selectAttendeeFromOrderList(index: Int) {
        
        showActivityIndicator()
        
        let summit = SummitManager.shared.summit.value
        
        Store.shared.selectAttendee(from: orderNumber, externalAttendee: nonConfirmedSummitAttendee.identifier, summit: summit) { [weak self] (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                guard let controller = self else { return }
                
                controller.dismissActivityIndicator()
                
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
                                
                                controller.cancel()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cells.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.cells[indexPath.row]
        
        switch cell {
            
        case .order:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.attendeeConfirmOrderTableViewCell)!
            
            return cell
            
        case .selection:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.attendeeConfirmSelectionTableViewCell)!
            
            return cell
            
        case .action:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.attendeeConfirmActionTableViewCell)!
            
            return cell
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if (textField.text ?? "").isEmpty == false {
            
            self.orderConfirm()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        self.orderNumber = textField.text ?? ""
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.selectedAttendee = attendees[row]
    }
}

// MARK: - Supporting Types

private extension AttendeeConfirmViewController {
    
    enum Input {
        
        case orderNumber
        case nameSelection
    }
    
    enum Cell {
        
        case order
        case selection
        case action
    }
}

final class AttendeeConfirmOrderTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var textField: UITextField!
}

final class AttendeeConfirmSelectionTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var pickerView: UIPickerView!
}

