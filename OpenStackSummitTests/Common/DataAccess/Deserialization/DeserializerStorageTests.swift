//
//  DeserializationStorageTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XCTest
import OpenStackSummit
import RealmSwift

class DeserializerStorageTests: XCTestCase {
    
    var realm = try! Realm()

    override func setUp() {
        super.setUp()
        
        try! realm.write {
            self.realm.deleteAll()
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_Add_Company_StorageContainsAddedCompany() {
        //Arrange
        let deserializerStorage = DeserializerStorage()
        let companyId = 1
        let company = Company()
        company.id = companyId
        let companyFromStorage : Company
        
        //Act
        deserializerStorage.add(company)
        companyFromStorage = deserializerStorage.get(companyId)

        //Assert
        XCTAssertEqual(company.id, companyFromStorage.id)
    }
    
    func test_Add_CompanyAndEventType_StorageContainsBothAddedEntities() {
        //Arrange
        let deserializerStorage = DeserializerStorage()
        let companyId = 1
        let company = Company()
        company.id = companyId
        let companyFromStorage : Company

        let eventTypeId = 2
        let eventType = EventType()
        eventType.id = eventTypeId
        let eventTypeFromStorage : EventType
        
        //Act
        deserializerStorage.add(company)
        deserializerStorage.add(eventType)
        companyFromStorage = deserializerStorage.get(companyId)
        eventTypeFromStorage = deserializerStorage.get(eventTypeId)
        
        //Assert
        XCTAssertEqual(company.id, companyFromStorage.id)
        XCTAssertEqual(eventType.id, eventTypeFromStorage.id)
    }
    
    func test_Add_TwoTimesSameCompany_StorageContainsSingleCompany() {
        //Arrange
        
        let deserializerStorage = DeserializerStorage()
        let companyId = 1
        let company = Company()
        company.id = companyId
        let companiesFromStorage : [Company]
        
        //Act
        deserializerStorage.add(company)
        deserializerStorage.add(company)
        companiesFromStorage = deserializerStorage.getAll()
        
        //Assert
        XCTAssertEqual(1, companiesFromStorage.count)
    }
    
    func test_Add_TwoDifferentCompanies_StorageContainsBothCompanies() {
        //Arrange
        
        let deserializerStorage = DeserializerStorage()
        let companyId1 = 1
        let company1 = Company()
        company1.id = companyId1
        
        let companyId2 = 2
        let company2 = Company()
        company2.id = companyId2
        
        let companiesFromStorage : [Company]
        
        //Act
        deserializerStorage.add(company1)
        deserializerStorage.add(company2)
        companiesFromStorage = deserializerStorage.getAll()
        
        //Assert
        XCTAssertEqual(2, companiesFromStorage.count)
    }
    
    func test_Exist_CompanyNotPresentOnStorage_ReturnsFalse() {
        //Arrange
        
        let deserializerStorage = DeserializerStorage()
        let companyId = 1
        let company = Company()
        company.id = companyId
        
        
        //Act
        let exist = deserializerStorage.exist(company)
        
        //Assert
        XCTAssertFalse(exist)
    }
    
    func test_Exist_CompanyPresentOnMemoryStorage_ReturnsTrue() {
        //Arrange
        
        let deserializerStorage = DeserializerStorage()
        let companyId = 1
        let company = Company()
        company.id = companyId
        
        
        //Act
        deserializerStorage.add(company)
        let exist = deserializerStorage.exist(company)
        
        //Assert
        XCTAssertTrue(exist)
    }

    func test_Exist_CompanyPresentOnDatabaseStorage_ReturnsTrue() {
        //Arrange
        let deserializerStorage = DeserializerStorage()
        let companyId = 1
        let company = Company()
        company.id = companyId
        try! realm.write {
            self.realm.add(company)
        }
        
        //Act
        let exist = deserializerStorage.exist(company)
        
        //Assert
        XCTAssertTrue(exist)
    }

    func test_Clear_InMemoryStorageContainsOneCompany_InMemoryStorageIsEmpty() {
        //Arrange
        let deserializerStorage = DeserializerStorage()
        let companyId = 1
        let company = Company()
        company.id = companyId
        
        //Act
        deserializerStorage.add(company)
        deserializerStorage.clear()
        
        //Assert
        let companies : [Company] = deserializerStorage.getAll()
        XCTAssertEqual(0, companies.count)
    }
}