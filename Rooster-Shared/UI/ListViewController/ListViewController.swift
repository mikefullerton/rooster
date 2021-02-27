//
//  ListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class ListViewController<ViewModel: ListViewModelProtocol> :    SDKViewController,
                                                                NSCollectionViewDataSource,
                                                                NSCollectionViewDelegate,
                                                                NSCollectionViewDelegateFlowLayout,
                                                                MouseTrackingCollectionViewDelegate,
                                                                Reloadable,
                                                                Loggable {
   
    private(set) var viewModel: ViewModel?
    
    // For subclasses to override and return the ViewModel
    func provideDataModel() -> ViewModel? {
        fatalError("This is a required override")
    }
    
    var minimumContentSize = CGSize.zero
    
    // Call this to reload the dataModel. This calls provideDataModel.
    public func reloadData() {
        self.viewModel = self.provideDataModel()
        self.collectionView.reloadData()
    }
    
    // in case subclass wants to change layout
  
    // MARK: -
    // MARK: View creation for subclass overrides

    private func createCollectionViewLayout() -> NSCollectionViewFlowLayout {
        let layout = NSCollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionFootersPinToVisibleBounds = true
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = NSEdgeInsets.zero
        return layout
    }
    
    func createScrollView() -> NSScrollView {
        return NSScrollView()
    }

    func createCollectionView() -> MouseTrackingCollectionView {
        return MouseTrackingCollectionView()
    }

    // MARK: -
    // MARK: view properties
    
    lazy var collectionView: MouseTrackingCollectionView = {
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

    lazy var scrollView : NSScrollView = {
        let view = self.createScrollView()
        view.automaticallyAdjustsContentInsets = false
        return view
    }()

    // MARK: -
    // MARK: NSViewController overrides
    
    override func loadView() {
        let scrollView = self.scrollView
        
        scrollView.documentView = self.collectionView
        self.view = scrollView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame = CGRect.zero
        frame.size = self.minimumContentSize
        self.view.frame = frame;
    }
    
    override func viewWillAppear() {
        self.reloadData()
        super.viewWillAppear()

    
        self.collectionView.postsFrameChangedNotifications = false
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.scrollToTop()
        
        // not sure why this is needed??
        self.collectionView.collectionViewLayout?.invalidateLayout()
       
    }
    
    override func viewDidDisappear() {
        super.viewWillDisappear()
        self.viewModel = nil
        self.collectionView.reloadData()

        self.collectionView.postsFrameChangedNotifications = false
    }

    override var preferredContentSize: NSSize {
        get {
            return super.preferredContentSize
        }
        set(size) {
            var size = size
            size.width = max(size.width, self.minimumContentSize.width)
            size.height = max(size.height, self.minimumContentSize.height)
            super.preferredContentSize = size
        }
    }

    // MARK: -
    // MARK: content related utilities
    
    var rowCount: Int {
        return self.viewModel?.rowCount ?? 0
    }
    
    var sectionCount: Int {
        return self.viewModel?.sectionCount ?? 0
    }
    
    var viewModelContentSize: CGSize {
        if let viewModel = self.viewModel {
            return CGSize(width: self.view.frame.size.width, height: viewModel.height)
        }
        
        return CGSize.zero
    }

    // MARK: -
    // MARK: scroll utils
    
    func scrollToTop() {
        let contentInsets = self.scrollView.contentInsets
        self.scrollView.contentView.scroll(NSPoint(x: 0, y: -contentInsets.top))
        self.scrollView.reflectScrolledClipView(self.scrollView.contentView)
    }

    // MARK: -
    // MARK: NSCollectionView Delegate
  
    func collectionView(_ collectionView: NSCollectionView,
                        willDisplay item: NSCollectionViewItem,
                        forRepresentedObjectAt indexPath: IndexPath) {
        
        guard let viewModel = self.viewModel,
              let row = viewModel.row(forIndexPath: indexPath) else {
            return
        }

        row.willDisplayView(item)
    }
    
    func collectionView(_ collectionView: NSCollectionView,
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
    
    func collectionView(_ collectionView: NSCollectionView,
                        didSelectItemsAt indexPaths: Set<IndexPath>) {
    
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        didDeselectItemsAt indexPaths: Set<IndexPath>) {
        
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        return indexPaths
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        return indexPaths
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        didEndDisplaying item: NSCollectionViewItem,
                        forRepresentedObjectAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        didEndDisplayingSupplementaryView view: NSView,
                        forElementOfKind elementKind: NSCollectionView.SupplementaryElementKind,
                        at indexPath: IndexPath) {
    
    }
    
    // MARK: -
    // MARK: NSCollectionViewDataSource
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel,
              let tableSection = viewModel.section(forIndex: section) else {
            return 0
        }

        return tableSection.rowCount
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        guard let viewModel = self.viewModel,
              let row = viewModel.row(forIndexPath: indexPath) else {
            return NSCollectionViewItem()
        }
        let identifier = NSUserInterfaceItemIdentifier(rawValue: row.cellReuseIdentifer)
        self.collectionView.register(row.viewClass, forItemWithIdentifier:identifier)

        let item = self.collectionView.makeItem(withIdentifier: identifier, for: indexPath)
        item.highlightState = .none
        
        return item
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return self.viewModel == nil ? 0 : viewModel!.sectionCount
    }
    
    func collectionView(_ collectionView: NSCollectionView,
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

        return SDKView()
    }
    
    // MARK: -
    // MARK: NSCollectionViewFlowLayout Layout delegate

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        guard let viewModel = self.viewModel,
              let row = viewModel.row(forIndexPath: indexPath) else {
            return CGSize.zero
        }

        return CGSize(width: self.view.bounds.size.width, height: row.height)
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        insetForSectionAt section: Int) -> SDKEdgeInsets {
        
        guard let viewModel = self.viewModel,
              let tableSection = viewModel.section(forIndex: section) else {
            return SDKEdgeInsets.zero
        }

        return tableSection.layout.insets
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        guard let viewModel = self.viewModel,
              let tableSection = viewModel.section(forIndex: section) else {
            return 0
        }

        return tableSection.layout.rowSpacing
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        // since we are one cell per row this won't do anything
        return 0
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> NSSize {
        guard let viewModel = self.viewModel,
              let header = viewModel.header(forSection:section) else {
            return NSSize.zero
        }
        
        return CGSize(width: self.view.bounds.size.width, height: header.preferredHeight)
    }

    func collectionView(_ collectionView: NSCollectionView,
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
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseEnteredCellAtIndexPath indexPath: IndexPath,
                                     forItem item: NSCollectionViewItem,
                                     withEvent event: NSEvent) {
    
        item.highlightState = .forSelection
    }
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseMovedInCellAtIndexPath indexPath: IndexPath,
                                     forItem item: NSCollectionViewItem,
                                     withEvent event: NSEvent) {


    }
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseExitedCellAtIndexPath indexPath: IndexPath,
                                     forItem item: NSCollectionViewItem) {
        
        item.highlightState = .none
    }
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseDidEnterWithEvent event: NSEvent) {
        
    }
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseDidExitWithEvent event: NSEvent) {
        
        for item in self.collectionView.visibleItems() {
            if item.highlightState != .none {
                item.highlightState = .none
            }
        }
    }
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseDownAtIndexPath indexPath: IndexPath,
                                     forItem item: NSCollectionViewItem,
                                     withEvent event: NSEvent) {
        
    }

    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseUpAtIndexPath indexPath: IndexPath,
                                     forItem item: NSCollectionViewItem,
                                     withEvent event: NSEvent) {
        
    }

    
}


