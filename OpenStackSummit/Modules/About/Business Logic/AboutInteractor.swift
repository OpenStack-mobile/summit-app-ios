//
//  AboutInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IAboutInteractor {
    func getActiveSummit() -> SummitDTO
}

public class AboutInteractor: NSObject, IAboutInteractor {
    var summitDataStore: ISummitDataStore!
    var summitDTOAssembler: ISummitDTOAssembler!
    
    public func getActiveSummit() -> SummitDTO {
        let summit = summitDataStore.getActiveLocal()
        let summitDTO = summitDTOAssembler.createDTO(summit!)
        return summitDTO
    }
}