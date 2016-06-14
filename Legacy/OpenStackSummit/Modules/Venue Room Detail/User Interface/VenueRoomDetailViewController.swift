//
//  VenueRoomDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueRoomDetailViewController {
    var name: String! { get set }
    var capacity: Int { get set }
    var picUrl: String! { get set }
}

class VenueRoomDetailViewController: UIViewController, IVenueRoomDetailViewController {
    var name: String! {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    var capacity: Int {
        get {
            return Int(capacityLabel.text!) ?? 0
        }
        set {
            capacityLabel.text = String(newValue)
        }
    }
    
    var picUrl: String! {
        get {
            return picUrlInternal
        }
        set {
            picUrlInternal = newValue
            if (!picUrlInternal.isEmpty) {
                pictureImageView.hnk_setImageFromURL(NSURL(string: picUrlInternal)!)
            }
            else {
                pictureImageView.image = nil
            }
        }
    }
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    var presenter: IVenueRoomDetailPresenter!
    private var picUrlInternal: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
