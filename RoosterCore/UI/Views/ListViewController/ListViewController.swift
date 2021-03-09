//
//  ListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class ListViewController: SDKViewController,
                               NSCollectionViewDelegateFlowLayout,
                               NSCollectionViewDataSource,
                               NSCollectionViewDelegate,
                               Loggable {
    public var sizeBehavior: SizeBehavior = .default

    open var minimumPreferredContentSize: CGSize? {
        nil
    }

    public private(set) var viewModel: ListViewModel? {
        didSet {
            self.updatePreferredContentSizeIfNeeded()
        }
    }

    // swiftlint:disable unavailable_function
    // For subclasses to override and return the ViewModel
    open func provideDataModel() -> ListViewModel? {
        fatalError("This is a required override")
    }
    // swiftlint:enable unavailable_function

    // Call this to reload the dataModel. This calls provideDataModel.
    open func reloadData() {
        self.viewModel = self.provideDataModel()
        self.collectionView.reloadData()
        self.logger.debug("""
            Did reload: Sections: \(self.sectionCount), \
            Rows: \(self.rowCount), \
            Content size: \(String(describing: self.viewModelContentSize))
            """)
    }

    open func updatePreferredContentSizeIfNeeded() {
        guard let viewModel = self.viewModel else {
            return
        }

        var size = self.preferredContentSize
        let viewModelSize = viewModel.size

        if self.sizeBehavior.contains(.modelSetsPreferredContentHeight) {
            size.height = viewModelSize.height

            assert(size.height != 0, "height is zero")
            assert(size.height != NSView.noIntrinsicMetric, "no height set in model")
        }

        if self.sizeBehavior.contains(.modelSetsPreferredContentWidth) {
            size.width = viewModelSize.width

            assert(size.width != 0, "width is zero")
            assert(size.width != NSView.noIntrinsicMetric, "no width set in model")
        }

        if size != self.preferredContentSize {
            self.preferredContentSize = size
        }
    }

    // MARK: - properties

    open func createCollectionViewLayout() -> NSCollectionViewFlowLayout {
        let layout = ListViewCollectionLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionFootersPinToVisibleBounds = true
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = NSEdgeInsets.zero
        return layout
    }

    open func createScrollView() -> NSScrollView? {
        NSScrollView()
    }

    open func createCollectionView() -> NSCollectionView {
        NSCollectionView()
    }

    public lazy var collectionViewLayout: NSCollectionViewLayout = {
        self.createCollectionViewLayout()
    }()

    public lazy var collectionView: NSCollectionView = {
        self.createCollectionView()
    }()

    public lazy var scrollView: NSScrollView? = {
        if let scrollView = self.createScrollView() {
            scrollView.drawsBackground = false
            scrollView.contentView.drawsBackground = false
            scrollView.automaticallyAdjustsContentInsets = true
            scrollView.autohidesScrollers = true
            scrollView.rulersVisible = false
            return scrollView
        }
        return nil
    }()

    // MARK: - NSViewController overrides

    override open var preferredContentSize: CGSize {
        get {
            super.preferredContentSize
        }
        set(size) {
            var size = size
            if let minSize = self.minimumPreferredContentSize {
                if minSize.width != NSView.noIntrinsicMetric {
                    size.width = max(size.width, minSize.width)
                }
                if minSize.height != NSView.noIntrinsicMetric {
                    size.height = max(size.height, minSize.height)
                }
            }
            super.preferredContentSize = size
            self.logger.debug("Set preferred content size: \(String(describing: size))")
        }
    }

    override open func loadView() {
        let collectionView = self.collectionView
        collectionView.collectionViewLayout = self.collectionViewLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isSelectable = false
        collectionView.allowsMultipleSelection = false
        collectionView.allowsEmptySelection = false
        collectionView.backgroundColors = [ .clear ]

        if let scrollView = self.scrollView {
            scrollView.documentView = collectionView
            self.view = scrollView
        } else {
            self.view = collectionView
        }

//        self.view.sdkLayer.backgroundColor = NSColor.clear.cgColor
    }

    override open func viewWillAppear() {
        self.reloadData()
        super.viewWillAppear()
//        #if DEBUG
//        self.startTrackFrameChangeEvents()
//        #endif
    }

    override open func viewDidAppear() {
        super.viewDidAppear()
        self.scrollToTop()

        // not sure why this is needed??
        self.collectionView.collectionViewLayout?.invalidateLayout()
    }

    override open func viewDidDisappear() {
        super.viewWillDisappear()
        self.viewModel = nil
        self.collectionView.reloadData()

        self.collectionView.postsFrameChangedNotifications = false
    }

    // MARK: - NSCollectionView Delegate

    open func collectionView(_ collectionView: NSCollectionView,
                             willDisplay item: NSCollectionViewItem,
                             forRepresentedObjectAt indexPath: IndexPath) {
        guard let viewModel = self.viewModel,
        let row = viewModel.row(forIndexPath: indexPath) else {
            self.logger.error("Failed to find item at indexPath \(indexPath) from viewModel for updating display")
            return
        }

        row.willDisplayRow(withCollectionViewItem: item)
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             willDisplaySupplementaryView view: SDKView,
                             forElementKind elementKind: NSCollectionView.SupplementaryElementKind,
                             at indexPath: IndexPath) {
        if elementKind == NSCollectionView.elementKindSectionHeader,
        let viewModel = self.viewModel,
        let header = viewModel.header(forSection: indexPath.section) {
            header.willDisplayAdornment(withView: view)
        }

        if elementKind == NSCollectionView.elementKindSectionFooter,
        let viewModel = self.viewModel,
        let footer = viewModel.footer(forSection: indexPath.section) {
            footer.willDisplayAdornment(withView: view)
        }
    }

    // NOTE: these empty methods are here for subclasses to override

    open func collectionView(_ collectionView: NSCollectionView,
                             didSelectItemsAt indexPaths: Set<IndexPath>) {
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             didDeselectItemsAt indexPaths: Set<IndexPath>) {
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        indexPaths
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        indexPaths
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             didEndDisplaying item: NSCollectionViewItem,
                             forRepresentedObjectAt indexPath: IndexPath) {
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             didEndDisplayingSupplementaryView view: NSView,
                             forElementOfKind elementKind: NSCollectionView.SupplementaryElementKind,
                             at indexPath: IndexPath) {
    }

    // MARK: - NSCollectionViewDataSource

    open func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel,
        let tableSection = viewModel.section(forIndex: section) else {
            self.logger.error("Section \(section) not found, return 0 items count")
            return 0
        }

        let count = tableSection.rowCount
        self.logger.debug("Reloading \(count) rows, in section: \(section)")
        return count
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let viewModel = self.viewModel,
        let row = viewModel.row(forIndexPath: indexPath) else {
            self.logger.error("Row at indexPath not found \(indexPath) not found, return 0 items count")
            return NSCollectionViewItem()
        }
        let identifier = NSUserInterfaceItemIdentifier(rawValue: row.cellReuseIdentifer)
        self.collectionView.register(row.rowControllerClass, forItemWithIdentifier: identifier)

        let item = self.collectionView.makeItem(withIdentifier: identifier, for: indexPath)
        item.highlightState = .none
        return item
    }

    open func numberOfSections(in collectionView: NSCollectionView) -> Int {
        let count = self.sectionCount
        self.logger.debug("Reloading \(count) sections, total rowCount: \(self.rowCount)")
        return count
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
                             at indexPath: IndexPath) -> SDKView {
        if kind == NSCollectionView.elementKindSectionHeader,
        let viewModel = self.viewModel,
        let header = viewModel.header(forSection: indexPath.section) {
            let identifier = NSUserInterfaceItemIdentifier(header.cellReuseIdentifer)

            self.collectionView.register(header.viewClass,
                                         forSupplementaryViewOfKind: kind,
                                         withIdentifier: identifier)

            return self.collectionView.makeSupplementaryView(ofKind: kind,
                                                             withIdentifier: identifier,
                                                             for: indexPath)
        }

        if kind == NSCollectionView.elementKindSectionFooter,
        let viewModel = self.viewModel,
        let footer = viewModel.footer(forSection: indexPath.section) {
            let identifier = NSUserInterfaceItemIdentifier(footer.cellReuseIdentifer)

            self.collectionView.register(footer.viewClass,
                                         forSupplementaryViewOfKind: kind,
                                         withIdentifier: identifier)

            return self.collectionView.makeSupplementaryView(ofKind: kind,
                                                             withIdentifier: identifier,
                                                             for: indexPath)
        }

        self.logger.error("Supplemental item at indexPath: \(indexPath) not found")

        return SDKView()
    }

    // MARK: - NSCollectionViewFlowLayout Layout delegate

    private func sizeForItem(_ item: ListViewModelItem) -> CGSize {
        guard let viewModel = self.viewModel else {
            assertionFailure("model is nil")
            self.logger.error("View model is nil!")
            return CGSize.zero
        }

        var size = viewModel.size(forItem: item)

        if size.width == NSView.noIntrinsicMetric && self.sizeBehavior.contains(.usePreferredContentWidth) {
            size.width = self.preferredContentSize.width
        }

        assert(size.width != 0, "width is zero")
        assert(size.height != 0, "height is zero")
        assert(size.width != NSView.noIntrinsicMetric, "no width set in model")
        assert(size.height != NSView.noIntrinsicMetric, "no height set in model")
        return size
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             layout collectionViewLayout: NSCollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> NSSize {
        guard let viewModel = self.viewModel,
              let row = viewModel.row(forIndexPath: indexPath) else {
            self.logger.error("Returning zero for size of item at indexPath: \(indexPath)")

            return CGSize.zero
        }

        return self.sizeForItem(row)
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             layout collectionViewLayout: NSCollectionViewLayout,
                             insetForSectionAt section: Int) -> SDKEdgeInsets {
        guard let viewModel = self.viewModel,
        let tableSection = viewModel.section(forIndex: section) else {
            return SDKEdgeInsets.zero
        }

        return tableSection.layout.insets
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             layout collectionViewLayout: NSCollectionViewLayout,
                             minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard let viewModel = self.viewModel,
        let tableSection = viewModel.section(forIndex: section) else {
            return 0
        }

        return tableSection.layout.rowSpacing
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             layout collectionViewLayout: NSCollectionViewLayout,
                             minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // since we are one cell per row this won't do anything
        return 0
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             layout collectionViewLayout: NSCollectionViewLayout,
                             referenceSizeForHeaderInSection section: Int) -> NSSize {
        guard let viewModel = self.viewModel,
              let header = viewModel.header(forSection: section) else {
            return NSSize.zero
        }

        return self.sizeForItem(header)
    }

    open func collectionView(_ collectionView: NSCollectionView,
                             layout collectionViewLayout: NSCollectionViewLayout,
                             referenceSizeForFooterInSection section: Int) -> NSSize {
        guard let viewModel = self.viewModel,
              let footer = viewModel.footer(forSection: section) else {
            return NSSize.zero
        }

        return self.sizeForItem(footer)
    }
}

