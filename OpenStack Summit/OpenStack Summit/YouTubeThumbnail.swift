//
//  YouTubeThumbnail.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/17/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

public extension UIImage {
    
    /// Initializes an image with the thumbnail of a YouTube video based on its ID.
    convenience init?(youtube identifier: String) {
        
        guard let url = NSURL(string: "http://img.youtube.com/vi/" + identifier + "/default.jpg"),
            let data = NSData(contentsOfURL: url)
            else { return nil }
        
        self.init(data: data)
    }
}


