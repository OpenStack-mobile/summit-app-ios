//
//  MemberOrderConfirmInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

@objc
protocol IMemberOrderConfirmInteractor {
    func getAttendeesForTicketOrder(orderNumber: String, completionBlock: ([NamedDTO]?, NSError?) -> Void)
}

public class MemberOrderConfirmInteractor: NSObject, IMemberOrderConfirmInteractor {
    var memberDataStore: IMemberDataStore!
    var reachability: IReachability!
    var securityManager: SecurityManager!
    var namedDTOAssembler: NamedDTOAssembler!

    public func getAttendeesForTicketOrder(orderNumber: String, completionBlock: ([NamedDTO]?, NSError?) -> Void) {
        if !reachability.isConnectedToNetwork() {
            let error = NSError(domain: "There is no network connectivity. Operation cancelled", code: 15002, userInfo: nil)
            completionBlock(nil, error)
            return
        }
        
        if securityManager.isLoggedIn(){
            
            memberDataStore.getAttendeesForTicketOrderOrigin(orderNumber) { (nonConfirmedAttendees, error) in
                
                if error != nil {
                    completionBlock(nil, error)
                    return
                }
                
                if let nonConfirmedAttendees = nonConfirmedAttendees {
                    var nonConfirmedSummitAttendeeDTO: NamedDTO
                    var dtos: [NamedDTO] = []
                    for nonConfirmedSummitAttendee in nonConfirmedAttendees {
                        nonConfirmedSummitAttendeeDTO = self.namedDTOAssembler.createDTO(nonConfirmedSummitAttendee)
                        dtos.append(nonConfirmedSummitAttendeeDTO)
                    }
                    
                    completionBlock(dtos, error)
                }
            }
        }
    
        
    }
}
