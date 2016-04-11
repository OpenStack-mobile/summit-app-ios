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
    var version: String { get set }
    var buildNumber: String { get set }
    var nameAndDate: String { get set }
}

class AboutViewController: RevealViewController, IAboutViewController {
    var presenter: IAboutPresenter!
    
    @IBOutlet weak var summitTextLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var buildNumberLabel: UILabel!
    @IBOutlet weak var nameAndDateLabel: UILabel!
    
    var version: String = "" {
        didSet {
            versionLabel.text = version
        }
    }
    
    var buildNumber: String = "" {
        didSet {
            buildNumberLabel.text = buildNumber
        }
    }
    
    var nameAndDate: String = "" {
        didSet {
            nameAndDateLabel.text = nameAndDate
        }
    }
    
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
    
    @IBAction func websiteTouch(sender: AnyObject) {
        let url : NSURL = NSURL(string: "https://openstack.org")!
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
