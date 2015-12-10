//
//  LevelListInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ILevelListInteractor {
    func getLevels() -> [String]
}

public class LevelListInteractor: NSObject, ILevelListInteractor {
    var eventDataStore: IEventDataStore!
    
    public func getLevels() -> [String] {
        return eventDataStore.getPresentationLevels().sort()
    }
}
