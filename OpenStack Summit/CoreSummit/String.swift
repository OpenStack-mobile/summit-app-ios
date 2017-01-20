//
//  String.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation

public extension String {
    
    /// Encodes to the encoding used with OpenStack API.
    public func toOpenStackEncoding() -> String? {
        
        guard let cString = self.cStringUsingEncoding(NSNonLossyASCIIStringEncoding),
            let encoded = String(CString: cString, encoding: NSUTF8StringEncoding)
            else { return nil }
        
        return encoded
    }
    /// Decodes from encoding used with OpenStack API.
    public init?(openStackEncoded string: String) {
        
        guard let cString = string.cStringUsingEncoding(NSUTF8StringEncoding),
            let encoded = String(CString: cString, encoding: NSNonLossyASCIIStringEncoding)
            else { return nil }
        
        self = encoded
    }
}
