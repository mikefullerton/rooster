//
//  CalendarItemListViewCellContent.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/26/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

extension CalendarItemListViewCell {
    // CalendarItemListViewCell got way too huge.
    // This encapsulates creation and ownership of the views, as well as the positioning (constraints)

    public class ContentViews {
       let contentInsets = SDKEdgeInsets(top: 14, left: 14, bottom: 14, right: 10)

       private static var placeholderView = SDKView()

       public weak var owner: CalendarItemListViewCell?

       private var view: SDKView {
           self.owner?.view ?? Self.placeholderView
       }

       public init() {
       }

       public func addViews() {
            // left
            self.addCalendarColorBar()

            self.addNotAcceptedOverlay()

            self.addLeadingActionButtons()
            self.addEventTitleLabel()

            self.addStartTimeLabel()
            self.addInfoBar()
            self.addEndTimeLabel()

            self.addStartCountDownLabel()
            self.addEndCountDownLabel()

            self.addItemTypeLabel()

            // right
            self.addActionButtons()

            self.addTimePassingView()

            self.addPastDueOverlay()
        }

        // MARK: Views

        lazy var dividerView = DividerView()

        lazy var infoBar = SimpleStackView(direction: .horizontal,
                                           insets: SDKEdgeInsets.zero,
                                           spacing: SDKOffset.zero)

        lazy var timePassingView = TimePassingView()

        lazy var actionButtons = SimpleStackView(direction: .horizontal,
                                                 insets: SDKEdgeInsets.ten,
                                                 spacing: SDKOffset.ten)

        lazy var leadingActionButtons = SimpleStackView(direction: .horizontal,
                                                        insets: SDKEdgeInsets.zero,
                                                        spacing: SDKOffset(horizontal: 4, vertical: 0))

        lazy var calendarColorBar = VerticalColorBar(insets: SDKEdgeInsets.zero,
                                                     barWidth: 8,
                                                     roundedCorners: false)

        lazy var startCountDownLabel: CountDownTextField = {
            let label = CountDownTextField()
            label.countDownDelegate = self.owner
            label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
            label.alignment = .right
            label.textColor = Theme(for: self.view).secondaryLabelColor

            return label
        }()

        lazy var endCountDownLabel: CountDownTextField = {
            let label = CountDownTextField()
            label.countDownDelegate = self.owner
            label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
            label.alignment = .right
            label.textColor = Theme(for: self.view).secondaryLabelColor

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

        lazy var itemTypeLabel: SDKTextField = {
            let label = SDKTextField()

            label.textColor = Theme(for: self.view).tertiaryLabelColor
            label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize - 1)
            label.isEditable = false
            label.isBordered = false
            label.drawsBackground = false

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
            self.createTimeLabel()
        }()

