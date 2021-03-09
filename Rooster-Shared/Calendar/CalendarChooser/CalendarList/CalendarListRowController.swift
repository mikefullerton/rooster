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

class CalendarListRowController : ListViewRowController<RCCalendar> {
    
    private var calendar: RCCalendar?
    private let padding:CGFloat = 8
    
    
    override class var preferredHeight: CGFloat {
        return 28
    }
    
    private lazy var checkBox: SDKSwitch = {
        let view = SDKSwitch(checkboxWithTitle: "", target: self, action: #selector(checkBoxChecked(_:)))
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.padding),
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: view.intrinsicContentSize.width),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        return view
    }()
    
    lazy var calendarColorBar: SDKView = {
        let view = SDKView()
        
        self.view.addSubview(view)
      
        let width: CGFloat = 4
        let inset: CGFloat = 2
        
        view.sdkLayer.cornerRadius = width / 2.0;
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: inset),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -inset),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.padding),
        ])
        
        return view
    }()
    
    func infoIconView(systemImageName imageName: String, toolTip: String) -> NSImageView {
        var image = NSImage(systemSymbolName: imageName, accessibilityDescription: toolTip)
        
        image = image?.withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .medium))
        image = image?.tint(color: NSColor.secondaryLabelColor)
        
        let view = SizedImageView(image: image!)
        view.toolTip = toolTip

        return view
    }
    
    lazy var remindersIcon: NSImageView = {
        return self.infoIconView(systemImageName: "list.bullet", toolTip: "This calendar supports reminders")
    }()

    lazy var eventsIcon: NSImageView = {
        return self.infoIconView(systemImageName: "calendar", toolTip: "This calendar supports events")
    }()
    
    lazy var readOnlyIcon: NSImageView = {
        return self.infoIconView(systemImageName: "lock", toolTip: "This calendar is read only")
    }()
    
    lazy var iconsStackView = SimpleStackView(direction: .horizontal,
                                              insets: SDKEdgeInsets.zero,
                                              spacing: SDKOffset.init(horizontal: 4.0, vertical: 0))
   
    
    
    func addIconsStackView() {
        
        let view = self.iconsStackView
        view.translatesAutoresizingMaskIntoConstraints = false
       
        self.view.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width),
            view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.padding),
        ])
    }
    
    func addRemindersIcon() {
        let view = self.remindersIcon
        view.translatesAutoresizingMaskIntoConstraints = false
       
        self.view.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 24),
            view.heightAnchor.constraint(equalToConstant: 24),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        if self.eventsIcon.superview != nil {
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: self.eventsIcon.leadingAnchor, constant: -4),
            ])
        } else {
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.padding),
            ])
        }
        
    }
    
    func removeIconStack() {
        NSLayoutConstraint.deactivate(self.iconsStackView.constraints)
        self.iconsStackView.removeFromSuperview()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.calendar = nil
        self.removeIconStack()
    }
    
    override func viewWillAppear(withContent calendar: RCCalendar) {
        self.calendar = calendar
        self.checkBox.title = calendar.title
        self.checkBox.intValue = calendar.isSubscribed ? 1 : 0
        
        if let calendarColor = calendar.color {
            self.calendarColorBar.sdkBackgroundColor = calendarColor
            self.calendarColorBar.isHidden = false
        } else {
            self.calendarColorBar.isHidden = true
        }
        
        self.removeIconStack()
        
        var icons: [NSImageView] = []
        if calendar.isReadOnly {
            icons.append(self.readOnlyIcon)
        }
        
        if calendar.allowsEvents {
            icons.append(self.eventsIcon)
        }
        
        if calendar.allowsReminders {
            icons.append(self.remindersIcon)
        }
        
        if icons.count > 0 {
            self.iconsStackView.setContainedViews(icons)
            self.addIconsStackView()
        }
        
        
    }
    
    @objc func checkBoxChecked(_ checkbox: SDKButton) {
        if let calendar = self.calendar {
            calendar.set(subscribed: !calendar.isSubscribed)
        }
    }

    
}
