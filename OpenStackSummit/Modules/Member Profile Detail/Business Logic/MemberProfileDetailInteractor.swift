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
    func getSpeakerProfile(speakerId: Int, completionBlock : (PresentationSpeaker?, NSError?) -> Void)
    func getAttendeeProfile(speakerId: Int, completionBlock : (SummitAttendee?, NSError?) -> Void)
    func isLoggedIn() -> Bool
    func getCurrentMember() -> Member?
}

public class MemberProfileDetailInteractor: MemberProfileDetailInteractorProtocol {
    
    var presentationSpeakerDataStore: IPresentationSpeakerDataStore!
    var summitAttendeeRemoteDataStore: ISummitAttendeeRemoteDataStore!
    var securityManager: SecurityManager!
    
    public func getSpeakerProfile(speakerId: Int, completionBlock : (PresentationSpeaker?, NSError?) -> Void) {
        var error: NSError?
        var speakerDTO: PresentationSpeaker? = nil
        if let speaker = presentationSpeakerDataStore.getByIdLocal(speakerId) {
            speakerDTO = self.presentationSpeakerDTOAssembler.createDTO(speaker)
        }
        else {
            error = NSError(domain: "There was an error getting speaker data", code: 9001, userInfo: nil)
        }
        completionBlock(speakerDTO, error)
    }
    
    public func getAttendeeProfile(attendeeId: Int, completionBlock : (SummitAttendee?, NSError?) -> Void) {
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