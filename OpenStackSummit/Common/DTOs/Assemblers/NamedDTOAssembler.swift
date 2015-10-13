//
//  NamedDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class NamedDTOAssembler: NSObject {
    public func createDTO<T: NamedEntity, V: NamedDTO>(entity: T) -> V {
        let dto = V()
        dto.id = entity.id
        dto.name = entity.name
        return dto
    }
}
