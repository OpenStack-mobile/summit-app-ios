//
//  FeedbackDetail.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/12/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreSummit

public struct FeedbackDetail: Unique {
    
    public let identifier: Identifier
    public let rate: Int
    public let review: String
    public let date: String
    public let eventName: String
    public let event: Identifier
    public let member: Member
}

// MARK: - Equatable

public func == (lhs: FeedbackDetail, rhs: FeedbackDetail) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.rate == rhs.rate
        && lhs.review == rhs.review
        && lhs.date == rhs.date
        && lhs.eventName == rhs.eventName
        && lhs.event == rhs.event
        && lhs.member == rhs.member
}

// MARK: - CoreData

extension FeedbackDetail: CoreDataDecodable {
    
    public init(managedObject feedback: FeedbackManagedObject) {
        
        self.identifier = feedback.id
        self.rate = Int(feedback.rate)
        self.review = feedback.review
        self.event = feedback.event.id
        self.eventName = feedback.event.name
        self.date = FeedbackDetail.timeAgoSinceDate(feedback.date, numericDates: false)
        self.member = Member(managedObject: feedback.member)
    }
    
    // MARK: - Static Methods
    
    private static func timeAgoSinceDate(_ date: Date, numericDates: Bool) -> String {
        
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components: DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if let year = components.year, year >= 2 {
            return "\(year) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if let month = components.month, month >= 2 {
            return "\(month) months ago"
        } else if let month = components.month, month >= 1 {
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if let weekOfYear = components.weekOfYear, weekOfYear >= 2 {
            return "\(weekOfYear) weeks ago"
        } else if let weekOfYear = components.weekOfYear, weekOfYear >= 1 {
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if let day = components.day, day >= 2 {
            return "\(day) days ago"
        } else if let day = components.day, day >= 1 {
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if let hour = components.hour, hour >= 2 {
            return "\(hour) hours ago"
        } else if let hour = components.hour, hour >= 1 {
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if let minute = components.minute, minute >= 2 {
            return "\(minute) minutes ago"
        } else if let minute = components.minute, minute >= 1 {
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if let second = components.second, second >= 3 {
            return "\(second) seconds ago"
        } else {
            return "Just now"
        }
    }
}
