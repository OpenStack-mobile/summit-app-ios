//
//  MemberProfileInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfileInteractor {
    func getSpeakerProfile(speakerId: Int, completionBlock : (PresentationSpeakerDTO?, NSError?) -> Void)
    func getAttendeeProfile(speakerId: Int, completionBlock : (SummitAttendeeDTO?, NSError?) -> Void)
    func isLoggedIn() -> Bool
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
    
    public func getAttendeeProfile(attendeeId: Int, completionBlock : (SummitAttendeeDTO?, NSError?) -> Void) {
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
    
    public func getCurrentMember() -> MemberDTO? {
        var memberDTO: MemberDTO?
        if let member = securityManager.getCurrentMember() {
            memberDTO = memberDTOAssembler.createDTO(member)
        }
        return memberDTO
    }
    
}