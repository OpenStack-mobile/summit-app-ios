//
//  MemberProfileInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

public protocol MemberProfileDetailInteractorProtocol {
    func getSpeakerProfile(speakerId: Int, completionBlock : ErrorValue<PresentationSpeaker> -> ())
    func getAttendeeProfile(speakerId: Int, completionBlock : ErrorValue<SummitAttendee> -> ())
    func isLoggedIn() -> Bool
    func getCurrentMember() -> Member?
}

public class MemberProfileDetailInteractor: MemberProfileDetailInteractorProtocol {
    
    var presentationSpeakerDataStore = PresentationSpeakerDataStore()
    var summitAttendeeRemoteDataStore = SummitAttendeeRemoteDataStore()
    var securityManager: SecurityManager!
    
    public func getSpeakerProfile(speakerId: Int, completionBlock : ErrorValue<PresentationSpeaker> -> ()) {
        
        if let speaker = presentationSpeakerDataStore.getByIdLocal(speakerId) {
            
            let speakerDTO = PresentationSpeaker(realmEntity: speaker)
            
            completionBlock(.Value(speakerDTO))
        }
        else {
            
            let error = NSError(domain: "There was an error getting speaker data", code: 9001, userInfo: nil)
            
            completionBlock(.Error(error))
        }
    }
    
    public func getAttendeeProfile(speakerId: Int, completionBlock : ErrorValue<SummitAttendee> -> ()) {
        summitAttendeeRemoteDataStore.getById(attendeeId) { attendee, error in
            
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let attendeeDTO = self.summitAttendeeDTOAssembler.createDTO(attendee!)
            completionBlock(attendeeDTO, error)
        }
    }
    
    public func isLoggedIn() -> Bool {
        return securityManager.isLoggedIn()
    }
    
    public func getCurrentMember() -> Member? {
        var memberDTO: Member?
        if let member = securityManager.getCurrentMember() {
            memberDTO = Member(realmEntity: )
        }
        return memberDTO
    }
    
}