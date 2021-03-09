//
//  EventHandler.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/10/21.
//

import Foundation

open class EventHandler {
    
    public typealias Handler = (_ content: Any, _ view: SDKView, _ event: RCEvent?) -> Void
    
    public var mouseDownHandler:Handler? = nil
    public var mouseUpHandler:Handler? = nil
    public var mouseOverHandler:Handler? = nil
}
