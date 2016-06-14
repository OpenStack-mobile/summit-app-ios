//
//  FeedbackEditWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IFeedbackEditWireframe {
    func presentFeedbackEditView(eventId: Int, viewController: UINavigationController)
    func backToPreviousView()
}

public class FeedbackEditWireframe: NSObject, IFeedbackEditWireframe {
    var feedbackEditViewController: FeedbackEditViewController!
    
    public func presentFeedbackEditView(eventId: Int, viewController: UINavigationController) {
        let newViewController = feedbackEditViewController!
        let _ = feedbackEditViewController.view! // this is only to force viewLoad to trigger
        feedbackEditViewController.presenter.eventId = eventId
        viewController.pushViewController(newViewController, animated: true)
    }
    
    public func backToPreviousView() {
        feedbackEditViewController.navigationController?.popViewControllerAnimated(true)
    }
}
