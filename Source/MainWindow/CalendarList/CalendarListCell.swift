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
        let view = UISwitch()
        view.preferredStyle = .checkbox
        view.addTarget(self, action: #selector(checkBoxChecked(_:)), for: .valueChanged)
        self.contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        ])

        return view
    }()
    
    lazy var calendarColorBar: UIView = {
        let view = UIView()
        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 4),
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        ])
        
        return view
    }()
    
    override func prepareForReuse() {
        self.calendar = nil
    }
    
    func setCalendar(_ calendar: EventKitCalendar) {
        self.calendar = calendar
        self.checkBox.title = calendar.title
        self.checkBox.setOn(calendar.isSubscribed, animated:false)
        self.checkBox.sizeToFit()
        if let calendarColor = calendar.color {
            self.calendarColorBar.backgroundColor = calendarColor
            self.calendarColorBar.isHidden = false
        } else {
            self.calendarColorBar.isHidden = true
        }
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
