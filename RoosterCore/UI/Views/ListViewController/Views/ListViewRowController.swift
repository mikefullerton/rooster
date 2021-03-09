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

open class ListViewRowController: AbstractListViewRowController {
    open func willDisplay(withContent content: Any?) {
    }
}
