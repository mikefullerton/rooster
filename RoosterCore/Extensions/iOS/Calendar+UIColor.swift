//
//  Calendar+UIColor.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import Foundation
import UIKit

extension Calendar {
    var color: UIColor? {
        self.cgColor != nil ? UIColor(cgColor: self.cgColor!) : nil
    }
}