//    public func startTrackFrameChangeEvents() {
//        self.collectionView.postsFrameChangedNotifications = true
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(frameDidChange(_:)),
//                                               name: NSView.frameDidChangeNotification,
//                                               object: self.collectionView)
//
//        self.scrollView.postsFrameChangedNotifications = true
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(frameDidChange(_:)),
//                                               name: NSView.frameDidChangeNotification,
//                                               object: self.scrollView)
//    }
//
//    @objc func frameDidChange(_ notification: Notification) {
//        if  let sendingView = notification.object as? NSCollectionView,
//            sendingView == self.collectionView {
//            self.logger.debug("Collection view frame did change \(String(describing: self.collectionView.frame))")
//        } else if   let sendingView = notification.object as? NSScrollView,
//                    sendingView == self.scrollView {
//            self.logger.debug("Scroll view Frame did change \(String(describing: self.scrollView.frame))")
//        }
//    }

extension ListViewController {
    public struct SizeBehavior: DescribeableOptionSet {
        public typealias RawValue = Int

        public private(set) var rawValue: Int

        public static var zero                                              = SizeBehavior([])
        public static var modelSetsPreferredContentWidth                    = SizeBehavior(rawValue: 1 << 1)
        public static var modelSetsPreferredContentHeight                   = SizeBehavior(rawValue: 1 << 2)
        public static var usePreferredContentWidth                          = SizeBehavior(rawValue: 1 << 3)

        public static var modelSetsPreferredContentSize: SizeBehavior       = [ .modelSetsPreferredContentWidth, .modelSetsPreferredContentHeight ]
        public static var `default`: SizeBehavior                           = [ .usePreferredContentWidth, .modelSetsPreferredContentHeight ]

        public static var descriptions: [(Self, String)] = [
            (.modelSetsPreferredContentWidth, "modelSetsPreferredContentWidth"),
            (.modelSetsPreferredContentHeight, "modelSetsPreferredContentHeight"),
            (.usePreferredContentWidth, "usePreferredContentWidth")
        ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
