//
//  PresentationCategoryDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class PresentationCategoryDeserializer: DeserializerProtocol {
    public func deserialize(json: JSON) -> BaseEntity {
        let presentationCategory = PresentationCategory()
        
        return presentationCategory
    }
}
