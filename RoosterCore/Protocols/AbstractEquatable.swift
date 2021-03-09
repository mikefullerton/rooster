//
//  AbstractEquatable.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/12/21.
//

import Foundation

public protocol AbstractEquatable {
    func isEqual(to scheduleItem: AbstractEquatable) -> Bool
}
