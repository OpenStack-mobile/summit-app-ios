//
//  VenueDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import ImageSlideshow
// import GoogleMaps
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
        
        imagesSlideshow.contentScaleMode = .scaleAspectFill
        mapsSlideshow.contentScaleMode = .scaleAspectFill
        
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        navigationItem.title = "VENUE"
        
        updateUI()
    }
    
    // MARK: - Action
    
    @IBAction func openInFullScreen(_ sender: UITapGestureRecognizer) {
        let slideshow = sender.view as! ImageSlideshow
        
        let ctr = FullScreenSlideshowViewController()
        ctr.pageSelected = {(page: Int) in
            slideshow.setScrollViewPage(page, animated: false)
        }
        
        ctr.initialImageIndex = slideshow.scrollViewPage
        ctr.inputs = slideshow.images
        self.transitionDelegate = ZoomAnimatedTransitioningDelegate.init(slideshowView: slideshow, slideshowController: ctr)
        ctr.transitioningDelegate = self.transitionDelegate!
        self.present(ctr, animated: true, completion: nil)
        
        ctr.closeButton.setImage(UIImage(named: "close"), for: UIControlState())
    }
    
    @IBAction func navigateToVenueLocationDetail(_ sender: UITapGestureRecognizer) {
        
        if !arrowImageView.isHidden {
            
            let venueLocationDetailVC = R.storyboard.venue.venueLocationDetailViewController()!
            
            venueLocationDetailVC.venue = venue
            
            self.show(venueLocationDetailVC, sender: self)
        }
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        assert(self.venue != nil, "No venue set")
        
        guard let venue = try! VenueListItem.find(self.venue, context: Store.shared.managedObjectContext)
            else { fatalError("Venue not found in cache. Invalid venue \(self.venue)") }
        
        self.name = venue.name
        self.location = venue.address
        
        self.toggleImagesGallery(venue.images.count > 0)
        if venue.images.count > 0 {
            self.images = venue.images
        }
        
        self.toggleMapNavigation(venue.maps.count > 0)
        self.toggleMapsGallery(venue.maps.count > 0)
        self.toggleMap(venue.maps.count == 0 && venue.location != nil)
        
        if venue.maps.count > 0 {
            self.maps = venue.maps
        }
        else if let location = venue.location {
            
            let marker = GMSMarker()
            var bounds = GMSCoordinateBounds()
            marker.position = location
            marker.map = mapView
            marker.title = venue.name
            marker.icon = R.image.map_pin()!
            bounds = bounds.includingCoordinate(marker.position)
            mapView.selectedMarker = marker
            
            let update = GMSCameraUpdate.fit(bounds)
            mapView.moveCamera(update)
            mapView.animate(toZoom: mapView.camera.zoom - 6)
        }
    }
    
    @inline(__always)
    func toggleMap(_ visible: Bool) {
        mapView.isHidden = !visible
    }
    
    @inline(__always)
    func toggleMapsGallery(_ visible: Bool) {
        mapsSlideshow.isHidden = !visible
    }
    
    @inline(__always)
    func toggleImagesGallery(_ visible: Bool) {
        imagesSlideshow.isHidden = !visible
        imagesSlideshowHeightConstraint.constant = visible ? 220 : 0
        imagesSlideshow.updateConstraints()
    }
    
    @inline(__always)
    func toggleMapNavigation(_ visible: Bool) {
        arrowImageView.isHidden = !visible
    }
}
