//
//  ListViewRow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/24/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif


open class ListViewRowController<CONTENT_TYPE> : AbstractListViewRowController {
    public typealias contentType = CONTENT_TYPE
    
    open func viewWillAppear(withContent content: CONTENT_TYPE) {
        
    }
}
