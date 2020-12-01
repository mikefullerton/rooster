//
//  EventListViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

struct EventListViewModel : TableViewModelProtocol {
    
    let sections: [TableViewSectionProtocol]
    
    init(withEvents events: [EventKitEvent]) {
        var sections: [TableViewSectionProtocol] = []
        for event in events {
            sections.append(EventSection(withEvent: event))
        }
        self.sections = sections
    }
}
