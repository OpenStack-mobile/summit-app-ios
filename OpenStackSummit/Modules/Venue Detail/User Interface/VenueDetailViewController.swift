//
//  VenueDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import GoogleMaps

@objc
public protocol IVenueDetailViewController {
    var name: String! { get set }
    var address: String! { get set }

    func addMarker(venue:VenueDTO)
    func reloadRoomsData()
}

class VenueDetailViewController: UIViewController, IVenueDetailViewController, GMSMapViewDelegate , UITableViewDelegate, UITableViewDataSource {
    
    var name: String! {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }

    var address: String! {
        get {
            return addressLabel.text
        }
        set {
            addressLabel.text = newValue
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var roomsTableView: UITableView!
    
    var presenter: IVenueDetailPresenter!
    let cellIdentifier = "venueRoomListTableViewCell"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //mapView = GMSMapView()
        mapView.myLocationEnabled = true
        mapView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addMarker(venue:VenueDTO) {
        var marker: GMSMarker
        var bounds = GMSCoordinateBounds()
        marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(venue.lat, venue.long)
        marker.map = mapView
        marker.title = venue.name
        bounds = bounds.includingCoordinate(marker.position)
        mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
    }
    
    func reloadRoomsData() {
        roomsTableView.delegate = self
        roomsTableView.dataSource = self
        roomsTableView.reloadData()
    }
    
    @IBAction func navigateToVenueRoomDetail(sender: AnyObject) {
        presenter.showVenueRoomDetail(1)
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
        self.presenter.showVenueRoomDetail(indexPath.row)
    }
}
