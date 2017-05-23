//
//  String.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation

// MARK: - UTF8 Encoding

public extension String {
    
    init?(UTF8Data: Data) {
        
        let data = UTF8Data
        
        var string = ""
        
        var generator = data.makeIterator()
        
        var encoding = UTF8()
        
        repeat {
            
            switch encoding.decode(&generator) {
                
            case let .scalarValue(scalar):
                
                let scalarString = String(scalar)
                
                string.append(scalarString)
                
            case .emptyInput:
                
                self = string
                
                return
                
            case .error:
                
                return nil
            }
            
        } while true
        
        return nil
    }
    
    func toUTF8Data() -> Data {
        
        return Data(bytes: Array(utf8))
    }
}

// MARK: - OpenStack Encoding

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
