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

    private let padding:CGFloat = 8
    
    private lazy var checkBox: UISwitch = {
        let view = UISwitch()
        view.preferredStyle = .checkbox
        view.addTarget(self, action: #selector(checkBoxChecked(_:)), for: .valueChanged)
        self.contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.padding),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        ])

        return view
    }()
    
    lazy var calendarColorBar: UIView = {
        let view = UIView()
        self.addSubview(view)
      
        let width: CGFloat = 4
        let inset: CGFloat = 2
        
        view.layer.cornerRadius = width / 2.0;
      
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: inset),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.padding),
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
            self.checkBox.thumbTintColor = calendarColor
            self.calendarColorBar.backgroundColor = calendarColor
            self.calendarColorBar.isHidden = false
        } else {
            self.checkBox.thumbTintColor = nil
            self.calendarColorBar.isHidden = true
        }
    }
    
    @objc func checkBoxChecked(_ checkbox: UISwitch) {
        if let calendar = self.calendar {
            calendar.set(subscribed: !calendar.isSubscribed)
        }
    }
    
    static var cellHeight: CGFloat {
        return 28
    }
    
    
    
}
