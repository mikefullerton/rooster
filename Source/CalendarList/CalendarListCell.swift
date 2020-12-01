//
//  CalendarListCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class CalendarListCell : UITableViewCell, TableViewRowCell {
    private var calendar: EventKitCalendar?

    private lazy var checkBox: UISwitch = {
        let cb = UISwitch()
        cb.preferredStyle = .checkbox
        cb.addTarget(self, action: #selector(checkBoxChecked(_:)), for: .valueChanged)
        self.contentView.addSubview(cb)
        return cb
    }()
    
    override func prepareForReuse() {
        self.calendar = nil
    }
    
    func setCalendar(_ calendar: EventKitCalendar) {
        self.calendar = calendar
        self.checkBox.title = calendar.title
        self.checkBox.setOn(calendar.isSubscribed, animated:false)
        self.checkBox.sizeToFit()
    }
    
    @objc func checkBoxChecked(_ checkbox: UISwitch) {
        if let calendar = self.calendar {
            calendar.set(subscribed: !calendar.isSubscribed)
        }
    }
    
    static var cellHeight: CGFloat {
        return 24
    }
    
    
    
}
