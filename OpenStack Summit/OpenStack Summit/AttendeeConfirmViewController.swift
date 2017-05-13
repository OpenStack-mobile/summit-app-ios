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
import Foundation
import CoreSummit
import JGProgressHUD

final class AttendeeConfirmViewController: UITableViewController, MessageEnabledViewController, ActivityViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // MARK: - Properties
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .dark)
    
    private var input: Input = .orderNumber {
        
        didSet { configureView() }
    }
    
    private var cells = [Cell]()
    
    private var attendees = [NonConfirmedAttendee]() {
        
        didSet { configureView() }
    }
    
    private var selectedAttendee: NonConfirmedAttendee? {
        
        didSet { updateActionButtons() }
    }
    
    private var orderNumber: Int? {
        
        didSet { updateActionButtons() }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup table view
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        // add tap gesture recognizer for keyboard dismiss
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resignTap))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        // update UI
        configureView()
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: AnyObject? = nil) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addOrder(_ sender: AnyObject? = nil) {
        
        self.resignResponder(view)
        
        switch input {
            
        case .orderNumber:
            
            orderConfirm()
            
        case .nameSelection:
            
            selectAttendee()
        }
    }
    
    @IBAction func resignTap(_ sender: AnyObject? = nil) {
        
        self.resignResponder(view)
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
        
        updateActionButtons()
    }
    
    private func resignResponder(_ view: UIView) {
        
        view.resignFirstResponder()
        
        view.subviews.forEach { resignResponder($0) }
    }
    
    @inline(__always)
    private func updateActionButtons() {
        
        // update UI
        if let actionButtonsCellIndex = cells.index(of: .action) {
            
            tableView.reloadRows(at: [IndexPath(row: actionButtonsCellIndex, section: 0)], with: .none)
        }
    }
    
    private func orderConfirm() {
        
        guard let orderNumber = self.orderNumber
            else { fatalError("No order number set") }
        
        let summit = SummitManager.shared.summit.value
        
        self.showActivityIndicator()
        
        Store.shared.attendees(for: orderNumber, summit: summit) { [weak self] (response) in
            
            guard let controller = self else { return }
            
            switch response {
                
            case let .error(error):
                
                controller.dismissActivityIndicator()
                
                let code = (error as NSError).code
                
                switch code {
                    
                case 412:
                    
                    controller.showInfoMessage("Info", message: "This Order# has already been associated with another user. If you feel this is an error, please contact summitapp@openstack.org or enter a different Order #.")
                    
                case 404:
                    
                    controller.showInfoMessage("Info", message: "Order wasn\'t found. Please verify that you provided correct order # and try again.")
                    
                default:
                    
                    controller.showErrorMessage(error)
                }
                
            case let .value(attendees):
                
                controller.selectedAttendee = nil
                controller.attendees = attendees
                
                if (attendees.count == 0) {
                    
                    controller.dismissActivityIndicator()
                    
                    controller.showInfoMessage("Info", message: "Order wasn\'t found. Please verify that you provided correct order # and try again.");
                }
                else if (attendees.count == 1) {
                    
                    controller.selectedAttendee = attendees[0]
                    
                    controller.selectAttendee()
                }
                else if (attendees.count > 1) {
                    
                    controller.dismissActivityIndicator()
                    
                    controller.input = .nameSelection
                }
            }
        }
    }
    
    private func selectAttendee() {
        
        guard let selectedAttendee = self.selectedAttendee,
            let orderNumber = self.orderNumber
            else { fatalError("No attendee selected") }
        
        showActivityIndicator()
        
        let summit = SummitManager.shared.summit.value
        
        Store.shared.confirmAttendee(for: orderNumber, externalAttendee: selectedAttendee.identifier, summit: summit) { [weak self] (response) in
            
            OperationQueue.main.addOperation {
                
                guard let controller = self else { return }
                
                controller.dismissActivityIndicator()
                
                switch response {
                    
                case let .some(error):
                    
                    let code = (error as NSError).code
                    
                    switch code {
                        
                    case 412:
                        
                        controller.showInfoMessage("Info", message: "This Order# has already been associated with another user. If you feel this is an error, please contact summitapp@openstack.org or enter a different Order #.")
                        
                    case 404:
                        
                        controller.showInfoMessage("Info", message: "Order wasn\'t found. Please verify that you provided correct order # and try again.")
                        
                    default:
                        
                        controller.showErrorMessage(error)
                    }
                    
                case .none:
                    
                    Store.shared.currentMember(for: summit) { (response) in
                        
                        OperationQueue.main.addOperation {
                            
                            switch response {
                                
                            case let .error(error):
                                
                                controller.showErrorMessage(error)
                                
                            case .value:
                                
                                controller.cancel()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.cells[indexPath.row]
        
        switch cell {
            
        case .order:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.attendeeConfirmOrderTableViewCell)!
            
            return cell
            
        case .selection:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.attendeeConfirmSelectionTableViewCell)!
            
            cell.pickerView.reloadAllComponents()
            
            return cell
            
        case .action:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.attendeeConfirmActionTableViewCell)!
            
            let confirmEnabled: Bool
            
            switch input {
                
            case .orderNumber:
                
                confirmEnabled = orderNumber != nil
                
            case .nameSelection:
                
                confirmEnabled = selectedAttendee != nil
            }
            
            cell.confirmButton.isEnabled = confirmEnabled
            
            return cell
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if self.orderNumber != nil {
            
            self.orderConfirm()
            
            return false
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        guard let orderNumer = Int(newString)
            else { return newString.isEmpty }
        
        self.orderNumber = orderNumer
        
        return true
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return attendees.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return attendees[row].name
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
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

final class AttendeeConfirmActionTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var confirmButton: Button!
}

