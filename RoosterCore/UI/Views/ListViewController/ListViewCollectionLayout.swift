//
//  ListViewCollectionLayout.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/19/21.
//

import Foundation
#if os(macOS)
import Cocoa
import AppKit
#else
import UIKit
#endif

open class ListViewCollectionLayout: NSCollectionViewFlowLayout, Loggable {
    override open func prepare(forAnimatedBoundsChange oldBounds: NSRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)

        self.logger.debug("prepare for new bounds, old bounds: \(String(describing: oldBounds))")
    }

    override open func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()

        self.logger.debug("Finalize bounds change, bounds: \(String(describing: self.collectionView?.bounds ?? CGRect.zero))")
    }

    override open func invalidateLayout() {
        super.invalidateLayout()
        self.logger.debug("invalidate layout")
    }

    override open func invalidateLayout(with context: NSCollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        self.logger.debug("invalidate layout with context")
    }
}
