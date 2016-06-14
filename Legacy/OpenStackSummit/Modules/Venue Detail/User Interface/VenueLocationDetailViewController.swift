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
    func addMarker(venue:VenueDTO)
}

class VenueLocationDetailViewController: UIViewController, IVenueLocationDetailViewController, GMSMapViewDelegate {

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
    
}
