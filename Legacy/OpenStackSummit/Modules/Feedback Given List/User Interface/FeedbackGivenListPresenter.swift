//
//  MyFeedbackPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IFeedbackGivenListPresenter {
    func viewLoad()
    func getFeedbackCount() -> Int
    func buildFeedbackCell(cell: IFeedbackTableViewCell, index: Int)
}

public class FeedbackGivenListPresenter: NSObject, IFeedbackGivenListPresenter {
    var viewController: IFeedbackGivenListViewController!
    var interactor: IFeedbackGivenListInteractor!
    var feedbackList: [FeedbackDTO]!
    
    public func viewLoad() {
        feedbackList = interactor.getLoggedMemberGivenFeedback()
        viewController.releoadList()
    }
    
    public func getFeedbackCount() -> Int {
        return feedbackList.count
    }
    
    public func buildFeedbackCell(cell: IFeedbackTableViewCell, index: Int){
        let feedback = feedbackList[index]
        cell.eventName = feedback.eventName
        cell.owner = feedback.owner
        cell.rate = Double(feedback.rate)
        cell.review = feedback.review
        cell.date = feedback.date
    }
}
