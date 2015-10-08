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
    var loginAssembly: LoginAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    var remoteDataStoresAssembly: RemoteDataStoresAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var applicationAssembly: ApplicationAssembly!
    
    dynamic func memberProfileWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfileWireframe.self) {
            (definition) in
            definition.injectProperty("loginWireframe", with: self.loginAssembly.loginWireframe())
            definition.injectProperty("memberProfileViewController", with: self.memberProfileViewController())
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
            
            definition.injectProperty("presentationSpeakerRemoteDataStore", with: self.remoteDataStoresAssembly.presentationSpeakerRemoteDataStore())
            definition.injectProperty("summitAttendeeRemoteDataStore", with: self.remoteDataStoresAssembly.summitAttendeeRemoteDataStore())
            definition.injectProperty("summitAttendeeDTOAssembler", with: self.dtoAssemblersAssembly.summitAttendeeDTOAssembler())
            definition.injectProperty("presentationSpeakerDTOAssembler", with: self.dtoAssemblersAssembly.presentationSpeakerDTOAssembler())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
        }
    }
    
    dynamic func memberProfileDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(MemberDataStore.self)
    }
    
    dynamic func memberProfileViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("MemberProfileViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.memberProfilePresenter())
        })
    }
}
