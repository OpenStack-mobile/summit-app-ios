//
//  CompanyDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class CompanyDeserializer: KeyValueDeserializer, DeserializerProtocol {
    var deserializerStorage: DeserializerStorage!
    
    public func deserialize(json : JSON) -> BaseEntity {
        let company : Company
        
        if let companyId = json.int {
            company = deserializerStorage.get(companyId)
        }
        else {
            company = super.deserialize(json) as Company
            if(!deserializerStorage.exist(company)) {
                deserializerStorage.add(company)
            }
        }
        
        return company
    }
}
