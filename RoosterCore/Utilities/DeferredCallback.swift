//
//  Notifier.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/30/21.
//

import Foundation

public class DeferredCallback {
    private var callbackCounter: Int
    private let queue: DispatchQueue

    public init(withQueue queue: DispatchQueue = DispatchQueue.main) {
        self.callbackCounter = 0
        self.queue = queue
    }

    public func schedule(callback: @escaping () -> Void) {
        self.callbackCounter += 1
        let counter = self.callbackCounter

        self.queue.async { [weak self] in
            guard let self = self else { return }
            if self.callbackCounter == counter {
                callback()
            }
        }
    }
}
