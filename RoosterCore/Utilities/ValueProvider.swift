//
//  SchedulePreferencesProvider.swift
//  Rooster-iOS
//
//  Created by Mike Fullerton on 4/20/21.
//

import Foundation

public class ValueProvider<T> {
    public typealias Getter = () -> T
    public typealias Setter = (_ value: T) -> Void

    private let getter: Getter
    private let setter: Setter

    public init(getter: @escaping Getter,
                setter: @escaping Setter) {
        self.getter = getter
        self.setter = setter
    }

    public var value: T {
        get { self.getter() }
        set { self.setter(newValue) }
    }
}
