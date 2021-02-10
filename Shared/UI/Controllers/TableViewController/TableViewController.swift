//
//  TableViewController.swift
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

class TableViewController<ViewModel> : SDKViewController,
                                       NSCollectionViewDataSource,
                                       NSCollectionViewDelegate,
                                       NSCollectionViewDelegateFlowLayout,
                                       MouseTrackingCollectionViewDelegate,
                                       Reloadable where ViewModel: TableViewModelProtocol {
   
    private(set) var viewModel: ViewModel?
    
    func provideDataModel() -> ViewModel? {
        return nil
    }
    
    public func reloadData() {
        self.viewModel = self.provideDataModel()
        self.collectionView.reloadData()
        self.scrollView.invalidateIntrinsicContentSize()
//        self.collectionView.invalidateIntrinsicContentSize()
    }
    
    private func createCollectionViewLayout() -> NSCollectionViewFlowLayout {
        let layout = NSCollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionFootersPinToVisibleBounds = true
        layout.scrollDirection = .vertical
        return layout
    }
    
    // in case subclass wants to change layout
    func didCreateCollectionViewLayout(_ layout: NSCollectionViewFlowLayout) {
        
    }
    
    lazy var scrollView : NSScrollView = {
        let view = NSScrollView()
        view.automaticallyAdjustsContentInsets = false
        return view
    }()

    lazy var collectionView: MouseTrackingCollectionView = {
        let collectionView = MouseTrackingCollectionView()
        
        let layout = self.createCollectionViewLayout()
        self.didCreateCollectionViewLayout(layout)
        
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.mouseTrackingDelegate = self
        return collectionView
    } ()
        
    var rowCount: Int {
        return self.viewModel?.rowCount ?? 0
    }
    
    var sectionCount: Int {
        return self.viewModel?.sectionCount ?? 0
    }
    
    override func loadView() {
        let scrollView = self.scrollView
        
        scrollView.documentView = self.collectionView
        self.view = scrollView
    }
    
    override func viewWillAppear() {
        self.reloadData()
        super.viewWillAppear()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.scrollToTop()
    }
    
    override func viewDidDisappear() {
        super.viewWillDisappear()
        self.viewModel = nil
        self.collectionView.reloadData()
    }
    
    var viewModelContentSize: CGSize {
        if let viewModel = self.viewModel {
            return CGSize(width: self.view.frame.size.width, height: viewModel.height)
        }
        
        return CGSize.zero
    }

    func scrollToTop() {
        let contentInsets = self.scrollView.contentInsets
        self.scrollView.contentView.scroll(NSPoint(x: 0, y: -contentInsets.top))
        self.scrollView.reflectScrolledClipView(self.scrollView.contentView)
    }
    
    // MARK: Delegate
  
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
           let adornmentView = view as? TableViewAdornmentView {
            
            header.willDisplayView(adornmentView)
        }

        if elementKind == NSCollectionView.elementKindSectionFooter,
           let viewModel = self.viewModel,
           let footer = viewModel.footer(forSection:indexPath.section),
           let adornmentView = view as? TableViewAdornmentView {
            footer.willDisplayView(adornmentView)
        }
    }
    
    /// these are here for subclasses to override
    
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
    
    /// MARK: FLOW Layout delegate

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

    /// MARK: Data Source
    
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
                                                             for: indexPath) as? TableViewAdornmentView {
                
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
                                                                    for: indexPath) as? TableViewAdornmentView {
                return view as! SDKView
            }
        }

        return SDKView()
    }
    
    /// MARK: mouse tracking
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseEnteredCellAtIndexPath indexPath: IndexPath,
                                     withEvent event: NSEvent) {
    
        if let collectionViewItem = self.collectionView.item(at: indexPath) {
            collectionViewItem.highlightState = .forSelection
        }

    }
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseMovedInCellAtIndexPath indexPath: IndexPath,
                                     withEvent event: NSEvent) {
        
    }
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseExitedCellAtIndexPath indexPath: IndexPath) {
        
        if let collectionViewItem = self.collectionView.item(at: indexPath) {
            collectionViewItem.highlightState = .none
        }
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
                                     withEvent event: NSEvent) {
        
    }

    
}


