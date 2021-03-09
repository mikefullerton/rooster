//
//  CalendarItemListViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class CalendarItemListViewCell<ITEM_TYPE: RCCalendarItem> : ListViewRowController<ITEM_TYPE>, CountDownTextFieldDelegate {
    
    let contentInsets = SDKEdgeInsets(top: 14, left: 14, bottom: 14, right: 10)
    
    var dividerView: DividerView

    private(set) var calendarItem: ITEM_TYPE?

    let itemTypeLabelTopInset:CGFloat = 8
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.sdkLayer.cornerRadius = 0.0
        self.view.sdkLayer.backgroundColor = NSColor.clear.cgColor

//        self.view.sdkLayer.cornerRadius = 6.0
        self.view.sdkLayer.borderWidth = 0.5
        self.view.sdkLayer.borderColor = SDKColor.separatorColor.cgColor
        self.view.sdkLayer.masksToBounds = true
        
        self.addHighlightBackgroundView()
        
        // left
        self.addCalendarColorBar()

        self.addEventTitleLabel()

        self.addStartTimeLabel()
        self.addInfoBar()
        self.addEndTimeLabel()
        
        self.addStartCountDownLabel()
        self.addEndCountDownLabel()

//        self.addItemTypeButton()
        
        self.addItemTypeLabel()
        
        // right
        self.addIconBar()
        
        
        self.addTimePassingView()
        
    }
    
    override func prepareForReuse() {
        self.startCountDownLabel.stopCountDown()
        self.endCountDownLabel.stopCountDown()
        self.calendarItem = nil
        self.iconBar.prepareForReuse()
        self.timePassingView.stopTimer()
    }
    
    class override var preferredHeight:CGFloat {
        return 80
    }
    
    /// MARK: Views

    lazy var infoBar = CalendarItemInfoBar()
    
    lazy var timePassingView = TimePassingView()
    
    lazy var iconBar = CalendarItemIconBar()
    
    lazy var calendarColorBar = VerticalColorBar(insets: SDKEdgeInsets.zero,
                                                 barWidth: 8,
                                                 roundedCorners: false)
    
    lazy var startCountDownLabel: CountDownTextField = {
        let label = CountDownTextField()
        label.countDownDelegate = self
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.alignment = .right
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.outputFormatter = { prefix, countdown in
            return " (Starts in \(countdown))"
        }

        return label
    }()
    
    lazy var endCountDownLabel: CountDownTextField = {
        let label = CountDownTextField()
        label.countDownDelegate = self
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.alignment = .right
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.outputFormatter = { prefix, countdown in
            return " (Ends in \(countdown))"
        }
        
        return label
    }()

    func createTimeLabel() -> SDKTextField {
        let label = SDKTextField()
        
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        return label
    }
    
    var itemTypeString: String {
        return ""
    }
    
    lazy var itemTypeLabel: SDKTextField = {
        let label = SDKTextField()
        
        label.textColor = Theme(for: self.view).tertiaryLabelColor
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize - 1)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        
//        let string = self.itemTypeString
        
