//
//  AboutInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import CoreSummit

public protocol AboutInteractorProtocol {
    
    func getActiveSummit() -> Summit
}

public final class AboutInteractor: AboutInteractorProtocol {
    
    var summitDataStore: SummitDataStore!
    
    public func getActiveSummit() -> CoreSummit.Summit {
        
        let realmEntity = summitDataStore.getActiveLocal()
        
        return Summit(realmEntity: realmEntity)
    }
}