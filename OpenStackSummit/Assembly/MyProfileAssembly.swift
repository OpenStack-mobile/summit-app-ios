import UIKit
import Typhoon

public class MyProfileAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var personalScheduleAssembly: PersonalScheduleAssembly!
    var memberProfileDetailAssembly: MemberProfileDetailAssembly!
    var feedbackGivenListAssembly: FeedbackGivenListAssembly!
    var speakerPresentationsAssembly: SpeakerPresentationsAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!

    dynamic func myProfileWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(MyProfileWireframe.self) {
            (definition) in
            definition.injectProperty("navigationController", with: self.applicationAssembly.navigationController())
            definition.injectProperty("myProfileViewController", with: self.myProfileViewController())
        }
    }
    
    dynamic func myProfilePresenter() -> AnyObject {
        return TyphoonDefinition.withClass(MyProfilePresenter.self) {
            (definition) in
            
            definition.injectProperty("memberProfileDetailViewController", with: self.memberProfileDetailAssembly.memberProfileDetailViewController())
            definition.injectProperty("personalScheduleViewController", with: self.personalScheduleAssembly.personalScheduleViewController())
            definition.injectProperty("feedbackGivenListViewController", with: self.feedbackGivenListAssembly.feedbackGivenListViewController())
            definition.injectProperty("speakerPresentationsViewController", with: self.speakerPresentationsAssembly.speakerPresentationsViewController())
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
                definition.scope = TyphoonScope.WeakSingleton
        })
    }
}
