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
    open class Adornment: ListViewSectionItem {
        public static let defaultSize = CGSize(width: NSView.noIntrinsicMetric, height: 24)

        public weak var section: Section?

        public var model: ListViewModel? {
            self.section?.model
        }

        open var viewClass: SDKView.Type {
            SectionHeaderView.self
        }

        open var contentView: SDKView?

        public init(withTitle title: String) {
            let textView = Self.createTitleView()
            textView.stringValue = title
            self.contentView = textView
        }

        public init(withCustomView customView: SDKView) {
            self.contentView = customView
        }

        open var size: CGSize {
            var size = Adornment.defaultSize

            if let view = self.contentView {
                size = view.intrinsicContentSize

                size.height += 10
            }
            return size
        }

        open var cellReuseIdentifer: String {
            "\(type(of: self))"
        }

        open func willDisplayAdornment(withView view: SDKView) {
            if let headerView = view as? SectionHeaderView {
                headerView.set(contentView: self.contentView)
            }
        }

        public class func createTitleView() -> SDKTextField {
            let titleView = SDKTextField()
            titleView.isEditable = false
            titleView.textColor = Theme(for: self).secondaryLabelColor
            titleView.alignment = .left
            titleView.font = SDKFont.boldSystemFont(ofSize: SDKFont.systemFontSize)
            titleView.drawsBackground = false
            titleView.isBordered = false
            return titleView
        }
    }
}
