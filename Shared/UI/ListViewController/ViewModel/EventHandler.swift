//
//  EventHandler.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/10/21.
//

import Foundation

class EventHandler {
    
    typealias Handler = (_ content: Any, _ view: SDKView, _ event: Event?) -> Void
    
    var mouseDownHandler:Handler? = nil
    var mouseUpHandler:Handler? = nil
    var mouseOverHandler:Handler? = nil
}
