//
//  EventDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Haneke

@objc
public protocol IEventDetailViewController {
    func showEventDetail(eventDetail: EventDetailDTO)
    func didAddEventToMySchedule(event: EventDetailDTO)
    func showErrorMessage(error: NSError)
    
    var presenter: IEventDetailPresenter! { get set }
}

class EventDetailViewController: UIViewController, IEventDetailViewController {
    
    @IBOutlet weak var eventDetailLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var presenter: IEventDetailPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //imageView.hnk_setImageFromURL(NSURL(string:"http://www.openstack.org/assets/paris-summit/_resampled/resizedimage464600-meridien-map-level01.png")!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showEventDetail(eventDetail: EventDetailDTO) {
        titleLabel.text = eventDetail.title
        timeLabel.text = eventDetail.date
        locationLabel.text = eventDetail.location
        eventDetailLabel.text = eventDetail.eventDescription
    }
    
    func didAddEventToMySchedule(event: EventDetailDTO) {
        
    }
    
    func showErrorMessage(error: NSError) {
        
    }
    
    @IBAction func leaveFeedback(sender: AnyObject) {
        presenter.leaveFeedback()
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}
