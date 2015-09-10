//
//  MemberProfileAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class MemberProfileAssembly: TyphoonAssembly {
    var baseInteractorAssembly: BaseInteractorAssembly!
    var loginAssembly: LoginAssembly!
    
    dynamic func memberProfileWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfileWireframe.self) {
            (definition) in
            definition.injectProperty("loginWireframe", with: self.loginAssembly.loginWireframe())
        }
    }
    
    dynamic func memberProfilePresenter() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfilePresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.memberProfileInteractor())
            definition.injectProperty("memberProfileWireframe", with: self.memberProfileWireframe())
            definition.injectProperty("viewController", with: self.memberProfileViewController())
        }
    }
    
    dynamic func memberProfileDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfileDTOAssembler.self){
            (definition) in
            
            definition.injectProperty("scheduleItemDTOAssembler", with: self.memberSheduleItemDTOAssembler())
        }
    }
    
    dynamic func memberSheduleItemDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(ScheduleItemDTOAssembler.self)
    }
    
    dynamic func memberProfileInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfileInteractor.self) {
            (definition) in
            
            definition.injectProperty("memberDataStore", with: self.memberProfileDataStore())
            definition.injectProperty("session", with: self.baseInteractorAssembly.baseInteractorSession())
            definition.injectProperty("memberProfileDTOAssembler", with: self.memberProfileDTOAssembler())
        }
    }
    
    dynamic func memberProfileDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(MemberDataStore.self)
    }
    
    dynamic func memberProfileViewController() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfileViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.memberProfilePresenter())
        }
    }
}
