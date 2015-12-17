//
//  HanekeInputSource.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 12/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Haneke
import ImageSlideshow

public class HanekeInputSource: NSObject, InputSource {
    let url: NSURL!
    let frame: CGRect!
    
    public init(url: NSURL, frame: CGRect) {
        self.url = url
        self.frame = frame
    }
    
    public init?(urlString: String, frame: CGRect) {
        self.frame = frame
        if let validUrl = NSURL(string: urlString) {
            self.url = validUrl
            super.init()
        } else {
            // working around Swift 1.2 failure initializer bug
            self.url = NSURL(string: "")!
            super.init()
            return nil
        }
    }
    
    @objc public func setToImageView(imageView: UIImageView) {
        imageView.frame = frame
        imageView.contentMode = .ScaleAspectFit
        imageView.hnk_setImageFromURL(url)
    }
}