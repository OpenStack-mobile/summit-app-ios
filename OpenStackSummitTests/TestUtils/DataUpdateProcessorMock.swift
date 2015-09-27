//
//  DataUpdateProcessorMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class DataUpdateProcessorMock: NSObject, IDataUpdateProcessor {
    var processCount = 0
    var thresholdProcessCount = 0
    var expectation: XCTestExpectation?
    
    init(expectation: XCTestExpectation?, thresholdProcessCount: Int) {
        self.thresholdProcessCount = thresholdProcessCount
        self.expectation = expectation
    }
    
    func process(data: String) {
        processCount++
        if (thresholdProcessCount == processCount) {
            expectation?.fulfill()
        }
    }
}
