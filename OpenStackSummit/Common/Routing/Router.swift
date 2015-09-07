//
//  Router.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

@objc public enum View: Int {
    case EventDetail, GeneralSchedule, VenueList
}

@objc
public protocol IRouter {
    func navigateTo(view: View, params: [String:AnyObject]?)
    func navigateToRoot(view: View, params: [String:AnyObject]?)
}

public class Router: NSObject, IRouter {
    
    var storyboard: UIStoryboard!
    var currentViewParams: [String: AnyObject]!
    
    public func navigateTo(view: View, params: [String:AnyObject]?) {
        
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        let navigationController = appDelegate.window!.rootViewController as! UINavigationController
        var identifier = ""
        
        switch view {
        case View.EventDetail:
            identifier = "EventDetailViewController"
        case View.VenueList:
            identifier = "VenueListViewController"
        case View.GeneralSchedule:
            identifier = "GeneralScheduleViewController"
        default:
            identifier = ""
        }
        let viewController = storyboard.instantiateViewControllerWithIdentifier(identifier);
        navigationController.pushViewController(viewController, animated: true)
    }
    
    public func navigateToRoot(view: View, params: [String:AnyObject]?) {
        
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        let navigationController = appDelegate.window!.rootViewController as! UINavigationController
        var identifier = ""
        
        switch view {
        case View.EventDetail:
            identifier = "EventDetailViewController"
        case View.VenueList:
            identifier = "VenueListViewController"
        case View.GeneralSchedule:
            identifier = "GeneralScheduleViewController"
        default:
            identifier = ""
        }
        let viewController = storyboard.instantiateViewControllerWithIdentifier(identifier);
        navigationController.setViewControllers([viewController], animated: true)
    }
    
}
