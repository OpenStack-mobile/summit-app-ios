//
//  MemberProfileDetailAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class MemberProfileDetailAssembly: TyphoonAssembly {
    var securityManagerAssembly: SecurityManagerAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var applicationAssembly: ApplicationAssembly!
    
    dynamic func memberProfileDetailWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfileDetailWireframe.self) {
            (definition) in
            definition.injectProperty("memberProfileDetailViewController", with: self.memberProfileDetailViewController())
        }
    }
    
    dynamic func memberProfileDetailPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfileDetailPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.memberProfileDetailInteractor())
            definition.injectProperty("memberProfileDetailWireframe", with: self.memberProfileDetailWireframe())
            definition.injectProperty("viewController", with: self.memberProfileDetailViewController())
        }
    }
    
    dynamic func memberProfileDetailInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfileDetailInteractor.self) {
            (definition) in
            
            definition.injectProperty("presentationSpeakerDataStore", with: self.dataStoreAssembly.presentationSpeakerDataStore())
            definition.injectProperty("summitAttendeeRemoteDataStore", with: self.dataStoreAssembly.summitAttendeeRemoteDataStore())
            definition.injectProperty("summitAttendeeDTOAssembler", with: self.dtoAssemblersAssembly.summitAttendeeDTOAssembler())
            definition.injectProperty("presentationSpeakerDTOAssembler", with: self.dtoAssemblersAssembly.presentationSpeakerDTOAssembler())
            definition.injectProperty("memberDTOAssembler", with: self.dtoAssemblersAssembly.memberDTOAssembler())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
        }
    }
    
    dynamic func memberProfileDetailViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("MemberProfileDetailViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.memberProfileDetailPresenter())
        })
    }
}
