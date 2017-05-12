//
//  ImageInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class ImageInterfaceController: WKInterfaceController {
    
    static let identifier = "Image"
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var imageView: WKInterfaceImage!
    
    @IBOutlet private(set) weak var activityIndicator: WKInterfaceImage!
    
    // MARK: - Properties
    
    private(set) var image: Image!
    
    // MARK: - Loading
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let image = (context as? Context<Image>)?.value
            else { fatalError("Invalid context") }
        
        self.image = image
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        updateUserActivity(NSUserActivityTypeBrowsingWeb, userInfo: nil, webpageURL: image.url)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        // show activity indicator
        activityIndicator.setImageNamed("Activity")
        activityIndicator.startAnimatingWithImages(in: NSRange(location: 0, length: 30), duration: 1.0, repeatCount: 0)
        activityIndicator.setHidden(false)
        imageView.setHidden(true)
        
        // load image
        imageView.loadCached(image.url) { [weak self] (response) in
            
            guard let controller = self else { return }
            
            // hide activity indicator
            controller.activityIndicator.setHidden(true)
            controller.imageView.setHidden(false)
            
            // show alert image
            
            guard case .data = response else {
                
                controller.imageView.setImageNamed("alert")
                return
            }
        }
    }
}
