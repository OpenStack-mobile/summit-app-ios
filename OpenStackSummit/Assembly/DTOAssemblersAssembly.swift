//
//  DTOAssemblersAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Typhoon

public class DTOAssemblersAssembly: TyphoonAssembly {
    dynamic func summitAttendeeDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(SummitAttendeeDTOAssembler.self) {
            (definition) in
            definition.injectProperty("personListItemDTOAssembler", with: self.personListItemDTOAssembler())
        }
    }

    dynamic func presentationSpeakerDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(PresentationSpeakerDTOAssembler.self) {
            (definition) in
            definition.injectProperty("personListItemDTOAssembler", with: self.personListItemDTOAssembler())
        }
    }
    
    dynamic func personListItemDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(PersonListItemDTOAssembler.self)
    }
    
    dynamic func feedbackDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(FeedbackDTOAssembler.self)
    }
    
    dynamic func eventDetailDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(EventDetailDTOAssembler.self) {
            (definition) in
            
            definition.injectProperty("speakerDTOAssembler", with: self.speakerDTOAssembler())
            definition.injectProperty("scheduleItemDTOAssembler", with: self.scheduleItemDTOAssembler())
        }
    }
    
    dynamic func speakerDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(PresentationSpeakerDTOAssembler.self) {
            (definition) in
            
            definition.injectProperty("personListItemDTOAssembler", with: self.personListItemDTOAssembler())
        }
    }
    
    dynamic func scheduleItemDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(ScheduleItemDTOAssembler.self)
    }
    
    dynamic func memberProfileDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfileDTOAssembler.self){
            (definition) in
            
            definition.injectProperty("scheduleItemDTOAssembler", with: self.scheduleItemDTOAssembler())
        }
    }
}
