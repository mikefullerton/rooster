//
//  Asserts.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/8/21.
//

import Foundation

public func assertNotNil<T>(_ any: Any?) -> T? {
    assert(any != nil, "unexpected nil pointer: \(type(of: any))")
    return any as? T
}
