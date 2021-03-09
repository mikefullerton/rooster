//
//  CalendarItemInfoBarView.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/19/21.
//

import Foundation
import Cocoa
import RoosterCore

public class CalendarItemInfoBar: SimpleStackView {

    public init() {
        super.init(direction: .horizontal,
                   insets: SDKEdgeInsets.zero,
                   spacing: SDKOffset.zero)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var recurringIcon: SizedImageView = {
        let config = NSImage.SymbolConfiguration(scale: .small)
        
        let image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", accessibilityDescription: "Recurring Event")?.withSymbolConfiguration(config)
        
        let tintedImage = image?.tint(color: Theme(for: self).secondaryLabelColor)
        
        let view = SizedImageView(image: tintedImage!)
        
        view.toolTip = "This is a recurring event"
        
        return view
    }()
    
    func update(withCalendarItem calendarItem: RCCalendarItem) {
    
        var views:[SDKView] = []
        
        if calendarItem.isRecurring {
            views.append(self.recurringIcon)
        }
        
        self.setContainedViews(views)
    }
    
//    public init() {
//        super.init(dir
//    }
}
