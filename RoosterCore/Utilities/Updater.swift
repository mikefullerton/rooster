//
//  RapidSaver.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/25/21.
//

import Foundation

public class Updater<T: Any>: Loggable {
    
    private var updateCounter = 0
    
    public var representedObject: T?
    
    public init(representedObject: T? = nil) {
        self.representedObject = representedObject
    }
    
    private var incrementedCounter: Int {
        self.updateCounter += 1
        return self.updateCounter
    }
    
    public func update(afterMilliseconds updateDelayMilliseconds: Int,
                       callback: @escaping () -> Void) {
        
        self.logger.log("Started updating..")
        
        let updateCount = self.incrementedCounter
        
        let fireTime = DispatchTime.now() + .milliseconds(updateDelayMilliseconds)
        
        DispatchQueue.main.asyncAfter(deadline: fireTime) { [weak self] in
            if updateCount == self?.updateCounter {
                self?.logger.log("Actually saved")
                callback()
            } else {
                self?.logger.log("Ignored stale save")
            }
        }
    }
}
