//
//  CalendarListCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class CalendarListCell : UITableViewCell {
    
    private var calendar: EventKitCalendar?
    
//    convenience init() {
//        self.init(style: .default, reuseIdentifier: CalendarListCell.reuseIdentifier)
//    }
//    
//    init(style: CellStyle, reuseIdentifier: String) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//    
//    required public init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//    
    override func prepareForReuse() {
        self.calendar = nil
    }
    
    func setCalendar(_ calendar: EventKitCalendar) {
        self.calendar = calendar
        
        if let text = self.calendar?.title {
            self.textLabel?.text = text
        }
    }
    
    

}
