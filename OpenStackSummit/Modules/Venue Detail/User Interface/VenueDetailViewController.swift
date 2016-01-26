//
//  VenueDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import ImageSlideshow
import GoogleMaps

@objc
public protocol IVenueDetailViewController {
    var navigationController: UINavigationController? { get }
    
    var name: String! { get set }
    var location: String! { get set }
    var maps: [String]! { get set }
    var slideshowEnabled: Bool { @objc(isSlideshowEnabled) get set }
    
    func addMarker(venue:VenueDTO)
    func reloadRoomsData()
}

class VenueDetailViewController: UIViewController, IVenueDetailViewController , UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate {
    
    private var mapsInternal: [String]!
    private var isSlideshowEnableInternal: Bool = false
    
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
                    let url = map.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    imageInputs.append(HanekeInputSource(urlString: url, frame: slideshow.bounds)!)
                }
                
                slideshow.setImageInputs(imageInputs)
            }
        }
    }
    
    var slideshowEnabled: Bool {
        @objc(isSlideshowEnabled) get {
            return isSlideshowEnableInternal
        }
        set(slideshowEnabled) {
            isSlideshowEnableInternal = slideshowEnabled
            mapView.hidden = slideshowEnabled
            slideshow.hidden = !slideshowEnabled
            arrowImageView.hidden = !slideshowEnabled
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var roomsTableView: UITableView!
    @IBOutlet weak var roomsTableViewHeightConstraint: NSLayoutConstraint!
    
    var presenter: IVenueDetailPresenter!
    let cellIdentifier = "venueRoomListTableViewCell"
    
    var transitionDelegate: ZoomAnimatedTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.myLocationEnabled = true
        mapView.delegate = self
        
        let recognizer = UITapGestureRecognizer(target: self, action: "click")
        slideshow.addGestureRecognizer(recognizer)
        
        roomsTableView.registerNib(UINib(nibName: "TableViewSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewSectionHeader")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        roomsTableViewHeightConstraint?.constant = roomsTableView.contentSize.height
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
    
    func addMarker(venue: VenueDTO) {
        let marker = GMSMarker()
        var bounds = GMSCoordinateBounds()
        marker.position = CLLocationCoordinate2DMake(venue.lat, venue.long)
        marker.map = mapView
        marker.title = venue.name
        marker.icon = UIImage(named: "map_pin")
        bounds = bounds.includingCoordinate(marker.position)
        mapView.selectedMarker = marker
        mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
    }
    
    func reloadRoomsData() {
        roomsTableView.delegate = self
        roomsTableView.dataSource = self
        roomsTableView.reloadData()
    }
    
    @IBAction func navigateToVenueLocationDetail(sender: UITapGestureRecognizer) {
        if slideshowEnabled {
            presenter.showVenueLocationDetail()
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = roomsTableView.dequeueReusableHeaderFooterViewWithIdentifier("TableViewSectionHeader") as! TableViewSectionHeader
        header.titleLabel.text = "At this location".uppercaseString
        return header
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getVenueRoomsCount();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! VenueListTableViewCell
        presenter.buildVenueRoomCell(cell, index: indexPath.row)
        return cell
    }
    
    /*func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        self.presenter.showVenueLocationDetail()
    }*/
}
