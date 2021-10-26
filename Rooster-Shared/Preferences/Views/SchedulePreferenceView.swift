//
//  EventsPanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/23/21.
//

import Foundation
import RoosterCore

public class SchedulePreferenceView: SimpleStackView {
    var preferencesProvider: ValueProvider<SchedulePreferences>

    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    public private(set) var prefs: SchedulePreferences {
        get { self.preferencesProvider.value }
        set { self.preferencesProvider.value = newValue }
    }

    public init(preferencesProvider: ValueProvider<SchedulePreferences>) {
        self.preferencesProvider = preferencesProvider

        super.init(direction: .vertical,
                   insets: SDKEdgeInsets.zero,
                   spacing: SDKOffset.zero)

        #if REMINDERS
        self.setContainedViews( [
            self.createCalendarSection(),
            self.createEventsSection(),
            self.createUnscheduledRemindersSection()
        ])
        #else
        self.setContainedViews( [
            self.createCalendarSection(),
            self.createEventsSection()
        ])
        #endif

        self.preferencesUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else {
                return
            }

            self.refresh()
        }

        self.refresh()
    }

    func createUnscheduledRemindersSection() -> GroupBoxView {
        let boxView = GroupBoxView(title: "Reminders")

        boxView.setContainedViews([
            SinglePreferenceChoiceView(withTitle: "Show Unscheduled Reminders (no due date)",
                                       updater: { view in
                                            view.checkbox.isOn = self.prefs.showUnscheduledReminders
                                       },
                                       setter: { view in
                                            self.prefs.showUnscheduledReminders = view.checkbox.isOn
                                       })
        ])

        return boxView
    }

    private lazy var daysPopupMenu: PopupMenuPreferenceView = {
        var menuItems: [String] = []
        for i in 1...6 {
            let title = i > 1 ? "\(i) Days" : "\(i) Day"
            menuItems.append(title)
        }
        menuItems.append("1 Week")

        return PopupMenuPreferenceView(withTitle: "Number of days to show (experimental):",
                                       menuItems: menuItems,
                                       refresh: { prefView in
                                            prefView.selectedItemIndex = self.prefs.visibleDayCount - 1
                                       },
                                       update: { prefView in
                                            self.prefs.visibleDayCount = (prefView.selectedItemIndex ?? 0) + 1
                                       })
    }()

    func createCalendarSection() -> GroupBoxView {
        let boxView = GroupBoxView(title: "Calendar")
#if REMINDERS
        let prompt = "Show Calendar Name on Events and Reminders"
#else
        let prompt = "Show Calendar Name on Events"
#endif
        boxView.setContainedViews([
            SinglePreferenceChoiceView(withTitle: prompt,
                                       updater: { view in
                                            view.checkbox.isOn = self.prefs.displayOptions.contains(.showCalendarName)
                                       },
                                       setter: { view in
                                            self.prefs.displayOptions.set(.showCalendarName, to: view.checkbox.isOn)
                                       }),

            self.daysPopupMenu
        ])

        return boxView
    }

    func createEventsSection() -> GroupBoxView {
        let box = GroupBoxView(title: "Events")

        let showAllDayEvents = SinglePreferenceChoiceView(withTitle: "Show All Day Events",
                                                          updater: { view in
                                                                view.checkbox.isOn = self.prefs.showAllDayEvents
                                                          },
                                                          setter: { view in
                                                                self.prefs.showAllDayEvents = view.checkbox.isOn
                                                          })

        let scheduleAllDayEvents = SinglePreferenceChoiceView(withTitle: "Schedule All Day Events with Notifications",
                                                              updater: { view in
                                                                    view.isEnabled = self.prefs.showAllDayEvents
                                                                    view.checkbox.isOn = self.prefs.scheduleAllDayEvents
                                                              },
                                                              setter: { view in
                                                                    self.prefs.scheduleAllDayEvents = view.checkbox.isOn
                                                              })

        let declinedEvents = SinglePreferenceChoiceView(withTitle: "Show Declined Events",
                                                        updater: { view in
                                                            view.checkbox.isOn = self.prefs.showDeclinedEvents
                                                        },
                                                        setter: { view in
                                                            self.prefs.showDeclinedEvents = view.checkbox.isOn
                                                        })

        box.setContainedViews([
            showAllDayEvents,
            scheduleAllDayEvents,
            declinedEvents
        ])

        return box
    }

    public func refresh() {
    }
}
