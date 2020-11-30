//
//  EventListViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

struct EventRow : TableViewRowProtocol {
    private let event: EventKitEvent
    
    init(withEvent event: EventKitEvent) {
        self.event = event
    }
    
    var cellReuseIdentifer: String {
        return "EventRow"
    }
    
    var cellClass: UITableViewCell.Type {
        return EventListTableViewCell.self
    }
    
    var height: CGFloat {
        return 40
    }
    
    func willDisplay(cell: UITableViewCell) {
        if let calenderCell = cell as? EventListTableViewCell {
            calenderCell.setEvent(self.event)
        }
    }
}

struct EventSection : TableViewSectionProtocol {
    private let event: EventKitEvent
    
    init(withEvent event: EventKitEvent) {
        self.event = event
    }
    
    var rowCount: Int {
        return 1
    }

    func row(forIndex index: Int) -> TableViewRowProtocol? {
        guard index == 0 else {
            return nil
        }
            
        return EventRow(withEvent: self.event)
    }
    
    var header: TableViewSectionAdornmentProtocol? {
        return SpacerAdornment(withHeight: 10.0)
    }
    
    var footer: TableViewSectionAdornmentProtocol? {
        return DividerAdornment(withHeight: 20.0)
    }
}

struct EventListViewModel : TableViewModelProtocol {
    
    private let sections: [TableViewSectionProtocol]
    
    init(withEvents events: [EventKitEvent]) {
        var sections: [TableViewSectionProtocol] = []
        for event in events {
            sections.append(EventSection(withEvent: event))
        }
        self.sections = sections
    }
    
    var sectionCount: Int {
        return self.sections.count
    }
    
    func section(forIndex index: Int) -> TableViewSectionProtocol? {
        guard index >= 0, index < self.sections.count else {
            return nil
        }
        return self.sections[index]
    }
    
    
}
