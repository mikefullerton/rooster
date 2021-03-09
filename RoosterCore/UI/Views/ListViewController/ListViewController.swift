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

open class LoggableCollectionViewFlowLayout : NSCollectionViewFlowLayout, Loggable {
    
    open override func prepare(forAnimatedBoundsChange oldBounds: NSRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        
        self.logger.log("prepare for new bounds, old bounds: \(NSStringFromRect(oldBounds))")
    }
    
    open override func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        
        self.logger.log("Finalize bounds change, bounds: \(NSStringFromRect(self.collectionView?.bounds ?? CGRect.zero))")
    }
    
    open override func invalidateLayout() {
        super.invalidateLayout()
        self.logger.log("invalidate layout")
    }

    open override func invalidateLayout(with context: NSCollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        self.logger.log("invalidate layout with context")
    }

}

open class ListViewController<ViewModel: ListViewModelProtocol> :   SDKViewController,
                                                                    NSCollectionViewDataSource,
                                                                    NSCollectionViewDelegate,
                                                                    NSCollectionViewDelegateFlowLayout,
                                                                    MouseTrackingCollectionViewDelegate,
                                                                    Reloadable,
                                                                    Loggable {
       
    public private(set) var viewModel: ViewModel?
    
    // For subclasses to override and return the ViewModel
    open func provideDataModel() -> ViewModel? {
        fatalError("This is a required override")
    }
    
    // Call this to reload the dataModel. This calls provideDataModel.
    open func reloadData() {
        self.viewModel = self.provideDataModel()
        self.collectionView.reloadData()
        self.logger.log("Did reload: Sections: \(self.sectionCount), Rows: \(self.rowCount), Content size: \(NSStringFromSize(self.viewModelContentSize))")
    }
    
    // in case subclass wants to change layout
  
    // MARK: -
    // MARK: View creation for subclass overrides

    open func createCollectionViewLayout() -> NSCollectionViewFlowLayout {
        let layout = LoggableCollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionFootersPinToVisibleBounds = true
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = NSEdgeInsets.zero
        return layout
    }
    
    open func createScrollView() -> NSScrollView {
        return NSScrollView()
    }

    open func createCollectionView() -> MouseTrackingCollectionView {
        return MouseTrackingCollectionView()
    }

    public func startTrackFrameChangeEvents() {
        self.collectionView.postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(frameDidChange(_:)),
                                               name: NSView.frameDidChangeNotification,
                                               object:self.collectionView)

        self.scrollView.postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(frameDidChange(_:)),
                                               name: NSView.frameDidChangeNotification,
                                               object:self.scrollView)

    }
    
    @objc func frameDidChange(_ notification: Notification) {
        
        if  let sendingView = notification.object as? NSCollectionView,
            sendingView == self.collectionView {
            
            self.logger.log("Collection view frame did change \(NSStringFromRect(self.collectionView.frame))")
        
        } else if   let sendingView = notification.object as? NSScrollView,
                    sendingView == self.scrollView {
            
            self.logger.log("Scroll view Frame did change \(NSStringFromRect(self.scrollView.frame))")
        }
    }

    public var lowestSelectedPath: IndexPath? {
        let selectedIndexPaths = self.collectionView.selectionIndexPaths
        if selectedIndexPaths.count > 0 {
            var lowest = IndexPath(item: Int.max, section: Int.max)
         
            selectedIndexPaths.forEach() {
                if $0.section < lowest.section && $0.item < lowest.item {
                    lowest = $0
                }
            }
            
            return lowest
        }
        
        return nil
    }
    
    // TODO: this is poorly named
    public var highestSelectedPath: IndexPath? {
        let selectedIndexPaths = self.collectionView.selectionIndexPaths
        if selectedIndexPaths.count > 0 {
            var highest = IndexPath(item: -1, section: -1)
         
            selectedIndexPaths.forEach() {
                if $0.section > highest.section && $0.item > highest.item {
                    highest = $0
                }
            }
            
            return highest
        }
        
        return nil
    }
    
    // TODO: this is poorly named
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
    
    // TODO: this is poorly named
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
    
    public func setSelectedRows(_ rows: [IndexPath], scrollPosition: NSCollectionView.ScrollPosition = .centeredVertically) {
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

    // MARK: -
    // MARK: view properties
    
    public lazy var collectionView: MouseTrackingCollectionView = {
        let collectionView = self.createCollectionView()
        
        let layout = self.createCollectionViewLayout()
        
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.mouseTrackingDelegate = self
        
        collectionView.isSelectable = false
        collectionView.allowsMultipleSelection = false
        collectionView.allowsEmptySelection = false
        return collectionView
    }()

    public lazy var scrollView : NSScrollView = {
        let view = self.createScrollView()
        view.automaticallyAdjustsContentInsets = false
        return view
    }()

    // MARK: -
    // MARK: NSViewController overrides
    
    open override func loadView() {
        let scrollView = self.scrollView
        
        scrollView.documentView = self.collectionView
        self.view = scrollView
    }
    
    open override func viewWillAppear() {
        self.reloadData()
        super.viewWillAppear()
        #if DEBUG
        self.startTrackFrameChangeEvents()
        #endif
    }
    
    open override func viewDidAppear() {
        super.viewDidAppear()
        self.scrollToTop()
        
        // not sure why this is needed??
        self.collectionView.collectionViewLayout?.invalidateLayout()
    }
    
    open override func viewDidDisappear() {
        super.viewWillDisappear()
        self.viewModel = nil
        self.collectionView.reloadData()

        self.collectionView.postsFrameChangedNotifications = false
    }

    // MARK: -
    // MARK: content related utilities
    
    public var rowCount: Int {
        return self.viewModel?.rowCount ?? 0
    }
    
    public var sectionCount: Int {
        return self.viewModel?.sectionCount ?? 0
    }
    
    public var viewModelContentSize: CGSize {
        if let viewModel = self.viewModel {
            return CGSize(width: self.view.frame.size.width, height: viewModel.height)
        }
        
        return CGSize.zero
    }

    // MARK: -
    // MARK: scroll utils
    
    public func scrollToTop() {
        let contentInsets = self.scrollView.contentInsets
        self.scrollView.contentView.scroll(NSPoint(x: 0, y: -contentInsets.top))
        self.scrollView.reflectScrolledClipView(self.scrollView.contentView)
    }

    // MARK: -
    // MARK: NSCollectionView Delegate
    
    open func collectionView(_ collectionView: NSCollectionView,
                             willDisplay item: NSCollectionViewItem,
                             forRepresentedObjectAt indexPath: IndexPath) {
        
        guard let viewModel = self.viewModel,
        let row = viewModel.row(forIndexPath: indexPath) else {
            
            self.logger.error("Failed to find item at indexPath \(indexPath) from viewModel for updating display")
            return
        }
        
        row.willDisplayView(item)
    }
    
    open func collectionView(_ collectionView: NSCollectionView,
                             willDisplaySupplementaryView view: SDKView,
                             forElementKind elementKind: NSCollectionView.SupplementaryElementKind,
                             at indexPath: IndexPath) {
        
        if elementKind == NSCollectionView.elementKindSectionHeader,
        let viewModel = self.viewModel,
        let header = viewModel.header(forSection:indexPath.section),
        let adornmentView = view as? ListViewAdornmentView {
            
            header.willDisplayView(adornmentView)
        }
        
        if elementKind == NSCollectionView.elementKindSectionFooter,
        let viewModel = self.viewModel,
        let footer = viewModel.footer(forSection:indexPath.section),
        let adornmentView = view as? ListViewAdornmentView {
            footer.willDisplayView(adornmentView)
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
        return indexPaths
    }
    
    open func collectionView(_ collectionView: NSCollectionView,
                             shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        return indexPaths
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
    
    // MARK: -
    // MARK: NSCollectionViewDataSource
    
    open func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel,
        let tableSection = viewModel.section(forIndex: section) else {
            
            self.logger.log("Section \(section) not found, return 0 items count")
            return 0
        }
        
        let count = tableSection.rowCount
        self.logger.log("Reloading \(count) rows, in section: \(section)")
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
        self.collectionView.register(row.viewClass, forItemWithIdentifier:identifier)
        
        let item = self.collectionView.makeItem(withIdentifier: identifier, for: indexPath)
        item.highlightState = .none
        
        return item
    }
    
    open func numberOfSections(in collectionView: NSCollectionView) -> Int {
        let count = self.sectionCount
        self.logger.log("Reloading \(count) sections, total rowCount: \(self.rowCount)")
        return count
    }
    
    open func collectionView(_ collectionView: NSCollectionView,
                             viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
                             at indexPath: IndexPath) -> SDKView {
        
        if kind == NSCollectionView.elementKindSectionHeader,
        let viewModel = self.viewModel,
        let header = viewModel.header(forSection:indexPath.section) {
            
            let identifier = NSUserInterfaceItemIdentifier(header.cellReuseIdentifer)
            
            self.collectionView.register(header.viewClass,
                                         forSupplementaryViewOfKind: kind,
                                         withIdentifier: identifier)
            
            if let view = self.collectionView.makeSupplementaryView(ofKind: kind,
                                                                    withIdentifier: identifier,
                                                                    for: indexPath) as? ListViewAdornmentView {
                
                return view as! SDKView
            }
        }
        
        if kind == NSCollectionView.elementKindSectionFooter,
        let viewModel = self.viewModel,
        let footer = viewModel.footer(forSection:indexPath.section) {
            
            let identifier = NSUserInterfaceItemIdentifier(footer.cellReuseIdentifer)
            
            self.collectionView.register(footer.viewClass,
                                         forSupplementaryViewOfKind: kind,
                                         withIdentifier: identifier)
            
            if let view = self.collectionView.makeSupplementaryView(ofKind: kind,
                                                                    withIdentifier: identifier,
                                                                    for: indexPath) as? ListViewAdornmentView {
                return view as! SDKView
            }
        }
        
        self.logger.error("Supplemental item at indexPath: \(indexPath) not found")
        
        return SDKView()
    }
    
    // MARK: -
    // MARK: NSCollectionViewFlowLayout Layout delegate
    
    open func collectionView(_ collectionView: NSCollectionView,
                             layout collectionViewLayout: NSCollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        guard let viewModel = self.viewModel,
        let row = viewModel.row(forIndexPath: indexPath) else {
            
            self.logger.error("Returning zero for size of item at indexPath: \(indexPath)")
            
            return CGSize.zero
        }
        
        return CGSize(width: self.view.bounds.size.width, height: row.height)
    }
    
    open func collectionView(_ collectionView: NSCollectionView,
                             layout collectionViewLayout: NSCollectionViewLayout,
                             insetForSectionAt section: Int) -> SDKEdgeInsets {
        
        guard let viewModel = self.viewModel,
        let tableSection = viewModel.section(forIndex: section) else {
            
            //            self.logger.error("Return zero for size of item at indexPath: \(indexPath)")
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
        let header = viewModel.header(forSection:section) else {
            return NSSize.zero
        }
        
        return CGSize(width: self.view.bounds.size.width, height: header.preferredHeight)
    }
    
    open func collectionView(_ collectionView: NSCollectionView,
                             layout collectionViewLayout: NSCollectionViewLayout,
                             referenceSizeForFooterInSection section: Int) -> NSSize {
        guard let viewModel = self.viewModel,
        let footer = viewModel.footer(forSection:section) else {
            
            return NSSize.zero
        }
        return CGSize(width: self.view.bounds.size.width, height: footer.preferredHeight)
    }
    
    // MARK: -
    // MARK: MouseTrackingCollectionView delegate
    
    open func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                          mouseEnteredCellAtIndexPath indexPath: IndexPath,
                                          forItem item: NSCollectionViewItem,
                                          withEvent event: NSEvent) {
        
        item.highlightState = .forSelection
    }
    
    open func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                          mouseMovedInCellAtIndexPath indexPath: IndexPath,
                                          forItem item: NSCollectionViewItem,
                                          withEvent event: NSEvent) {
        
        
    }
    
    open func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                          mouseExitedCellAtIndexPath indexPath: IndexPath,
                                          forItem item: NSCollectionViewItem) {
        
        item.highlightState = .none
    }
    
    open func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                          mouseDidEnterWithEvent event: NSEvent) {
        
    }
    
    open func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                          mouseDidExitWithEvent event: NSEvent) {
        
        for item in self.collectionView.visibleItems() {
            if item.highlightState != .none {
                item.highlightState = .none
            }
        }
    }
    
    open func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                          mouseDownAtIndexPath indexPath: IndexPath,
                                          forItem item: NSCollectionViewItem,
                                          withEvent event: NSEvent) {
        
    }
    
    open func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                          mouseUpAtIndexPath indexPath: IndexPath,
                                          forItem item: NSCollectionViewItem,
                                          withEvent event: NSEvent) {
        
    }

    
}


