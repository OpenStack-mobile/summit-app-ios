//
//  MenuAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class MenuAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var searchAssembly: SearchAssembly!
    var eventsAssembly: EventsAssembly!
    var venuesAssembly: VenuesAssembly!
    var peopleAssembly: PeopleAssembly!
    var memberOrderConfirmAssembly: MemberOrderConfirmAssembly!
    var myProfileAssembly: MyProfileAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    var aboutAssembly: AboutAssembly!
    
    dynamic func menuWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(MenuWireframe.self) {
            (definition) in
            
            definition.injectProperty("searchWireframe", with: self.searchAssembly.searchWireframe())
            definition.injectProperty("eventsWireframe", with: self.eventsAssembly.eventsWireframe())
            definition.injectProperty("venuesWireframe", with: self.venuesAssembly.venuesWireframe())
            definition.injectProperty("peopleWireframe", with: self.peopleAssembly.peopleWireframe())
            definition.injectProperty("myProfileWireframe", with: self.myProfileAssembly.myProfileWireframe())
            definition.injectProperty("memberOrderConfirmWireframe", with: self.memberOrderConfirmAssembly.memberOrderConfirmWireframe())
            definition.injectProperty("aboutWireframe", with: self.aboutAssembly.aboutWireframe())
        }
    }
    
    dynamic func menuPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(MenuPresenter.self) {
  
            (definition) in
            
            definition.injectProperty("interactor", with: self.menuInteractor())
            definition.injectProperty("wireframe", with: self.menuWireframe())
            definition.injectProperty("viewController", with: self.menuViewController())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
            definition.injectProperty("session", with: self.applicationAssembly.session())
        }
    }
    
    dynamic func menuInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(MenuInteractor.self) {
            (definition) in
            
            definition.injectProperty("summitDataStore", with: self.dataStoreAssembly.summitDataStore())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
            definition.injectProperty("memberDTOAssembler", with: self.dtoAssemblersAssembly.memberDTOAssembler())
            definition.injectProperty("pushNotificationsManager", with: self.applicationAssembly.pushNotificationsManager())
            definition.injectProperty("reachability", with: self.applicationAssembly.reachability())
        }
    }
    
    dynamic func menuViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("MenuViewController")
            }, configuration: {
                (definition) in
                
                definition.injectProperty("presenter", with: self.menuPresenter())
        })
    }
}
