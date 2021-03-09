//
//  ListViewController+Extensions.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/19/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

extension ListViewController {
    // MARK: - Selection Utils
    public func setSelectedRows(_ rows: [IndexPath],
                                scrollPosition: NSCollectionView.ScrollPosition = .centeredVertically) {
        let indexPaths = Set<IndexPath>(rows)

        self.deselectSelectedRows()
        self.collectionView.selectItems(at: indexPaths,
                                        scrollPosition: scrollPosition)
        self.collectionView(self.collectionView, didSelectItemsAt: indexPaths)
    }

    public func selectNextRow() {
        if let nextIndexPath = self.nextSelectedRowIndexPath {
            self.setSelectedRows([nextIndexPath])
        }
    }

    public func selectPreviousRow() {
        if let previousIndexPath = self.previousSelectedRowIndexPath {
            self.setSelectedRows([previousIndexPath])
        }
    }

    public var lowestSelectedPath: IndexPath? {
        let selectedIndexPaths = self.collectionView.selectionIndexPaths
        if !selectedIndexPaths.isEmpty {
            var lowest = IndexPath(item: Int.max, section: Int.max)

            selectedIndexPaths.forEach {
                if $0.section < lowest.section && $0.item < lowest.item {
                    lowest = $0
                }
            }

            return lowest
        }

        return nil
    }

    // FUTURE: this is poorly named
    public var highestSelectedPath: IndexPath? {
        let selectedIndexPaths = self.collectionView.selectionIndexPaths
        if !selectedIndexPaths.isEmpty {
            var highest = IndexPath(item: -1, section: -1)

            selectedIndexPaths.forEach {
                if $0.section > highest.section && $0.item > highest.item {
                    highest = $0
                }
            }

            return highest
        }

        return nil
    }

    // FUTURE: this is poorly named
    public var nextSelectedRowIndexPath: IndexPath? {
        if let highest = self.highestSelectedPath {
            var item = highest.item
            for section in highest.section...self.sectionCount {
                let numberOfItemsInSection = self.collectionView(self.collectionView, numberOfItemsInSection: section)
                if numberOfItemsInSection > 0 && numberOfItemsInSection > item + 1 {
                    return IndexPath(item: item + 1, section: section)
                }

                item = -1
            }
        }

        return nil
    }

    // FUTURE: this is poorly named
    public var previousSelectedRowIndexPath: IndexPath? {
        if let lowest = self.lowestSelectedPath {
            var item = lowest.item
            for section in (0...lowest.section).reversed() {
                let numberOfItemsInSection = self.collectionView(self.collectionView, numberOfItemsInSection: section)
                if item > 0 && item > numberOfItemsInSection - 1 {
                    return IndexPath(item: numberOfItemsInSection - 1, section: section)
                } else if item > 0 && item <= numberOfItemsInSection {
                    return IndexPath(item: item - 1, section: section)
                }

                item = Int.max
            }
        }

        return nil
    }

    public func deselectSelectedRows() {
        let indexPaths = Set<IndexPath>(self.collectionView.selectionIndexPaths)
        self.collectionView.deselectItems(at: indexPaths)
        self.collectionView(self.collectionView, didDeselectItemsAt: indexPaths)
    }
}

extension ListViewController {
    // MARK: - content related utilities

    public var rowCount: Int {
        self.viewModel?.rowCount ?? 0
    }

    public var sectionCount: Int {
        self.viewModel?.sectionCount ?? 0
    }

    private func minSize(for size: CGSize) -> CGSize {
        CGSize(width: max(size.width, 100), height: size.height)
    }

    public var viewModelContentSize: CGSize {
        self.viewModel?.size ?? CGSize.zero
    }
}

extension ListViewController {
    // MARK: - Scrolling Utils

    public func scrollToTop() {
        if let scrollView = self.scrollView {
            let contentInsets = scrollView.contentInsets
            scrollView.contentView.scroll(NSPoint(x: 0, y: -contentInsets.top))
            scrollView.reflectScrolledClipView(scrollView.contentView)
        }
    }
}
