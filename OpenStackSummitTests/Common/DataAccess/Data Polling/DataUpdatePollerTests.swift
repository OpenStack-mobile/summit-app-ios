//
//  DataUpdatePollerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class DataUpdatePollerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_startPolling_pollingIntervalIs200Miliseconds_pollServerIsCalledAtLeastTwiceBeforeOneSecond() {
        // Arrange        
        let expectation = expectationWithDescription("async load")

        let httpMock = HttpMock(responseObject: "", error: nil)
        let httpFactoryMock = HttpFactoryMock(http: httpMock)
        let thresholdProcessCount = 2
        let dataUpdateProcessorMock = DataUpdateProcessorMock(expectation: expectation, thresholdProcessCount: thresholdProcessCount)
        let dataUpdateDataStoreMock = DataUpdateDataStoreMock()
        let summitDataStoreMock = SummitDataStoreMock(summit: Summit())
        let dataUpdatePoller = DataUpdatePoller(httpFactory: httpFactoryMock, dataUpdateProcessor: dataUpdateProcessorMock, dataUpdateDataStore: dataUpdateDataStoreMock, summitDataStore: summitDataStoreMock)
        dataUpdatePoller.pollingInterval = 0.2
        
        // Act
        dataUpdatePoller.startPollingIfNotPollingAlready()
        
        
        // Assert
        self.waitForExpectationsWithTimeout(1.0, handler: nil)
        XCTAssertGreaterThan(dataUpdateProcessorMock.processCount, 1)
    }
    
    func test_startPolling_thereIsAnError_processIsNotCalled() {
        // Arrange
        let httpMock = HttpMock(responseObject: nil, error: NSError(domain: "", code: 1, userInfo: nil))
        let httpFactoryMock = HttpFactoryMock(http: httpMock)
        let thresholdProcessCount = 0
        let dataUpdateProcessorMock = DataUpdateProcessorMock(expectation: nil, thresholdProcessCount: thresholdProcessCount)
        let dataUpdateDataStoreMock = DataUpdateDataStoreMock()
        let summitDataStoreMock = SummitDataStoreMock(summit: Summit())
        let dataUpdatePoller = DataUpdatePoller(httpFactory: httpFactoryMock, dataUpdateProcessor: dataUpdateProcessorMock, dataUpdateDataStore: dataUpdateDataStoreMock, summitDataStore: summitDataStoreMock)
        dataUpdatePoller.pollingInterval = 0.2
        
        // Act
        dataUpdatePoller.startPollingIfNotPollingAlready()
        
        // Assert
        XCTAssertEqual(dataUpdateProcessorMock.processCount, 0)
    }
}
