//
//  SpeakerPresentationsWireframe.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 12/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation

public class SpeakerPresentationsWireframe: ScheduleWireframe {
    var speakerPresentationsViewController: SpeakerPresentationsViewController!
    
    public override func showEventDetail(eventId: Int) {
        super.showEventDetail(eventId, viewController: speakerPresentationsViewController)
    }
}

