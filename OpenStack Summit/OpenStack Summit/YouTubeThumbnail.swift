//
//  YouTubeThumbnail.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/17/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

public extension NSURL {
    
    /// Initializes an URL for the thumbnail of a YouTube video based on its ID.
    convenience init?(youtubeThumbnail identifier: String) {
        
        self.init(string: "https://img.youtube.com/vi/" + identifier + "/maxresdefault.jpg")
    }
}


