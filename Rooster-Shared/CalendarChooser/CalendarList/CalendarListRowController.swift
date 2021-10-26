//
//  CalendarListCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public protocol CalendarListRowControllerDelegate: AnyObject {
    func calendarRowShouldPickColor(_ calendarRow: CalendarListRowController)
}

open class CalendarListRowController: ListViewRowController {
    public private(set) var scheduleItem: ScheduleCalendar?

    public weak var delegate: CalendarListRowControllerDelegate?

    private let padding: CGFloat = 8

    override open class func preferredSize(forContent content: Any?) -> CGSize {
        CGSize(width: -1, height: 28)
    }

    lazy var iconsStackView = SimpleStackView(direction: .horizontal,
                                              insets: SDKEdgeInsets.zero,
                                              spacing: SDKOffset(horizontal: 4.0, vertical: 0))

    private lazy var checkBox: SDKSwitch = {
        let view = SDKSwitch(title: "", target: self, action: #selector(checkBoxChecked(_:)))
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var calendarColorBar: SDKView = {
        let view = SDKView()

        self.view.addSubview(view)

        let width: CGFloat = 4
        let inset: CGFloat = 2

        view.sdkLayer.cornerRadius = width / 2.0

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: inset),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -inset),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.padding)
        ])

        return view
    }()

    func infoIconView(systemImageName imageName: String, toolTip: String) -> NSImageView {
        guard let image = NSImage(systemSymbolName: imageName, accessibilityDescription: toolTip),
              let symbol = image.withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .medium)) else {
            return NSImageView()
        }

        let tintedSymbol = symbol.tint(color: NSColor.secondaryLabelColor)

        let view = SizedImageView(image: tintedSymbol)
        view.toolTip = toolTip

        return view
    }

    lazy var remindersIcon: NSImageView = {
        self.infoIconView(systemImageName: "list.bullet", toolTip: "This calendar supports reminders")
    }()

    lazy var eventsIcon: NSImageView = {
        self.infoIconView(systemImageName: "calendar", toolTip: "This calendar supports events")
    }()

    lazy var readOnlyIcon: NSImageView = {
        self.infoIconView(systemImageName: "lock", toolTip: "This calendar is read only")
    }()

    lazy var colorPickerButton: Button = {
        let button = Button(systemSymbolName: "square.and.pencil",
                            accessibilityDescription: "calendar color",
                            symbolConfiguration: NSImage.SymbolConfiguration(scale: .medium),
                            target: self,
                            action: #selector(pickColor(_:)))
        return button
    }()

    @objc func pickColor(_ sender: Any) {
        self.delegate?.calendarRowShouldPickColor(self)
    }

    func addIconsStackView() {
        let view = self.iconsStackView
        view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(view)

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width),
            view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.padding)
        ])
    }

    func addRemindersIcon() {
        let view = self.remindersIcon
        view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(view)

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 24),
            view.heightAnchor.constraint(equalToConstant: 24),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])

        if self.eventsIcon.superview != nil {
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: self.eventsIcon.leadingAnchor, constant: -4)
            ])
        } else {
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.padding)
            ])
        }
    }

    func removeIconStack() {
        NSLayoutConstraint.deactivate(self.iconsStackView.constraints)
        self.iconsStackView.removeFromSuperview()
    }

    override open func prepareForReuse() {
        super.prepareForReuse()
        self.scheduleItem = nil
        self.removeIconStack()
    }

    func updateColors() {
        if  let scheduleItem = self.scheduleItem,
            let calendarColor = scheduleItem.calendar.color {
            self.calendarColorBar.sdkBackgroundColor = calendarColor
            self.colorPickerButton.contentTintColor = calendarColor

            self.calendarColorBar.isHidden = false
        } else {
            self.calendarColorBar.isHidden = true
        }
    }

    override open func willDisplay(withContent content: Any?) {
        guard let scheduleItem = content as? ScheduleCalendar else {
            return
        }

        self.scheduleItem = scheduleItem
        self.checkBox.title = scheduleItem.title
        self.checkBox.isOn = scheduleItem.isEnabled

        self.updateColors()

        self.removeIconStack()

        var icons: [SDKView] = []

        if scheduleItem.isReadOnly {
            icons.append(self.readOnlyIcon)
        }

        if scheduleItem.allowsEvents {
            icons.append(self.eventsIcon)
        }

        if scheduleItem.allowsReminders {
            icons.append(self.remindersIcon)
        }

        icons.append(self.colorPickerButton)

        self.checkBox.deactivatePositionalContraints()

        if !icons.isEmpty {
            self.iconsStackView.setContainedViews(icons)
            self.addIconsStackView()

            NSLayoutConstraint.activate([
                self.checkBox.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.padding),
                self.checkBox.trailingAnchor.constraint(equalTo: self.iconsStackView.leadingAnchor, constant: self.padding),
                self.checkBox.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
        } else {
            self.removeIconStack()

            NSLayoutConstraint.activate([
                self.checkBox.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.padding),
                self.checkBox.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: self.padding),
                self.checkBox.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
        }
    }

    @objc func checkBoxChecked(_ checkbox: SDKButton) {
        if var item = self.scheduleItem {
            item.isEnabled.toggle()

            CoreControllers.shared.scheduleController.update(calendar: item)
        }
    }
}