//        label.attributedStringValue = NSAttributedString(string: string, attributes: [ NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue ])
        
        label.stringValue = "\(self.itemTypeString):"
        
        return label
    }()
    

    lazy var countdownLabel: CountDownTextField = {
        let label = CountDownTextField()
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.alignment = .right
        label.textColor = Theme(for: self.view).secondaryLabelColor
        return label
    }()

    lazy var startTimeLabel: SDKTextField = {
        return self.createTimeLabel()
    }()
    
    lazy var endTimeLabel: SDKTextField = {
        return self.createTimeLabel()
    }()
    
    lazy var combinedTimeLabel: SDKTextField = {
        let label = SDKTextField()
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false

        return label
    }()
    
    lazy var eventTitleLabel: SDKTextField = {
        let label = SDKTextField()
        label.textColor = Theme(for: self.view).labelColor
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false

        return label
    }()

    var imageButtonIcon: SDKImage? {
        return nil
    }
    
    lazy var itemTypeButton: ImageButton = {
        let button = ImageButton(withImage: self.imageButtonIcon!)
        
        return button
    }()
    
    /// MARK: Adding views
    
    func addInfoBar() {
        let view = self.infoBar
        
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.eventTitleLabel.trailingAnchor, constant: 4),
            view.topAnchor.constraint(equalTo: self.eventTitleLabel.topAnchor, constant: 0)
        ])
    }
    
    func addItemTypeLabel() {
        let view = self.itemTypeLabel
        
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left / 2),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.itemTypeLabelTopInset)
        ])
    }
    
    func addTimePassingView() {
        let view = self.timePassingView
        
        self.view.addSubview(view, positioned: .above, relativeTo:self.calendarColorBar)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
//            view.topAnchor.constraint(equalTo: self.startTimeLabel.centerYAnchor),
//            view.bottomAnchor.constraint(equalTo: self.endTimeLabel.centerYAnchor)
        ])
    }
    
    func addIconBar() {
        let view = self.iconBar
        
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.contentInsets.right),
            view.centerYAnchor.constraint(equalTo: self.eventTitleLabel.centerYAnchor)
        ])
    }

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
    
    static var timeInset: CGFloat {
        return 2.0
    } 
    
    func addStartTimeLabel() {
        let view = self.startTimeLabel

        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.bottomAnchor.constraint(equalTo: self.eventTitleLabel.topAnchor, constant: -Self.timeInset)
        ])
    }
    
    func addEndTimeLabel() {
        let view = self.endTimeLabel

        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.topAnchor.constraint(equalTo: self.eventTitleLabel.bottomAnchor, constant: Self.timeInset)
        ])
    }
    
    func addCombinedTimeLabel() {
        let view = self.combinedTimeLabel
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.contentInsets.top),
        ])
    }
    
    func addEventTitleLabel() {
        let view = self.eventTitleLabel
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: self.itemTypeLabelTopInset - 2),
        ])
    }
    
    func addItemTypeButton() {
        let view = self.itemTypeButton
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: 2),
//            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 2),
            view.centerYAnchor.constraint(equalTo: self.startTimeLabel.centerYAnchor, constant: 0),
            view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width),
            view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height)
        ])
    }
    
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

    /// MARK: Utils
    
    func countDownTextFieldNextFireDate(_ countDownTextField: CountDownTextField) -> Date? {
        if countDownTextField === self.startCountDownLabel {
            return self.calendarItem?.alarm.startDate
        } else if countDownTextField === self.endCountDownLabel,
                  countDownTextField.isHidden == false {
            return self.calendarItem?.alarm.endDate
        }
        
        return nil
    }
    
    
    override func viewWillAppear(withContent calendarItem: ITEM_TYPE) {
        self.calendarItem = calendarItem
        
        let calendar = calendarItem.calendar
        
        if let calendarColor = calendar.color {
            self.calendarColorBar.color = calendarColor
        } else {
            self.calendarColorBar.color = SDKColor.systemGray
        }
        
//        self.itemTypeLabel.textColor = self.calendarColorBar.color
       

        self.calendarColorBar.toolTip = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
        self.eventTitleLabel.toolTip = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
        
        self.iconBar.update(withCalendarItem: calendarItem)
        self.infoBar.update(withCalendarItem: calendarItem)
        
        self.startTimeLabel.stringValue = calendarItem.alarm.startDate.shortTimeString
        self.endTimeLabel.stringValue = calendarItem.alarm.endDate.shortTimeString
        self.startCountDownLabel.stopCountDown()
        self.endCountDownLabel.stopCountDown()
        
        if calendarItem.isHappeningNow {
            self.startCountDownLabel.isHidden = true
            self.endCountDownLabel.isHidden = false
            
            self.timePassingView.set(startDate: calendarItem.alarm.startDate,
                                     endDate: calendarItem.alarm.endDate)
            
            self.startCountDownLabel.stopCountDown()
            self.endCountDownLabel.startCountDown()
        } else {
            self.startCountDownLabel.isHidden = false
            self.endCountDownLabel.isHidden = true

            self.endCountDownLabel.stopCountDown()
            self.startCountDownLabel.startCountDown()
        }
        
        self.eventTitleLabel.stringValue = calendarItem.title
        
        self.view.needsLayout = true
    }
}
