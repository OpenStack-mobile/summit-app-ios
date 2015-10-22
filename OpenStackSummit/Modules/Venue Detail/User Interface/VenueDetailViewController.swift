//
//  VenueDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueDetailViewController {
    var name: String! { get set }
    var address: String! { get set }

    func addMarker(venue:VenueDTO)
}

class VenueDetailViewController: UIViewController, IVenueDetailViewController, GMSMapViewDelegate {

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
    @IBOutlet weak var venueMap: UIView!
    
    var presenter: IVenueDetailPresenter!
    var mapView: GMSMapView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapView = GMSMapView()
        mapView.myLocationEnabled = true
        mapView.delegate = self
        venueMap = mapView
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func navigateToVenueRoomDetail(sender: AnyObject) {
        presenter.showVenueRoomDetail(1)
    }

}
