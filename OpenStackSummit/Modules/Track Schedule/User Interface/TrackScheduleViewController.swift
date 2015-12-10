//
//  TrackScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//
import UIKit
import AFHorizontalDayPicker

@objc
protocol ITrackScheduleViewController : IScheduleViewController {
    var track: String! { get set }
}

class TrackScheduleViewController: ScheduleViewController, ITrackScheduleViewController {
    var track: String! {
        get {
            return trackLabel.text
        }
        set {
            trackLabel.text = newValue
        }
    }
    
    @IBOutlet weak var trackLabel: UILabel!
    
    var presenter: ITrackSchedulePresenter! {
        get {
            return internalPresenter as! ITrackSchedulePresenter
        }
        set {
            internalPresenter = newValue
        }
    }
}
