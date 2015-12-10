//
//  MyProfileInteractor.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 12/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation

@objc
public protocol IMyProfileInteractor {
    func getSpeakerProfile(speakerId: Int, completionBlock : (PresentationSpeakerDTO?, NSError?) -> Void)
    func getCurrentMember() -> MemberDTO?
}

public class MyProfileInteractor: NSObject, IMyProfileInteractor {
    
    var presentationSpeakerRemoteDataStore: IPresentationSpeakerRemoteDataStore!
    var summitAttendeeRemoteDataStore: ISummitAttendeeRemoteDataStore!
    var summitAttendeeDTOAssembler: ISummitAttendeeDTOAssembler!
    var presentationSpeakerDTOAssembler: IPresentationSpeakerDTOAssembler!
    var memberDTOAssembler: IMemberDTOAssembler!
    var securityManager: SecurityManager!
    
    public func getSpeakerProfile(speakerId: Int, completionBlock : (PresentationSpeakerDTO?, NSError?) -> Void) {
        presentationSpeakerRemoteDataStore.getById(speakerId) { speaker, error in
            
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let speakerDTO = self.presentationSpeakerDTOAssembler.createDTO(speaker!)
            completionBlock(speakerDTO, error)
        }
    }
    
    public func getCurrentMember() -> MemberDTO? {
        var memberDTO: MemberDTO?
        if let member = securityManager.getCurrentMember() {
            memberDTO = memberDTOAssembler.createDTO(member)
        }
        return memberDTO
    }
    
}