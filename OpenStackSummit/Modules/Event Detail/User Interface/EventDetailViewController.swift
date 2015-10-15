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
    func didAddEventToMySchedule(event: EventDetailDTO)
    func showErrorMessage(error: NSError)
    
    var presenter: IEventDetailPresenter! { get set }
    var eventTitle: String! { get set }
    var eventDescription: String! { get set }
    var date: String! { get set }
    var location: String! { get set }
    var allowFeedback: Bool { get set }
}

class EventDetailViewController: UIViewController, IEventDetailViewController {
    
    @IBOutlet weak var eventDetailLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var feedbackButton: UIButton!
    
    private var eventDescriptionHTML = ""
    
    var eventTitle: String! {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    var eventDescription: String! {
        get {
            return eventDescriptionHTML
        }
        set {
            //eventDescriptionHTML = newValue.stringByReplacingOccurrencesOfString("\\", withString: "")
            let attrStr = try! NSAttributedString(data: newValue.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            eventDetailLabel.attributedText = attrStr
        }
    }
    var date: String! {
        get {
            return timeLabel.text
        }
        set {
            timeLabel.text = newValue
        }
    }
    
    var location: String! {
        get {
            return locationLabel.text
        }
        set {
            locationLabel.text = newValue
        }
    }
    
    var allowFeedback: Bool {
        get {
            return !feedbackButton.hidden
        }
        set {
            feedbackButton.hidden = !newValue
        }
    }
    
    var presenter: IEventDetailPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //imageView.hnk_setImageFromURL(NSURL(string:"http://www.openstack.org/assets/paris-summit/_resampled/resizedimage464600-meridien-map-level01.png")!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
