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
    
    public static let horizontalInset: CGFloat = 20
    public static let verticalInset: CGFloat = 10
    public static let labelHeight:CGFloat = 20
    public static let verticalPadding:CGFloat = 4

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
        
        // left
        self.addCalendarColorBar()
        
        self.addStartTimeLabel()
        self.addEndTimeLabel()
        
        self.addEventTitleLabel()
//        self.addCalendarTitleLabel()

        // right
        self.addIconBar()

        self.addDividerView()
    }
    
    override func prepareForReuse() {
        self.countDownLabel.stopTimer()
        self.calendarItem = nil
        self.iconBar.prepareForReuse()
    }

    lazy var iconBar = CalendarItemIconBar()
    
    func addIconBar() {
        let view = self.iconBar
        
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.contentInsets.right),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.contentInsets.top)
        ])
    }
    
    func addCalendarColorBar() {

        let view = self.calendarColorBar
        
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.contentInsets.left),
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    lazy var calendarColorBar = VerticalColorBar()
    
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
    
    func updateCalendarBar(withCalendar calendar: Calendar) {
        if let calendarColor = calendar.color {
            self.calendarColorBar.color = calendarColor
        } else {
            self.calendarColorBar.color = SDKColor.systemGray
        }

        self.calendarColorBar.toolTip = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
    }
    
    lazy var countDownLabel: CountdownTextField = {
        let label = CountdownTextField()
        label.prefixString = "Alarm will fire in "
        label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        label.alignment = .right
        return label
    }()
    
    func addCountDownLabel() {
        let view = self.countDownLabel
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.contentInsets.right),
            view.lastBaselineAnchor.constraint(equalTo: self.eventTitleLabel.lastBaselineAnchor)
//            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
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
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: 0),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.contentInsets.top/2 + 5)
        ])
    }
    
    func addEndTimeLabel() {
        let view = self.endTimeLabel

        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: 0),
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
        label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
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
        
        self.updateCalendarBar(withCalendar: calendarItem.calendar)

        self.iconBar.update(withCalendarItem: calendarItem)
     
        if calendarItem.alarm.isHappeningNow {
            self.countDownLabel.stopTimer()
            self.countDownLabel.isHidden = true
        } else {
            self.countDownLabel.startTimer(fireDate: calendarItem.alarm.startDate)
            self.countDownLabel.isHidden = false
        }
        
        self.startTimeLabel.stringValue = calendarItem.alarm.startDate.shortTimeString
        self.endTimeLabel.stringValue = calendarItem.alarm.endDate.shortTimeString
        
        self.endTimeLabel.invalidateIntrinsicContentSize()
        self.startTimeLabel.invalidateIntrinsicContentSize()
        
//        self.timeLabel.stringValue = calendarItem.timeLabelDisplayString
        self.eventTitleLabel.stringValue = calendarItem.title
        
        self.view.needsLayout = true
    }
}
