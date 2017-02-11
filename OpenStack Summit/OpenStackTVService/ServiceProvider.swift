//
//  ServiceProvider.swift
//  OpenStackTVService
//
//  Created by Alsey Coleman Miller on 2/11/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation
import TVServices
import CoreSummit

final class ServiceProvider: NSObject, TVTopShelfProvider {

    override init() {
        super.init()
        
        print("Launching OpenStack Summit tvOS Service Provider v\(AppVersion) Build \(AppBuild)")
        print("Using Environment: \(AppEnvironment.rawValue)")
    }

    // MARK: - TVTopShelfProvider

    let topShelfStyle: TVTopShelfContentStyle = .Sectioned

    var topShelfItems: [TVContentItem] {
        
        var items = [TVContentItem]()
        
        return items
    }

}

// MARK: - Extensions
/*
extension Video {
    
    func toContextItem() -> TVContentItem { fatalError() }
}*/
