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
    func showCreateFeedback()
    func showEditFeedback(feedback: FeedbackDTO)
}

class FeedbackEditViewController: UIViewController, IFeedbackEditViewController {
    
    var presenter: IFeedbackEditPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}
