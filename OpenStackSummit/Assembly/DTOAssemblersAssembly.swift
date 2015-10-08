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
    
}
