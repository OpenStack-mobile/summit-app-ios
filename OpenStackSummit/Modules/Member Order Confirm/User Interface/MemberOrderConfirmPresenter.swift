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
}

class MemberOrderConfirmPresenter: NSObject, IMemberOrderConfirmPresenter {
    
    var interactor: IMemberOrderConfirmInteractor!
    var wireframe: IMemberOrderConfirmWireframe!
    var viewController: IMemberOrderConfirmViewController!
    var orderNumber: String!
    
    func viewLoad() {
    
    }
    
    func orderConfirm(orderNumber: String) {
        viewController.showActivityIndicator();
        
        self.orderNumber = orderNumber;
        
        interactor.getAttendeesForTicketOrder(orderNumber) { nonConfirmedAttendees, error in
/*            if error != nil {
                String friendlyMessage = message;
                if (message.startsWith("412")) {
                    friendlyMessage = view.getResources().getString(R.string.eventbrite_order_already_in_use);
                }
                else if (message.startsWith("404")) {
                    friendlyMessage = view.getResources().getString(R.string.order_not_found);
                }
                
                self.viewController.showErrorMessage(error!)
                return
            }
            
            nonConfirmedSummitAttendeeDTOs = data;
            
            if (nonConfirmedSummitAttendeeDTOs.size() == 0) {
                view.showInfoMessage(view.getResources().getString(R.string.order_not_found));
            }
            else if (nonConfirmedSummitAttendeeDTOs.size() == 1) {
                selectAttendeeFromOrderList(0);
            }
            else if (nonConfirmedSummitAttendeeDTOs.size() > 1) {
                view.setAttendees(data);
            }
            
            view.hideActivityIndicator();*/
            
            
            
        }
    }
}
