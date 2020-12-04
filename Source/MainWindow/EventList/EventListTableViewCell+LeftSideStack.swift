//
//  EventListTableViewCell+LeftSideStack.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/4/20.
//

import Foundation
import UIKit

extension EventListTableViewCell {
    
    class LeftSideStack : UIView {

        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            
            self.addTimeLabel()
            self.addEventTitleLabel()
            self.addCalendarTitleLabel()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        lazy var timeLabel: UILabel = {
            let label = UILabel()
            label.textColor = UIColor.secondaryLabel
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 26)
            return label
        }()
        
        func addTimeLabel() {
            
            let view = self.timeLabel
            
            self.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
                view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            ])
        }
        
        lazy var eventTitleLabel: UILabel = {
            let label = UILabel()
            label.textColor = UIColor.label
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 26)
            return label
        }()
        
        func addEventTitleLabel() {
            let view = self.eventTitleLabel
            
            self.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            ])
        }
        
        lazy var calendarTitleLabel: UILabel = {
            let label = UILabel()
            label.textColor = UIColor.secondaryLabel
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 26)
            return label
        }()
        
        func addCalendarTitleLabel() {
            let view = self.calendarTitleLabel
            
            self.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
                view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            ])
        }
        
        func shortDateString(_ date: Date) -> String {
            return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
        }
        
        func setEvent(_ event: EventKitEvent) {
            let startTime = self.shortDateString(event.startDate)
            let endTime = self.shortDateString(event.endDate)
            
            self.timeLabel.text = "\(startTime) - \(endTime)"
            self.eventTitleLabel.text = event.title
            
            let calendar = event.calendar
            self.calendarTitleLabel.text = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
        }
        
        func prepareForReuse() {

        }
    }
}
