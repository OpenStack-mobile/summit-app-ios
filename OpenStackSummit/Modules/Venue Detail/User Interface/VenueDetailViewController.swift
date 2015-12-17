//
//  VenueDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import ImageSlideshow

@objc
public protocol IVenueDetailViewController {
    var navigationController: UINavigationController? { get }
    
    var name: String! { get set }
    var location: String! { get set }
    var maps: [String]! { get set }
    
    func reloadRoomsData()
}

class VenueDetailViewController: UIViewController, IVenueDetailViewController , UITableViewDelegate, UITableViewDataSource {
    
    private var mapsInternal: [String]!
    
    var name: String! {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
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
    
    var maps: [String]! {
        get {
            return mapsInternal
        }
        set {
            if mapsInternal == nil {
                mapsInternal = newValue
                var imageInputs:[HanekeInputSource] = []
                
                for map in mapsInternal {
                    imageInputs.append(HanekeInputSource(urlString: map, frame: slideshow.bounds)!)
                }
                
                slideshow.setImageInputs(imageInputs)
            }
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var roomsTableView: UITableView!
    
    var presenter: IVenueDetailPresenter!
    let cellIdentifier = "venueRoomListTableViewCell"
    
    var transitionDelegate: ZoomAnimatedTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let recognizer = UITapGestureRecognizer(target: self, action: "click")
        slideshow.addGestureRecognizer(recognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func click() {
        let ctr = FullScreenSlideshowViewController()
        ctr.pageSelected = {(page: Int) in
            self.slideshow.setScrollViewPage(page, animated: false)
        }
        
        ctr.initialPage = slideshow.scrollViewPage
        ctr.inputs = slideshow.images
        self.transitionDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: slideshow);
        ctr.transitioningDelegate = self.transitionDelegate!
        self.presentViewController(ctr, animated: true, completion: nil)
    }
    
    func reloadRoomsData() {
        roomsTableView.delegate = self
        roomsTableView.dataSource = self
        roomsTableView.reloadData()
    }
    
    @IBAction func navigateToVenueLocationDetail(sender: UITapGestureRecognizer) {
        presenter.showVenueLocationDetail()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getVenueRoomsCount();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! VenueListTableViewCell
        presenter.buildVenueRoomCell(cell, index: indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        self.presenter.showVenueLocationDetail()
    }
}
