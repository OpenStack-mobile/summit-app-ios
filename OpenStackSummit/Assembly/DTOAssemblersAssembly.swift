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
            definition.injectProperty("ScheduleItemAssembler", with: self.ScheduleItemAssembler())
        }
    }
    
    dynamic func speakerDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(PresentationSpeakerDTOAssembler.self) {
            (definition) in
            
            definition.injectProperty("personListItemDTOAssembler", with: self.personListItemDTOAssembler())
        }
    }
    
    dynamic func ScheduleItemAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(ScheduleItemAssembler.self)
    }
    
    dynamic func memberProfileDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(MemberProfileDTOAssembler.self){
            (definition) in
            
            definition.injectProperty("ScheduleItemAssembler", with: self.ScheduleItemAssembler())
        }
    }
    
    dynamic func namedDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(NamedDTOAssembler.self)
    }
    
    dynamic func CoreSummit.SummitAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(CoreSummit.SummitAssembler.self)
    }

    dynamic func venueListItemDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(VenueListItemDTOAssembler.self)
    }

    dynamic func venueRoomDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(VenueRoomDTOAssembler.self) {
            (definition) in
            
            definition.injectProperty("ScheduleItemAssembler", with: self.ScheduleItemAssembler())
        }
    }
    
    dynamic func venueDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(VenueDTOAssembler.self) {
            (definition) in
            
            definition.injectProperty("venueRoomDTOAssembler", with: self.venueRoomDTOAssembler())
        }
    }
    
    dynamic func memberDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(MemberDTOAssembler.self) {
            (definition) in
            
            definition.injectProperty("presentationSpeakerDTOAssembler", with: self.presentationSpeakerDTOAssembler())
            definition.injectProperty("summitAttendeeDTOAssembler", with: self.summitAttendeeDTOAssembler())
        }

    }
    
}
