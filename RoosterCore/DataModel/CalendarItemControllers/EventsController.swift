//
//  EventsController.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/22/21.
//

import Foundation
import EventKit

public class EventsController: CalendarItemController {
    
    
    public func shouldShowStatus(forEvent event: RCEvent) -> Bool {

        if  let originator = event.organizer,
            originator.isCurrentUser {
            return false
        }
        
//        event.allowsParticipationStatusModifications,
            
        if  event.hasParticipants,
            let currentUser = event.currentUser,
            currentUser.participantStatus.isVisibleStatus {
            return true
        }

        return false
    }

    public func save(event: RCEvent) {
        
        if event.hasChanges {
        
            let eventStore = event.calendar.ekEventStore
            
            let ekEvent = event.updateEKEvent()
            
            do {
                try eventStore.save(ekEvent, span: .thisEvent, commit: true)
            } catch {
                self.showSaveError(forItem:event,
                                   informativeText: "",
                                   error:error)
            }
        }
    }
}

extension RCEvent {
    func updateEKEvent() -> EKEvent {
        self.ekEvent.startDate = self.startDate
        self.ekEvent.endDate = self.endDate
        self.ekEvent.title = self.title
        self.ekEvent.location = self.location
        self.ekEvent.url = self.url
        self.ekEvent.notes = self.notes
        self.ekEvent.participationStatus_ = EKParticipantStatus(rawValue: self.participationStatus.rawValue) ?? .unknown
        self.ekEvent.isAllDay = self.isAllDay
        self.ekEvent.availability = EKEventAvailability(rawValue: self.availability.rawValue) ?? .notSupported
        
        return self.ekEvent
    }

}
