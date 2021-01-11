//
//  EventKitItemLeftSideCellContentView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation

import UIKit

extension CalendarItemTableViewCell {

    class AbstractLeftSideContentView : ContentViewStack {
        init() {
            super.init(frame: CGRect.zero)
            self.addTimeLabel()
            self.addEventTitleLabel()
            self.addCalendarTitleLabel()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        lazy var timeLabel: UILabel = {
            let label = UILabel()
            label.textColor = Theme(for: self).secondaryLabelColor
            return label
        }()
        
        func addTimeLabel() {
            let view = self.timeLabel
            
            self.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            ])
        }
        
        lazy var eventTitleLabel: UILabel = {
            let label = UILabel()
            label.textColor = Theme(for: self).labelColor
            return label
        }()
        
        func addEventTitleLabel() {
            let view = self.eventTitleLabel
            
            self.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            ])
        }
        
        lazy var calendarTitleLabel: UILabel = {
            let label = UILabel()
            label.textColor = Theme(for: self).secondaryLabelColor
            return label
        }()
        
        func addCalendarTitleLabel() {
            let view = self.calendarTitleLabel
            
            self.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            ])
        }
        
        func prepareForReuse() {

        }
    }

}
