//
//  EventListTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

class EventListTableViewCell : EventKitItemTableViewCell, TableViewRowCell {
    private var event: EventKitEvent? = nil
    
    private var leftView: LeftSideContentView
    private var rightView: RightSideContentView
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        self.rightView = RightSideContentView()
        self.leftView = LeftSideContentView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.addRightView(self.rightView)
        self.addLeftView(self.leftView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var cellHeight: CGFloat {
        return (EventListTableViewCell.labelHeight + EventListTableViewCell.verticalPadding) * 3 + 20
    }
    
    override func prepareForReuse() {
        self.event = nil
    
        self.leftView.prepareForReuse()
        self.rightView.prepareForReuse()
    }
    
    func setEvent(_ event: EventKitEvent) {

        self.event = event
        
        self.updateCalendarBar(withCalendar: event.calendar)
        
        self.leftView.setEvent(event)
        self.rightView.setEvent(event)
        
        self.setNeedsLayout()
        
    }
}
