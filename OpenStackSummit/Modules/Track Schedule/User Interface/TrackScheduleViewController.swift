//
//  TrackScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//
import UIKit
import AFHorizontalDayPicker

class TrackScheduleViewController: ScheduleViewController {
   
    var presenter: ITrackSchedulePresenter! {
        get {
            return internalPresenter as! ITrackSchedulePresenter
        }
        set {
            internalPresenter = newValue
        }
    }
}
