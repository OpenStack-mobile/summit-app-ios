//
//  VenueLocationDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import GoogleMaps

@objc
public protocol IVenueLocationDetailViewController {
    var name: String! { get set }
    func addMarker(venue:VenueDTO)
}

class VenueLocationDetailViewController: UIViewController, IVenueLocationDetailViewController, GMSMapViewDelegate {
    
    var name: String! {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    var presenter: IVenueLocationDetailPresenter!

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
}
