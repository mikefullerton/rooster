//
//  EventHandler.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/10/21.
//

import Foundation

open class EventHandler {
    public typealias Handler = (_ content: Any, _ view: SDKView, _ event: EventKitEvent?) -> Void

    public var mouseDownHandler: Handler?
    public var mouseUpHandler: Handler?
    public var mouseOverHandler: Handler?
}
