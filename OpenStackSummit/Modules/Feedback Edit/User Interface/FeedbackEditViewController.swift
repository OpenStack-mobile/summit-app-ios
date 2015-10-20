//
//  FeedbackEditViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IFeedbackEditViewController {
    
    var rate: Int { get }
    var review: String! { get }
    
    func showCreateFeedback()
    func showEditFeedback(feedback: FeedbackDTO)
    func showErrorMessage(error: NSError)
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
    }
    
    var review: String {
        get {
            return reviewTextArea.text
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
    
    @IBAction func sendFeedback(sender: AnyObject) {
        presenter.saveFeedback()
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}
