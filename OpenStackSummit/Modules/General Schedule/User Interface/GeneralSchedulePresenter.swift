//
//  GeneralSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import MTDates

extension Array where Element: SummitEvent {
    func filter(byDate date: NSDate) -> [SummitEvent] {
        return self.filter { (event) -> Bool in
            event.start.mt_isWithinSameDay(date)
        }
    }
}

@objc
public protocol IGeneralSchedulePresenter: ISchedulePresenter {
    func showFilters()
}

public class GeneralSchedulePresenter: SchedulePresenter, IGeneralSchedulePresenter {
    
    weak var viewController : IScheduleViewController! {
        get {
            return internalViewController
        }
        set {
            internalViewController = newValue
        }
    }
    
    var interactor : IGeneralScheduleInteractor! {
        get {
            return internalInteractor as! IGeneralScheduleInteractor
        }
        set {
            internalInteractor = newValue
        }
    }
    
    var wireframe : IGeneralScheduleWireframe! {
        get {
            return internalWireframe as! IGeneralScheduleWireframe
        }
        set {
            internalWireframe = newValue
        }
    }
    
    override public func viewLoad() {
        interactor.checkForClearDataEvents()
        super.viewLoad()
    }
    
    public func showFilters() {
        wireframe.showFilters()
    }
}
