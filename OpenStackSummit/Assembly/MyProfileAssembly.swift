//
//  MyProfileAssembly.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class MyProfileAssembly: TyphoonAssembly {
    
    var applicationAssembly: ApplicationAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    
    var personalScheduleAssembly: PersonalScheduleAssembly!
    var memberProfileAssembly: MemberProfileAssembly!
    var feedbackGivenListAssembly: FeedbackGivenListAssembly!
    
    dynamic func myProfileWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(MyProfileWireframe.self) {
            (definition) in
            
            definition.injectProperty("navigationController", with: self.applicationAssembly.navigationController())
            definition.injectProperty("myProfileViewController", with: self.myProfileViewController())
            definition.injectProperty("personalScheduleViewController", with: self.personalScheduleAssembly.personalScheduleViewController())
            definition.injectProperty("feedbackGivenListViewController", with: self.feedbackGivenListAssembly.feedbackGivenListViewController())
            definition.injectProperty("memberProfileWireframe", with: self.memberProfileAssembly.memberProfileWireframe())
        }
    }
    
    dynamic func myProfilePresenter() -> AnyObject {
        return TyphoonDefinition.withClass(MyProfilePresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.myProfileViewController())
            definition.injectProperty("interactor", with: self.myProfileInteractor())
        }
    }
    
    dynamic func myProfileInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(MyProfileInteractor.self) {
            (definition) in
            
            definition.injectProperty("presentationSpeakerDataStore", with: self.dataStoreAssembly.presentationSpeakerDataStore())
            definition.injectProperty("summitAttendeeRemoteDataStore", with: self.dataStoreAssembly.summitAttendeeRemoteDataStore())
            definition.injectProperty("summitAttendeeDTOAssembler", with: self.dtoAssemblersAssembly.summitAttendeeDTOAssembler())
            definition.injectProperty("presentationSpeakerDTOAssembler", with: self.dtoAssemblersAssembly.presentationSpeakerDTOAssembler())
            definition.injectProperty("memberDTOAssembler", with: self.dtoAssemblersAssembly.memberDTOAssembler())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
        }
    }
    
    dynamic func myProfileViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("MyProfileViewController")
            }, configuration: {
                (definition) in
                
                definition.injectProperty("presenter", with: self.myProfilePresenter())
        })
    }
}