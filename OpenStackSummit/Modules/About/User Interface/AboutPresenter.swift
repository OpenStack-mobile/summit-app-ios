//
//  AboutPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IAboutPresenter {
    func viewLoad()
}

public class AboutPresenter: NSObject, IAboutPresenter {
    var interactor: IAboutInteractor!
    var wireframe: IAboutWireframe!
    var viewController: IAboutViewController!
    
    public func viewLoad() {
        let summit = interactor.getActiveSummit()
        let nameAndDate = buildNameDate(summit)
        
        viewController.nameAndDate = nameAndDate
        
        let version = buildVersion()
        if let version = version {
            viewController.version = "Version \(version)"
        }
        else {
            viewController.version = ""
        }
        
        let buildNumber = buildBuildNumber()
        if let buildNumber = buildNumber {
            viewController.buildNumber = "Build Number \(buildNumber)"
        }
        else {
            viewController.buildNumber = ""
        }
    }
    
    func buildNameDate(summit: SummitDTO) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: summit.timeZone);
        dateFormatter.dateFormat = "MMMM dd-"
        let stringDateFrom = dateFormatter.stringFromDate(summit.startDate)
        
        dateFormatter.dateFormat = "dd, yyyy"
        let stringDateTo = dateFormatter.stringFromDate(summit.endDate)
        
        return "\(summit.name) - \(stringDateFrom)\(stringDateTo)"
    }
    
    func buildVersion() -> String? {
        let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"]
        return nsObject as? String
    }
    
    func buildBuildNumber() -> String? {
        let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary?[kCFBundleVersionKey as String]
        return nsObject as? String
    }
}