//
//  PresentationSpeakerDTOAssemblerMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class PresentationSpeakerDTOAssemblerMock: NSObject, IPresentationSpeakerDTOAssembler {
    var presentationSpeakerDTO: PresentationSpeakerDTO
    
    init(presentationSpeakerDTO: PresentationSpeakerDTO) {
        self.presentationSpeakerDTO = presentationSpeakerDTO
    }
    
    func createDTO(presentationSpeaker: PresentationSpeaker) -> PresentationSpeakerDTO {
        return presentationSpeakerDTO
    }
}