        lazy var endTimeLabel: SDKTextField = {
            self.createTimeLabel()
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

        lazy var allDayTextField: SDKTextField = {
            let label = SDKTextField()
            label.textColor = Theme(for: self.view).secondaryLabelColor
            label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
            label.isEditable = false
            label.isBordered = false
            label.drawsBackground = false
            label.stringValue = "All Day"
            return label
        }()

        lazy var notAcceptedOverlay: SDKView = {
            var image = NSImage(named: "transparent_stripes")!
            image = image.tint(color: NSColor.systemGray)
            let view = TileImageView(withImage: image)
            view.alphaValue = 0.1
            view.isHidden = true

            return view
        }()

        lazy var pastDueOverlay: SDKView = {
            var image = NSImage(named: "transparent_stripes")!
            image = image.tint(color: NSColor.red)
            let view = TileImageView(withImage: image)
            view.alphaValue = 0.1
            view.isHidden = true
            return view
        }()

//        lazy var calendarIcon: SDKImageButton = {
//            let view = SDKImageButton(systemImageName: "calendar",
//                                      target: self.owner,
//                                      action: #selector(handleCalendarButtonClicked(_:)),
//                                      toolTip: "Open in Calendar.app")
//
//            return view
//
//        }()
//

        // MARK: - Action Buttons

        lazy var locationButton: SDKButton = {
            let view = SDKButton(systemSymbolName: "mappin.and.ellipse",
                                 accessibilityDescription: "Meeting Location URL",
                                 target: self.owner,
                                 action: #selector(handleLocationButtonClick(_:)))

            view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            return view
        }()

        lazy var symbolConfig = NSImage.SymbolConfiguration(scale: .large)

        lazy var enabledAlarmImage: SDKImage = {
            let image = SDKImage(systemSymbolName: "bell",
                                 accessibilityDescription: "mute alarm")?.withSymbolConfiguration(self.symbolConfig)
            return image!
        }()

        lazy var disabledAlarmImage: SDKImage = {
            let image = SDKImage(systemSymbolName: "bell.slash",
                                 accessibilityDescription: "mute alarm")?.withSymbolConfiguration(self.symbolConfig)
            return image!
        }()

        lazy var alarmIcon: SDKButton = {
            let view = SDKButton(image: self.enabledAlarmImage,
                                 target: self.owner,
                                 action: #selector(handleAlarmButtonClicked(_:)))

            view.toolTip = "ScheduleItemAlarm Enabled"

            view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

            return view
        }()

        lazy var alarmAnimation = SwayAnimation(withView: self.alarmIcon)

        public lazy var recurringIcon: SizedImageView = {
            let config = NSImage.SymbolConfiguration(scale: .small)

            let image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath",
                                accessibilityDescription: "Recurring Event")?.withSymbolConfiguration(config)

            let tintedImage = image?.tint(color: Theme(for: self).secondaryLabelColor)

            let view = SizedImageView(image: tintedImage!)

            view.toolTip = "This is a recurring event"

            return view
        }()

        // MARK: - adding

        func addNotAcceptedOverlay() {
            let view = self.notAcceptedOverlay
            self.view.addSubview(view)
            view.activateFillInParentConstraints()
        }

        func addPastDueOverlay() {
            let view = self.pastDueOverlay
            self.view.addSubview(view)
            view.activateFillInParentConstraints()
        }

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
            let inset = CGPoint(x: 4, y: 4)

            let view = self.itemTypeLabel

            self.view.addSubview(view)

            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
                view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: inset.y)
            ])
        }

        func addTimePassingView() {
            let view = self.timePassingView

            self.view.addSubview(view, positioned: .above, relativeTo: self.calendarColorBar)

            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                view.topAnchor.constraint(equalTo: self.view.topAnchor),
                view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)

        //            view.topAnchor.constraint(equalTo: self.startTimeLabel.centerYAnchor),
        //            view.bottomAnchor.constraint(equalTo: self.endTimeLabel.centerYAnchor)
            ])
        }

        func addActionButtons() {
            let view = self.actionButtons

            self.view.addSubview(view)

            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.contentInsets.right),
                view.centerYAnchor.constraint(equalTo: self.eventTitleLabel.centerYAnchor)
            ])

            view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }

        func addCalendarColorBar() {
            let view = self.calendarColorBar

            self.view.addSubview(view)

            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                view.topAnchor.constraint(equalTo: self.view.topAnchor),
                view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
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
                dividerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])

            self.dividerView = dividerView
        }

        static var timeInset: CGFloat {
            6.0
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
                view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.contentInsets.top)
            ])
        }

        func addLeadingActionButtons() {
            let view = self.leadingActionButtons
            self.view.addSubview(view)

            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
                view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
        }

        func addEventTitleLabel() {
            let view = self.eventTitleLabel

            self.view.addSubview(view)

            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.leadingActionButtons.trailingAnchor, constant: 4),
                view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
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

        func addAllDayTextField(withDateRange dateRange: DateRange) {
            let view = self.allDayTextField
            self.view.addSubview(view)

            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.contentInsets.right),
                view.lastBaselineAnchor.constraint(equalTo: self.eventTitleLabel.lastBaselineAnchor)
            ])
        }
    }
}
