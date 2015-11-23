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
    var personalScheduleAssembly: PersonalScheduleAssembly!
    var memberProfileAssembly: MemberProfileAssembly!
    var feedbackGivenListAssembly: FeedbackGivenListAssembly!
    
    dynamic func myProfileViewController() -> AnyObject {
        return TyphoonDefinition.withClass(MyProfileViewController.self) {
            (definition) in
            
            definition.injectProperty("personalScheduleViewController", with: self.personalScheduleAssembly.personalScheduleViewController())
            definition.injectProperty("memberProfileViewController", with: self.memberProfileAssembly.memberProfileViewController())
            definition.injectProperty("feedbackGivenListViewController", with: self.feedbackGivenListAssembly.feedbackGivenListViewController())
        }
    }
}