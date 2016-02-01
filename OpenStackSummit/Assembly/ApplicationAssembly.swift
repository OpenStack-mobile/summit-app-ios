//
//  ApplicationAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class ApplicationAssembly: TyphoonAssembly {
    
    var securityManagerAssembly: SecurityManagerAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    
    dynamic func appDelegate() -> AnyObject {
        return TyphoonDefinition.withClass(AppDelegate.self)
    }
        
    dynamic func mainStoryboard() -> AnyObject {
        return TyphoonDefinition.withClass(TyphoonStoryboard.self) {
            (definition) in
            
            definition.useInitializer("storyboardWithName:factory:bundle:") {
                (initializer) in
                
                initializer.injectParameterWith("Main")
                initializer.injectParameterWith(self)
                initializer.injectParameterWith(NSBundle.mainBundle())
            }
            
            definition.scope = TyphoonScope.Singleton
        }
    }
    
    dynamic func pushNotificationsManager() -> AnyObject {
        return TyphoonDefinition.withClass(PushNotificationsManager.self) {
            (definition) in
            
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
            definition.injectProperty("summitDataStore", with: self.dataStoreAssembly.summitDataStore())
        }
    }

    dynamic func session() -> AnyObject {
        return TyphoonDefinition.withClass(Session.self) {
            (definition) in
            
            definition.scope = TyphoonScope.Singleton
        }
    }
    
    dynamic func scheduleFilter() -> AnyObject {
        return TyphoonDefinition.withClass(ScheduleFilter.self) {
            (definition) in
            
            definition.scope = TyphoonScope.Singleton
        }
    }
    
    dynamic func navigationController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("NavigationController")
            }, configuration: {
                (definition) in
                
                definition.scope = TyphoonScope.Singleton
        })
    }
    
    dynamic func reachability() -> AnyObject {
        return TyphoonDefinition.withClass(Reachability.self)
    }
}
