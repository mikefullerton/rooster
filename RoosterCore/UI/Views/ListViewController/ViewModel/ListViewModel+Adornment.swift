//
//  ListViewSectionAdornment.swift
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

open class ListViewAdornmentView: SDKView {
    open func adornmentWillAppear(withContent content: Any?) {
    }

    open class func preferredSize(forContent content: Any?) -> CGSize {
        ListViewModel.Adornment.defaultSize
    }
}

extension ListViewModel {
    open class Adornment {
        public static let defaultSize = CGSize(width: -1, height: 24)

        open var viewClass: SDKView.Type

        open var content: Any?

        public init() {
            self.viewClass = SectionHeaderView.self
            self.content = nil
        }

        public init(withContent content: Any?,
                    withViewClass viewClass: SDKView.Type) {
            self.viewClass = viewClass
            self.content = content
        }

        public init(withTitle title: String) {
            self.viewClass = SectionHeaderView.self
            self.content = title
        }

        open var preferredSize: CGSize {
            if let adornmentViewClass = self.viewClass as? ListViewAdornmentView.Type {
                return adornmentViewClass.preferredSize(forContent: self.content)
            }

            return Self.defaultSize
        }

        open var cellReuseIdentifer: String {
            "\(type(of: self))"
        }

        open func willDisplayAdornment(withView view: SDKView) {
            if let adornmentView = view as? ListViewAdornmentView {
                adornmentView.adornmentWillAppear(withContent: self.content)
            }
        }
    }
}
