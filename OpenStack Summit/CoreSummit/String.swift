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
        
        guard let cString = self.cString(using: String.Encoding.nonLossyASCII),
            let encoded = String(cString: cString, encoding: String.Encoding.utf8)
            else { return nil }
        
        return encoded
    }
    /// Decodes from encoding used with OpenStack API.
    public init?(openStackEncoded string: String) {
        
        guard let cString = string.cString(using: String.Encoding.utf8),
            let encoded = String(cString: cString, encoding: String.Encoding.nonLossyASCII)
            else { return nil }
        
        self = encoded
    }
}
