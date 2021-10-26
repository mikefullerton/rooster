//
//  UnscheduledRemindersBanner.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/18/21.
//

import AppKit
import Foundation
import RoosterCore

public class UnscheduledRemindersBanner: AbstractBannerRow {
    public struct ContentType {
        let preferences: ValueProvider<SchedulePreferences>
        let calendarReference: CalendarReference?
    }

    lazy var disclosureButton: AnimateableButton = {
        let button = AnimateableButton()

        button.contentViews = [
            HighlightableImageView(image: NSImage.image(withSystemSymbolName: "arrowtriangle.down.fill", accessibilityDescription: "disclose")!),
            HighlightableImageView(image: NSImage.image(withSystemSymbolName: "arrowtriangle.right.fill", accessibilityDescription: "disclose")!)
        ]

        button.title = ""
        button.viewIndex = 0
        return button
    }()

    public lazy var priorityMenuButton: PopUpMenuButton = {
        let button = PopUpMenuButton(withTitle: "All")
        button.textField?.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize - 2)
        button.textField?.textColor = NSColor.secondaryLabelColor
        button.addLabel(title: "Minimum priority: ")

        button.label?.textColor = Theme(for: self).secondaryLabelColor
        button.label?.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize - 2)
        return button
    }()

    private lazy var priorityLabel: SDKTextField = {
        let label = HighlightableTextField()
        label.isEditable = false
        label.textColor = Theme(for: self).secondaryLabelColor
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize - 2)
        label.drawsBackground = false
        label.isBordered = false
        label.stringValue = "Min priority: "
        return label
    }()

    func addDisclosureButton() {
        let view = self.disclosureButton
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.addDisclosureButton()
        self.addPriorityButton()

        self.setBanner("Unscheduled Reminders")
    }

    func addPriorityButton() {
        let view = self.priorityMenuButton
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)

        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    func updatePriorityButton(withContent content: ContentType) {
        var itemIndex = -1
        switch content.preferences.value.remindersPriorityFilter {
        case .none:
            itemIndex = 0

        case .low:
            itemIndex = 1

        case .medium:
            itemIndex = 2

        case .high:
            itemIndex = 3
        }

        self.priorityMenuButton.removeFromSuperview()

        let button = self.priorityMenuButton
        button.menuItems = [
            MenuItem(title: "None") { _ in
                content.preferences.value.remindersPriorityFilter = .none
            },

            MenuItem(title: "!") { _ in
                content.preferences.value.remindersPriorityFilter = .low
            },

            MenuItem(title: "!!") { _ in
                content.preferences.value.remindersPriorityFilter = .medium
            },

            MenuItem(title: "!!!") { _ in
                content.preferences.value.remindersPriorityFilter = .high
            }
        ]
        button.menuItems[itemIndex].state = .on
        button.title = button.menuItems[itemIndex].title

        self.addPriorityButton()
    }

    func updateDisclosureButton(withContent content: ContentType) {
        self.disclosureButton.callback = { _ in
            content.preferences.value.remindersDisclosed.toggle()
        }
        self.disclosureButton.viewIndex = content.preferences.value.remindersDisclosed ? 0 : 1
    }

    override public func willDisplay(withContent content: Any?) {
        guard let content = content as? ContentType else {
            assertionFailure("didn't find correct content for UnscheduledRemindersBannerData")
            return
        }

        self.updateDisclosureButton(withContent: content)
        self.updatePriorityButton(withContent: content)

        if let calendarRef = content.calendarReference {
            self.setBanner("Reminders - \(calendarRef.calendar.title) (\(calendarRef.calendar.source.title))")
        } else {
            self.setBanner("Unscheduled Reminders")
        }
    }

    override public class func preferredSize(forContent content: Any?) -> CGSize {
        self.bannerSize(forBanner: "Unscheduled Reminders")
    }

    override public func updateContstraints() {
        self.headlineLabel.deactivatePositionalContraints()
        self.label.deactivatePositionalContraints()

        if self.headlineLabel.isHidden == false && self.label.isHidden == false {
            NSLayoutConstraint.activate([
                self.headlineLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                self.headlineLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -8),

                self.label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                self.label.topAnchor.constraint(equalTo: self.headlineLabel.bottomAnchor, constant: 0)
            ])
        } else if self.label.isHidden == false {
            self.label.activate(constraints: [Constraint(.afterSibling, siblingView: self.disclosureButton, constant: 10), Constraint(.centerY)])
        } else if self.headlineLabel.isHidden == false {
            self.headlineLabel.activateCenteredInSuperviewConstraints()
        }
    }
}
