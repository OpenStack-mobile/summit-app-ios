//
//  ApplicationAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon
import SWRevealViewController

class ApplicationAssembly: TyphoonAssembly {
    
    var securityManagerAssembly: SecurityManagerAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var menuAssembly: MenuAssembly!
    var eventsAssembly: EventsAssembly!
    
    dynamic func appDelegate() -> AnyObject {
        return TyphoonDefinition.withClass(AppDelegate.self) {
            (definition) in
            
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
            definition.injectProperty("revealViewController", with: self.revealViewController())
        }
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
    
    dynamic func revealViewController() -> AnyObject {
        return TyphoonDefinition.withClass(SWRevealViewController.self) {
            (definition) in
            
            definition.useInitializer("initWithRearViewController:frontViewController:") {
                (initializer) in
                
                initializer.injectParameterWith(self.menuAssembly.menuViewController())
                initializer.injectParameterWith(self.initialNavigationController())
            }
            definition.scope = TyphoonScope.Singleton
        }
    }
    
    dynamic func initialNavigationController() -> AnyObject {
        return TyphoonDefinition.withClass(NavigationController.self) {
            (definition) in
            
            definition.injectMethod("setViewControllers:animated:", parameters: {
                (method) -> Void in
                method.injectParameterWith([self.eventsAssembly.eventsViewController()])
                method.injectParameterWith(false)
            })
        }
    }

    dynamic func navigationController() -> AnyObject {
        return TyphoonDefinition.withClass(NavigationController.self) {
            (definition) in
            
            definition.scope = TyphoonScope.Prototype
        }
    }
    
    dynamic func reachability() -> AnyObject {
        return TyphoonDefinition.withClass(Reachability.self)
    }
}
