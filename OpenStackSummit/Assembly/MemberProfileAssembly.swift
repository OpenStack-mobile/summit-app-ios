//
//  MemberProfileAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class MemberProfileAssembly: TyphoonAssembly {
    
    var applicationAssembly: ApplicationAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    
    var personalScheduleAssembly: PersonalScheduleAssembly!
    var memberProfileDetailAssembly: MemberProfileDetailAssembly!
    var feedbackGivenListAssembly: FeedbackGivenListAssembly!
    
    dynamic func memberProfileWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfileWireframe.self) {
            (definition) in
            
            definition.injectProperty("navigationController", with: self.applicationAssembly.navigationController())
            definition.injectProperty("memberProfileViewController", with: self.memberProfileViewController())
            definition.injectProperty("personalScheduleViewController", with: self.personalScheduleAssembly.personalScheduleViewController())
            definition.injectProperty("feedbackGivenListViewController", with: self.feedbackGivenListAssembly.feedbackGivenListViewController())
            definition.injectProperty("memberProfileDetailWireframe", with: self.memberProfileDetailAssembly.memberProfileDetailWireframe())
        }
    }
    
    dynamic func memberProfilePresenter() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfilePresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.memberProfileViewController())
            definition.injectProperty("interactor", with: self.memberProfileInteractor())
        }
    }
    
    dynamic func memberProfileInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfileInteractor.self) {
            (definition) in
            
            definition.injectProperty("presentationSpeakerDataStore", with: self.dataStoreAssembly.presentationSpeakerDataStore())
            definition.injectProperty("summitAttendeeRemoteDataStore", with: self.dataStoreAssembly.summitAttendeeRemoteDataStore())
            definition.injectProperty("summitAttendeeDTOAssembler", with: self.dtoAssemblersAssembly.summitAttendeeDTOAssembler())
            definition.injectProperty("presentationSpeakerDTOAssembler", with: self.dtoAssemblersAssembly.presentationSpeakerDTOAssembler())
            definition.injectProperty("memberDTOAssembler", with: self.dtoAssemblersAssembly.memberDTOAssembler())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
        }
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