//
//  FeedbackEditPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IFeedbackEditPresenter {
    func viewLoad()
    func saveFeedback(rate: Int, review: String)
    
    var feedbackId: Int { get set }
    var eventId: Int { get set }
}

public class FeedbackEditPresenter: NSObject, IFeedbackEditPresenter {
    public var feedbackId = 0
    public var eventId = 0
    var viewController: IFeedbackEditViewController!
    var interactor: IFeedbackEditInteractor!
    var wireframe: IFeedbackEditWireframe!
    
    public func viewLoad() {
        if (feedbackId == 0) {
            viewController.showCreateFeedback()
        }
        else {
            let feedback = interactor.getFeedback(feedbackId)
            viewController.showEditFeedback(feedback!)
        }
    }
    
    public func saveFeedback(rate: Int, review: String) {

    }
}
