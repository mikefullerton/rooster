//
//  CalendarItemTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class CalendarItemTableViewCell : SDKCollectionViewItem {
    
    let contentInsets = SDKEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
    
    var dividerView: DividerView

    private(set) var calendarItem: CalendarItem?
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        self.dividerView = DividerView()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName:nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = SDKView()
        self.view.sdkLayer.cornerRadius = 6.0
        self.view.sdkLayer.borderWidth = 0.5
        self.view.sdkLayer.borderColor = SDKColor.separatorColor.cgColor
        self.view.sdkLayer.masksToBounds = true
        
        
        // left
        self.addCalendarColorBar()

        self.addStartTimeLabel()
        self.addEndTimeLabel()
        self.addStartCountDownLabel()
        self.addEndCountDownLabel()

        self.addEventTitleLabel()

        
        // right
        self.addIconBar()
        
        self.addTimePassingView()


        
    }
    
    override func prepareForReuse() {
        self.startCountDownLabel.stopCountdown()
        self.endCountDownLabel.stopCountdown()
        self.calendarItem = nil
        self.iconBar.prepareForReuse()
        self.timePassingView.stopTimer()
    }
    
    static var preferredHeight: CGFloat {
        return 80
    }

    lazy var timePassingView = TimePassingView()
    
    func addTimePassingView() {
        let view = self.timePassingView
        
        self.view.addSubview(view, positioned: .above, relativeTo:self.calendarColorBar)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.startTimeLabel.centerYAnchor),
            view.bottomAnchor.constraint(equalTo: self.endTimeLabel.centerYAnchor)
        ])
    }
    
    lazy var iconBar = CalendarItemIconBar()
    
    func addIconBar() {
        let view = self.iconBar
        
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.contentInsets.right),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    lazy var calendarColorBar = VerticalColorBar(insets: SDKEdgeInsets.zero,
                                                 barWidth: 8,
                                                 roundedCorners: false)
    
    func addCalendarColorBar() {

        let view = self.calendarColorBar
        
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    
    func addDividerView() {
        let dividerView = self.dividerView
        self.view.addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            dividerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dividerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
        self.dividerView = dividerView
    }
    
    lazy var startCountDownLabel: CountdownTextField = {
        let label = CountdownTextField()
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.alignment = .right
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.outputFormatter = { prefix, countdown in
            return " (starts in \(countdown))"
        }

        return label
    }()
    
    lazy var endCountDownLabel: CountdownTextField = {
        let label = CountdownTextField()
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.alignment = .right
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.outputFormatter = { prefix, countdown in
            return " (ends in \(countdown))"
        }
        
        return label
    }()
    
    
    func addStartCountDownLabel() {
        let view = self.startCountDownLabel
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.startTimeLabel.trailingAnchor, constant: 0),
            view.lastBaselineAnchor.constraint(equalTo: self.startTimeLabel.lastBaselineAnchor)
        ])
    }
    
    func addEndCountDownLabel() {
        let view = self.endCountDownLabel
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.endTimeLabel.trailingAnchor, constant: 0),
            view.lastBaselineAnchor.constraint(equalTo: self.endTimeLabel.lastBaselineAnchor)
        ])
    }

    var timeLabel: SDKTextField {
        let label = SDKTextField()
        
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        return label
    }
    
    lazy var countdownLabel: CountdownTextField = {
        let label = CountdownTextField()
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.alignment = .right
        label.textColor = Theme(for: self.view).secondaryLabelColor

        return label
        
    }()

    lazy var startTimeLabel: SDKTextField = {
        return self.timeLabel
    }()
    
    lazy var endTimeLabel: SDKTextField = {
        return self.timeLabel
    }()
    
    func addStartTimeLabel() {
        let view = self.startTimeLabel

        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.contentInsets.top/2 + 5)
        ])
    }
    
    func addEndTimeLabel() {
        let view = self.endTimeLabel

        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.contentInsets.bottom/2 - 5)
        ])
    }
    
    lazy var combinedTimeLabel: SDKTextField = {
        let label = SDKTextField()
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false

        return label
    }()
    
    func addCombinedTimeLabel() {
        let view = self.combinedTimeLabel
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.contentInsets.top),
        ])
        
//        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    lazy var eventTitleLabel: SDKTextField = {
        let label = SDKTextField()
        label.textColor = Theme(for: self.view).labelColor
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false

        return label
    }()
    
    func addEventTitleLabel() {
        let view = self.eventTitleLabel
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
        ])
    }
    
    func updateCell(withCalendarItem calendarItem: CalendarItem) {
        
        self.calendarItem = calendarItem
        
        let calendar = calendarItem.calendar
        
        if let calendarColor = calendar.color {
            self.calendarColorBar.color = calendarColor
        } else {
            self.calendarColorBar.color = SDKColor.systemGray
        }

        self.calendarColorBar.toolTip = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
        self.eventTitleLabel.toolTip = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
        
        self.iconBar.update(withCalendarItem: calendarItem)
        
        self.startTimeLabel.stringValue = calendarItem.alarm.startDate.shortTimeString
        self.endTimeLabel.stringValue = calendarItem.alarm.endDate.shortTimeString
        self.startCountDownLabel.stopCountdown()
        self.endCountDownLabel.stopCountdown()

        if calendarItem.alarm.isHappeningNow {
            self.startCountDownLabel.isHidden = true
            self.endCountDownLabel.isHidden = false
            
            self.timePassingView.set(startDate: calendarItem.alarm.startDate,
                                     endDate: calendarItem.alarm.endDate)
            
            self.endCountDownLabel.startTimer(fireDate: calendarItem.alarm.endDate)
        } else {
            self.startCountDownLabel.isHidden = false
            self.endCountDownLabel.isHidden = true

            self.startCountDownLabel.startTimer(fireDate: calendarItem.alarm.startDate)
        }
        
//        self.timeLabel.stringValue = calendarItem.timeLabelDisplayString
        self.eventTitleLabel.stringValue = calendarItem.title
        
        self.view.needsLayout = true
    }
}
