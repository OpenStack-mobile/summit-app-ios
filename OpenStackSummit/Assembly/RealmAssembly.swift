//
//  CoreDataAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/12/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon
import RealmSwift

class RealmAssembly: TyphoonAssembly {
   
    dynamic func realm() -> AnyObject {
        return TyphoonDefinition.withClass(Realm.self) {
            (definition) in

            definition.scope = TyphoonScope.Singleton
        }
    }    
}
