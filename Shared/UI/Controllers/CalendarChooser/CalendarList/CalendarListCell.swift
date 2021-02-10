//
//  CalendarListCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class CalendarListCell : ListViewRowView<Calendar> {
    
    private var calendar: Calendar?
//    var eventHandler: EventHandler<Calendar, CalendarListCell>?
    
    private let padding:CGFloat = 8
    
    override func loadView() {
        self.view = SDKView()
    }
    
    override class var preferredHeight: CGFloat {
        return 28
    }
    
    private lazy var checkBox: SDKSwitch = {
        let view = SDKSwitch(checkboxWithTitle: "", target: self, action: #selector(checkBoxChecked(_:)))
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.padding),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.calendar = nil
    }
    
    override func viewWillAppear(withContent calendar: Calendar) {
        self.calendar = calendar
        self.checkBox.title = calendar.title
        self.checkBox.intValue = calendar.isSubscribed ? 1 : 0
        
        if let calendarColor = calendar.color {
            self.calendarColorBar.sdkBackgroundColor = calendarColor
            self.calendarColorBar.isHidden = false
        } else {
            self.calendarColorBar.isHidden = true
        }
    }
    
    @objc func checkBoxChecked(_ checkbox: SDKButton) {
        if let calendar = self.calendar {
            calendar.set(subscribed: !calendar.isSubscribed)
        }
    }
    
    
}
