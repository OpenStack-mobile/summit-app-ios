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
    
    public let url: NSURL
    
    public init(url: NSURL) {
        self.url = url
    }
    
    public init?(urlString: String) {
        if let validUrl = NSURL(string: urlString) {
            self.url = validUrl
            super.init()
        } else {
            // this may be simplified in Swift 2.2, which fixes the failable initializer compiler issues
            self.url = NSURL(string: "")!
            super.init()
            return nil
        }
    }
    
    @objc public func setToImageView(imageView: UIImageView) {
        imageView.hnk_setImageFromURL(url, format: Format<UIImage>(name: "original"))
    }
}