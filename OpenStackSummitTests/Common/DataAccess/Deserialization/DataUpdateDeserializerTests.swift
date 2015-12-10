//
//  DataUpdateDeserializerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import SwiftyJSON

class DataUpdateDeserializerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_deserialize_validJSONWithInsertOperation_returnsCorrectDataUpdateInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let event = SummitEvent()
        event.id = 1
        deserializerStorage.add(event)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = DataUpdateDeserializer(deserializerFactory: deserializerFactory)
        let json = "{\"id\":10,\"created\":1442920889,\"type\":\"INSERT\",\"class_name\":\"MySchedule\",\"entity\":1 }"
        
        //Act
        let dataUpdate = try! deserializer.deserialize(json) as! DataUpdate
        
        //Assert
        XCTAssertEqual(10,dataUpdate.id)
        XCTAssertEqual(DataOperation.Insert,dataUpdate.operation)
        XCTAssertEqual("MySchedule",dataUpdate.entityClassName)
        XCTAssertEqual(event,dataUpdate.entity as? SummitEvent)
    }

    func test_deserialize_validJSONWithUpdateOperation_returnsCorrectDataUpdateInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let event = SummitEvent()
        event.id = 1
        deserializerStorage.add(event)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = DataUpdateDeserializer(deserializerFactory: deserializerFactory)
        let json = "{\"id\":10,\"created\":1442920889,\"type\":\"UPDATE\",\"class_name\":\"MySchedule\",\"entity\":1 }"
        
        //Act
        let dataUpdate = try! deserializer.deserialize(json) as! DataUpdate
        
        //Assert
        XCTAssertEqual(10,dataUpdate.id)
        XCTAssertEqual(DataOperation.Update,dataUpdate.operation)
        XCTAssertEqual("MySchedule",dataUpdate.entityClassName)
        XCTAssertEqual(event,dataUpdate.entity as? SummitEvent)
    }

    func test_deserialize_validJSONWithDeleteOperation_returnsCorrectDataUpdateInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let event = SummitEvent()
        event.id = 1
        deserializerStorage.add(event)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = DataUpdateDeserializer(deserializerFactory: deserializerFactory)
        let json = "{\"id\":10,\"created\":1442920889,\"type\":\"DELETE\",\"class_name\":\"MySchedule\",\"entity_id\":1 }"
        
        //Act
        let dataUpdate = try! deserializer.deserialize(json) as! DataUpdate
        
        //Assert
        XCTAssertEqual(10,dataUpdate.id)
        XCTAssertEqual(DataOperation.Delete,dataUpdate.operation)
        XCTAssertEqual("MySchedule",dataUpdate.entityClassName)
        XCTAssertEqual(event,dataUpdate.entity as? SummitEvent)
    }
    
    func test_deserialize_validJSONWithInvalidOperation_throwsBadFormatException() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let event = SummitEvent()
        event.id = 1
        deserializerStorage.add(event)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = DataUpdateDeserializer(deserializerFactory: deserializerFactory)
        let json = "{\"id\":10,\"created\":1442920889,\"type\":\"NON_EXISTENT_OPERATION\",\"class_name\":\"MySchedule\",\"entity\":1 }"
        var exceptionCount = 0
        let expectedExceptionCount = 1
        
        //Act
        do {
            try deserializer.deserialize(json) as! DataUpdate
        }
        catch DeserializerError.BadFormat {
            exceptionCount++
        }
        catch {
            
        }
        
        //Assert
        XCTAssertEqual(expectedExceptionCount,exceptionCount)
    }
    
    func test_deserializeArray_validJSONWithTwoDeleteOperations_returnsArrayWithTwoElements() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        var event = SummitEvent()
        event.id = 1
        deserializerStorage.add(event)
        
        event = SummitEvent()
        event.id = 2
        deserializerStorage.add(event)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = DataUpdateDeserializer(deserializerFactory: deserializerFactory)
        let json = "[{\"id\":10,\"created\":1442920889,\"type\":\"DELETE\",\"class_name\":\"MySchedule\",\"entity_id\":1 }, {\"id\":11,\"created\":1442920889,\"type\":\"DELETE\",\"class_name\":\"MySchedule\",\"entity_id\":2 }]"
        
        //Act
        let dataUpdateArray = try! deserializer.deserializeArray(json) as! [DataUpdate]
        
        //Assert
        XCTAssertEqual(2, dataUpdateArray.count)
        XCTAssertEqual(10, dataUpdateArray[0].id)
        XCTAssertEqual(11, dataUpdateArray[1].id)
    }
    
 }
