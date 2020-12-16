//
//  ReminderTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation
import UIKit

class ReminderTableViewCell : EventKitItemTableViewCell, TableViewRowCell {
    private var reminder: EventKitReminder? = nil
    
    private var leftView: LeftSideContentView
    private var rightView: RightSideContentView
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        self.rightView = RightSideContentView()
        self.leftView = LeftSideContentView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.addLeftView(self.leftView)
        self.addRightView(self.rightView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var cellHeight: CGFloat {
        return (EventListTableViewCell.labelHeight + EventListTableViewCell.verticalPadding) * 3 + 20
    }
    
    override func prepareForReuse() {
        self.reminder = nil
    
        self.leftView.prepareForReuse()
        self.rightView.prepareForReuse()
    }
    
    func setReminder(_ reminder: EventKitReminder) {

        self.reminder = reminder
        
        self.updateCalendarBar(withCalendar: reminder.calendar)
        
        self.leftView.setReminder(reminder)
        self.rightView.setReminder(reminder)
        
        self.setNeedsLayout()
    }
}
