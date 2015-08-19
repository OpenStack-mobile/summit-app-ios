//
//  RealmTest.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import RealmSwift

public class Animal : Object{
    public dynamic var name = ""
}

public class Dog : Animal {
    public dynamic var type = ""
}

public class Cat : Animal {
    public dynamic var isGood = false
}

public class Person : Object  {
    public dynamic var name = ""
    public let pets = List<Animal>()
}

class RealmTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let realm = try! Realm()
        realm.write {
            realm.deleteAll()
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }    
}
