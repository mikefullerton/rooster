//
//  EventListTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

class EventListTableViewCell : UITableViewCell {
    
    private var event: EventKitEvent?
    
    override func prepareForReuse() {
        self.event = nil
    }
    
    func setEvent(_ event: EventKitEvent) {
        self.event = event
        
        if let text = self.event?.title {
            self.textLabel?.text = text
        }
    }
}
