//
//  DispatchQueue+Utilities.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/29/21.
//

import Foundation

extension DispatchQueue {
    public static let serial = DispatchQueue(label: "rooster.serial")

    public static let concurrent = DispatchQueue(label: "rooster.concurrent", attributes: .concurrent)
}
