//
//  EventDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Haneke

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var eventDetailLabel: UILabel!
    
    var presenter : EventDetailPresenter?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.showEventDetailAsync()
        
        imageView.hnk_setImageFromURL(NSURL(string:"http://www.openstack.org/assets/paris-summit/_resampled/resizedimage464600-meridien-map-level01.png")!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showEventDetail(eventDetail: String) {
        eventDetailLabel.text = eventDetail
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
