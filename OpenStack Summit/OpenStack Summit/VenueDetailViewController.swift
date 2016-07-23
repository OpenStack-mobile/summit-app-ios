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
import CoreSummit

final class VenueDetailViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var imagesSlideshow: ImageSlideshow!
    @IBOutlet weak var imagesSlideshowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapsSlideshow: ImageSlideshow!
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Accessors
    
    private(set) var name: String {
        get {
            return nameLabel.text ?? ""
        }
        set {
            nameLabel.text = newValue
        }
    }

    private(set) var location: String  {
        get {
            return locationLabel.text ?? ""
        }
        set {
            locationLabel.text = newValue
        }
    }
    
    private(set) var images = [String]() {
        didSet {
            var imageInputs: [HanekeInputSource] = []		
            
            for image in images {
                
                #if DEBUG
                    let url = image.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
                #else
                    let url = image
                #endif
                
                imageInputs.append(HanekeInputSource(urlString: url)!)
            }
            
            imagesSlideshow.setImageInputs(imageInputs)
        }
    }
    
    private(set) var maps = [String]() {
       didSet {
            var imageInputs: [HanekeInputSource] = []
        
            for map in maps {
                
                #if DEBUG
                    let url = map.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
                #else
                    let url = map
                #endif
                
                imageInputs.append(HanekeInputSource(urlString: url)!)
            }
            
            mapsSlideshow.setImageInputs(imageInputs)
        }
    }
    
    // MARK: - Properties
    
    var venue: Identifier!
    
    var transitionDelegate: ZoomAnimatedTransitioningDelegate?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesSlideshow.contentScaleMode = .ScaleAspectFill
        mapsSlideshow.contentScaleMode = .ScaleAspectFill
        
        mapView.myLocationEnabled = true
        mapView.delegate = self
        
        navigationItem.title = "VENUE"
    }
    
    // MARK: - Action
    
    @IBAction func openInFullScreen(sender: UITapGestureRecognizer) {
        let slideshow = sender.view as! ImageSlideshow
        
        let ctr = FullScreenSlideshowViewController()
        ctr.pageSelected = {(page: Int) in
            slideshow.setScrollViewPage(page, animated: false)
        }
        
        ctr.initialImageIndex = slideshow.scrollViewPage
        ctr.inputs = slideshow.images
        self.transitionDelegate = ZoomAnimatedTransitioningDelegate.init(slideshowView: slideshow, slideshowController: ctr)
        ctr.transitioningDelegate = self.transitionDelegate!
        self.presentViewController(ctr, animated: true, completion: nil)
        
        ctr.closeButton.setImage(UIImage(named: "close"), forState: .Normal)
    }
    
    @IBAction func navigateToVenueLocationDetail(sender: UITapGestureRecognizer) {
        if !arrowImageView.hidden {
            //presenter.showVenueLocationDetail()
        }
    }
    
    // MARK: - Private Methods
    
    func addMarker(venue: Venue) {
        let marker = GMSMarker()
        var bounds = GMSCoordinateBounds()
        marker.position = CLLocationCoordinate2DMake((venue.latitude ?? "" as NSString).doubleValue, (venue.longitude ?? "" as NSString).doubleValue)
        marker.map = mapView
        marker.title = venue.name
        marker.icon = UIImage(named: "map_pin")
        bounds = bounds.includingCoordinate(marker.position)
        mapView.selectedMarker = marker
        
        let update = GMSCameraUpdate.fitBounds(bounds)
        mapView.moveCamera(update)
        mapView.animateToZoom(mapView.camera.zoom - 6)
    }
    
    func toggleMap(visible: Bool) {
        mapView.hidden = !visible
    }
    
    func toggleMapsGallery(visible: Bool) {
        mapsSlideshow.hidden = !visible
    }
    
    func toggleImagesGallery(visible: Bool) {
        imagesSlideshow.hidden = !visible
        imagesSlideshowHeightConstraint.constant = visible ? 220 : 0
        imagesSlideshow.updateConstraints()
    }
    
    func toggleMapNavigation(visible: Bool) {
        arrowImageView.hidden = !visible
    }
}
