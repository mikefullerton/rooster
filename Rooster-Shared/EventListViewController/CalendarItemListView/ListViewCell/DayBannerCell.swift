//
//  DayBannerCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/22/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif


class DayBannerRow : ListViewRowController<Date> {
   
    private var date: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.sdkLayer.cornerRadius = 0.0
        self.view.sdkLayer.backgroundColor = NSColor.clear.cgColor

        self.addTodayTomorrowLabel()
        self.addTimeLabel()
    }
    
    lazy var timeLabel: SDKTextField = {
        let label = SDKTextField()
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false

        return label
    }()

    lazy var todayTomorrowLabel: SDKTextField = {
        let label = SDKTextField()
        label.textColor = Theme(for: self.view).labelColor
        label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false

        return label
    }()

    
    private func addTimeLabel() {
        let view = self.timeLabel
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addTodayTomorrowLabel() {
        let view = self.todayTomorrowLabel
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    open class override func preferredSize(forContent content: Any?) -> CGSize {
        
        if let date = content as? Date {
            if date.isToday || date.isTomorrow {
                return CGSize(width: -1, height: 42)
            }

            return CGSize(width: -1, height: 20)
        }
        
        return CGSize(width: -1, height: 20)
    }
    
    private func updateContstraints() {
        self.todayTomorrowLabel.removeLocationContraints()
        self.timeLabel.removeLocationContraints()
        
        if self.todayTomorrowLabel.isHidden == false {
        
            NSLayoutConstraint.activate([
                self.todayTomorrowLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                self.todayTomorrowLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -8),

                self.timeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                self.timeLabel.topAnchor.constraint(equalTo: self.todayTomorrowLabel.bottomAnchor, constant: 0)

            ])
        } else {
            self.view.setCenteredInParentConstraints(forSubview: self.timeLabel)
        }
    }
    

    override func viewWillAppear(withContent date: Date) {
        let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .full, timeStyle: .none)
    
        if date.isToday {
            self.todayTomorrowLabel.stringValue = "Today"
            self.todayTomorrowLabel.isHidden = false
            self.timeLabel.stringValue = formattedDate
        } else if date.isTomorrow {
            self.todayTomorrowLabel.stringValue = "Tomorrow"
            self.todayTomorrowLabel.isHidden = false
            self.timeLabel.stringValue = formattedDate
        } else {
            self.todayTomorrowLabel.isHidden = true
            self.timeLabel.stringValue = formattedDate
        }
        
        self.updateContstraints()
    }

}
    
