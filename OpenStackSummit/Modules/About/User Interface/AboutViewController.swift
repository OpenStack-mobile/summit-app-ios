//
//  AboutViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

@objc
protocol IAboutViewController {
    func setNameAndDate(nameAndDate: String)
    func setVersion(version: String)
}

class AboutViewController: RevealViewController, IAboutViewController {
    var presenter: IAboutPresenter!
    
    @IBOutlet weak var summitTextLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var nameAndDateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewLoad()
        navigationController?.navigationBar.topItem?.title = "ABOUT"
        summitTextLabel.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNameAndDate(nameAndDate: String) {
        nameAndDateLabel.text = nameAndDate
    }
    
    func setVersion(version: String) {
        versionLabel.text = version
    }
    
    @IBAction func websiteTouch(sender: AnyObject) {
        let url : NSURL = NSURL(string: "https://openstack.org")!
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
