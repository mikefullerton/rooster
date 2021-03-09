//
//  CalendarItemListViewCell+MenuBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import RoosterCore
import Cocoa

extension CalendarItemListViewCell {
    func updateForMenuBar() {
        self.view.sdkLayer.cornerRadius = 0.0
        self.view.sdkLayer.backgroundColor = NSColor.clear.cgColor
        
        self.isHighlightable = true
    }
    
    func menuItemWasSelected() {
        if var calendarItem = self.calendarItem,
           calendarItem.alarm.isFiring {
            calendarItem.stopAlarmButtonClicked()
        } else {
            NSApp.activate(ignoringOtherApps: true)
            
            AppDelegate.instance.mainWindowController?.showWindow(self)
            
        }
    }
    
}
