//
//  FeedbackEditViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftSpinner

@objc
public protocol IFeedbackEditViewController {
    
    var rate: Int { get set }
    var review: String! { get set }
    
    func showCreateFeedback()
    func showEditFeedback(feedback: FeedbackDTO)
    func showErrorMessage(error: NSError)
    func showActivityIndicator()
    func hideActivityIndicator()
}

class FeedbackEditViewController: UIViewController, IFeedbackEditViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var presenter: IFeedbackEditPresenter!
    var rates = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    @IBOutlet weak var ratePicker: UIPickerView!
    @IBOutlet weak var reviewTextArea: UITextView!
    
    var rate: Int {
        get {
            let selectedValue = rates[ratePicker.selectedRowInComponent(0)]
            return Int(selectedValue)!
        }
        set {
            let index = rates.indexOf(String(newValue));
            if (index != nil) {
                ratePicker.selectRow(index!, inComponent: 0, animated: false)
            }
        }
        
    }
    
    var review: String {
        get {
            return reviewTextArea.text
        }
        set {
            reviewTextArea.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratePicker.dataSource = self
        ratePicker.delegate = self
        
        presenter.viewLoad()
        // Do any additional setup after loading the view.
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
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rates.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rates[row]
    }

    func showErrorMessage(error: NSError) {
        
    }
    
    func showActivityIndicator() {
        SwiftSpinner.showWithDelay(0.5, title: "Please wait...")
    }
    
    func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
    @IBAction func sendFeedback(sender: AnyObject) {
        presenter.saveFeedback()
    }
}
