//
//  ListViewRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

extension ListViewModel {
    open class Row {
        public let content: Any?

        open var rowControllerClass: AbstractListViewRowController.Type

        open var preferredSize: CGSize {
            self.rowControllerClass.preferredSize(forContent: self.content)
        }

        open func willDisplayRow(withCollectionViewItem collectionViewItem: SDKCollectionViewItem) {
            if let rowController = collectionViewItem as? ListViewRowController {
                rowController.willDisplay(withContent: self.content)
            }
        }

        public init(withContent content: Any?,
                    rowControllerClass: AbstractListViewRowController.Type ) {
            self.content = content
            self.rowControllerClass = rowControllerClass
        }

        public var cellReuseIdentifer: String {
            "\(type(of: self)).\(self.rowControllerClass)"
        }
    }
}
