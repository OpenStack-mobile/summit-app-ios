//
//  TrackScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "TRACK"
        self.scheduleView.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0);
    }
}
