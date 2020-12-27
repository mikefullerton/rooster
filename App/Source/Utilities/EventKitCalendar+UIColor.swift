//
//  EventKitCalendar+UIColor.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import Foundation
import UIKit

extension EventKitCalendar {
    
    var color: UIColor? {
        return self.cgColor != nil ? UIColor(cgColor: self.cgColor!) : nil
    }
}
