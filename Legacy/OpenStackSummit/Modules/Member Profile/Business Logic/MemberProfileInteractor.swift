//
//  MemberProfileInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation

@objc
public protocol IMemberProfileInteractor {
    func getSpeakerProfile(speakerId: Int, completionBlock : (PresentationSpeakerDTO?, NSError?) -> Void)
    func getCurrentMember() -> MemberDTO?
}

public class MemberProfileInteractor: NSObject, IMemberProfileInteractor {
    
    var presentationSpeakerDataStore: IPresentationSpeakerDataStore!
    var summitAttendeeRemoteDataStore: ISummitAttendeeRemoteDataStore!
    var summitAttendeeDTOAssembler: ISummitAttendeeDTOAssembler!
    var presentationSpeakerDTOAssembler: IPresentationSpeakerDTOAssembler!
    var memberDTOAssembler: IMemberDTOAssembler!
    var securityManager: SecurityManager!
    
    public func getSpeakerProfile(speakerId: Int, completionBlock : (PresentationSpeakerDTO?, NSError?) -> Void) {
        var error: NSError?
        var speakerDTO: PresentationSpeakerDTO? = nil
        if let speaker = presentationSpeakerDataStore.getByIdLocal(speakerId) {
            speakerDTO = self.presentationSpeakerDTOAssembler.createDTO(speaker)
        }
        else {
            error = NSError(domain: "There was an error getting speaker data", code: 9001, userInfo: nil)
        }
        completionBlock(speakerDTO, error)
    }
    
    public func getCurrentMember() -> MemberDTO? {
        var memberDTO: MemberDTO?
        if let member = securityManager.getCurrentMember() {
            memberDTO = memberDTOAssembler.createDTO(member)
        }
        return memberDTO
    }
    
}