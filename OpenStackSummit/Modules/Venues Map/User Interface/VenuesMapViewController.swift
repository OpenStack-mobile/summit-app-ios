//
//  VenuesMapViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/21/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import GoogleMaps

@objc
protocol IVenuesMapViewController {
    func addMarkers(venues:[VenueListItemDTO])
}

class VenuesMapViewController: UIViewController, GMSMapViewDelegate, IVenuesMapViewController, XLPagerTabStripChildItem {
    
    var presenter: IVenuesMapPresenter!
    var mapView: GMSMapView!
    var dictionary = Dictionary<GMSMarker, Int>()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapView = GMSMapView()
        mapView.myLocationEnabled = true
        mapView.delegate = self
        self.view = mapView
        presenter.viewLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        let venueId = dictionary[marker]
        presenter.showVenueDetail(venueId!)
        return true
    }
    
    func addMarkers(venues:[VenueListItemDTO]) {
        var marker: GMSMarker
        var bounds = GMSCoordinateBounds()
        for venue in venues {
            marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(venue.lat, venue.long)
            marker.map = mapView
            marker.title = venue.name
            dictionary[marker] = venue.id
            bounds = bounds.includingCoordinate(marker.position)
        }
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
    
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> String {
        return "Map"
    }

}
