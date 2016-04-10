//
//  MemberOrderConfirmPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

@objc
protocol IMemberOrderConfirmPresenter {
    func viewLoad()
    func orderConfirm(orderNumber: String)
    func selectAttendeeFromOrderList(index: Int)
}

class MemberOrderConfirmPresenter: NSObject, IMemberOrderConfirmPresenter {
    
    var interactor: IMemberOrderConfirmInteractor!
    var wireframe: IMemberOrderConfirmWireframe!
    var viewController: IMemberOrderConfirmViewController!
    var orderNumber: String!
    var nonConfirmedAttendees: [NamedDTO]?
    let kOrderAlreadyInUse = "This Order# has already been associated with another user. If you feel this is an error, please contact summitsupport@openstack.org or enter a different Order #."
    let kOrderNotFound = "Order wasn\'t found. Please verify that you provided correct order # and try again."
    
    func viewLoad() {
    
    }
    
    func orderConfirm(orderNumber: String) {
        viewController.showActivityIndicator();
        
        self.orderNumber = orderNumber;
        
        interactor.getAttendeesForTicketOrder(orderNumber) { nonConfirmedAttendees, error in
            defer { self.viewController.hideActivityIndicator(); }
            
            if error != nil {
                if (error?.code == 412) {
                    self.viewController.showInfoMessage("Info", message: self.kOrderAlreadyInUse)
                }
                else if (error?.code == 404) {
                    self.viewController.showInfoMessage("Info", message: self.kOrderNotFound)

                }
                else {
                    self.viewController.showErrorMessage(error!)
                }
                
                return
            }
            
            self.nonConfirmedAttendees = nonConfirmedAttendees
            
            if (nonConfirmedAttendees?.count == 0) {
                self.viewController.showInfoMessage("Info", message: "Order wasn\'t found. Please verify that you provided correct order # and try again.");
            }
            else if (nonConfirmedAttendees?.count == 1) {
                self.selectAttendeeFromOrderList(0);
            }
            else if (nonConfirmedAttendees?.count > 1) {
                self.viewController.setSummitAttendees(nonConfirmedAttendees!);
            }
        
            self.viewController.showAttendeesSelector(nonConfirmedAttendees?.count > 0)
        }
    }
    
    func selectAttendeeFromOrderList(index: Int) {

        viewController.showActivityIndicator();
        
        if let nonConfirmedSummitAttendee =  nonConfirmedAttendees?[index] {
            interactor.selectAttendeeFromOrderList(orderNumber,externalAttendeeId: nonConfirmedSummitAttendee.id) { error in
                defer { self.viewController.hideActivityIndicator() }
                
                if error != nil {
                    if (error?.code == 412) {
                        self.viewController.showInfoMessage("Info", message: self.kOrderAlreadyInUse)
                    }
                    else if (error?.code == 404) {
                        self.viewController.showInfoMessage("Info", message: self.kOrderNotFound)
                        
                    }
                    else {
                        self.viewController.showErrorMessage(error!)
                    }
                    
                    self.viewController.showAttendeesSelector(false)
                    
                    return
                }
                
                self.viewController.hideActivityIndicator()
                self.wireframe.showEvents()
            };
        }
    }
}
