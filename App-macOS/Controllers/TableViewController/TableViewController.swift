//
//  TableViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import Cocoa

class TableViewController<ViewModel> : NSViewController,
                                       NSCollectionViewDataSource,
                                       NSCollectionViewDelegate,
                                       NSCollectionViewDelegateFlowLayout,
                                       Reloadable where ViewModel: TableViewModelProtocol {
    
    private(set) var viewModel: ViewModel?
    
    func reloadViewModel() -> ViewModel? {
        return nil
    }
    
    public func reloadData() {
        self.viewModel = self.reloadViewModel()
        self.collectionView.reloadData()
    }
    
    private func createLayout() -> NSCollectionViewLayout {
        let layout = NSCollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionFootersPinToVisibleBounds = true
        layout.scrollDirection = .vertical
        return layout
    }
    
    lazy var scrollView : NSScrollView = {
        let view = NSScrollView()
        view.automaticallyAdjustsContentInsets = false
        return view
    }()

    lazy var collectionView: NSCollectionView = {
        let collectionView = NSCollectionView()
        collectionView.collectionViewLayout = self.createLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    } ()
        
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
    
        let contentInsets = self.scrollView.contentInsets
        
        if contentInsets.top > 0 {
            self.scrollView.contentView.scroll(NSPoint(x: 0, y: -contentInsets.top))
            self.scrollView.reflectScrolledClipView(self.scrollView.contentView)
        }
    }
    
    override func viewDidDisappear() {
        super.viewWillDisappear()
        self.viewModel = nil
        self.collectionView.reloadData()
    }
    
    // MARK: Delegate
  
    func collectionView(_ collectionView: NSCollectionView,
                        willDisplay item: NSCollectionViewItem,
                        forRepresentedObjectAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        willDisplaySupplementaryView view: NSView,
                        forElementKind elementKind: NSCollectionView.SupplementaryElementKind,
                        at indexPath: IndexPath) {
        
    }

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
                        insetForSectionAt section: Int) -> NSEdgeInsets {
        
        return NSEdgeInsets.zero
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> NSSize {
        guard let viewModel = self.viewModel,
              let header = viewModel.header(forSection:section) else {
            
            return NSSize.zero
        }
        
        return CGSize(width: self.view.bounds.size.width, height: header.height)
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> NSSize {
        guard let viewModel = self.viewModel,
              let footer = viewModel.footer(forSection:section) else {

            return NSSize.zero
        }
        return CGSize(width: self.view.bounds.size.width, height: footer.height)
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
                        at indexPath: IndexPath) -> NSView {
        
        if kind == NSCollectionView.elementKindSectionHeader,
           let viewModel = self.viewModel,
           let header = viewModel.header(forSection:indexPath.section) {
            
            let identifier = NSUserInterfaceItemIdentifier(NSStringFromClass(header.viewClass))
            
            self.collectionView.register(header.viewClass,
                                         forSupplementaryViewOfKind: kind,
                                         withIdentifier: identifier)
            
            if let view = self.collectionView.makeSupplementaryView(ofKind: kind,
                                                             withIdentifier: identifier,
                                                             for: indexPath) as? TableViewAdornmentView {
                view.setContents(header)
                return view as! NSView
            }
        }

        if kind == NSCollectionView.elementKindSectionFooter,
           let viewModel = self.viewModel,
           let footer = viewModel.footer(forSection:indexPath.section) {

            let identifier = NSUserInterfaceItemIdentifier(NSStringFromClass(footer.viewClass))
            
            self.collectionView.register(footer.viewClass,
                                         forSupplementaryViewOfKind: kind,
                                         withIdentifier: identifier)
            
            if let view = self.collectionView.makeSupplementaryView(ofKind: kind,
                                                                    withIdentifier: identifier,
                                                                    for: indexPath) as? TableViewAdornmentView {
                view.setContents(footer)
                return view as! NSView
            }
        }

        return NSView()
    }
    
    // MARK: Data Source
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel,
              let tableSection = viewModel.section(forIndex: section) else {
            return 0
        }

        return tableSection.rowCount
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let viewModel = self.viewModel,
              let row = viewModel.row(forIndexPath: indexPath) else {
            return NSCollectionViewItem()
        }
        let identifier = NSUserInterfaceItemIdentifier(rawValue: row.cellReuseIdentifer)
        self.collectionView.register(row.cellClass, forItemWithIdentifier:identifier)

        let item = self.collectionView.makeItem(withIdentifier: identifier, for: indexPath)
        row.willDisplay(cell: item,
                        atIndexPath: indexPath,
                        isSelected:  false) // tableView.indexPathForSelectedRow != nil ? tableView.indexPathForSelectedRow == indexPath :
        return item
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return self.viewModel == nil ? 0 : viewModel!.sectionCount
    }
    
    var calculatedContentSize: CGSize {
        if let viewModel = self.viewModel {
            return CGSize(width: self.view.frame.size.width, height: viewModel.height)
        }
        
        return CGSize.zero
    }
    
//    override var preferredContentSize: CGSize {
//        get {
//            if let viewModel = self.viewModel {
//                return CGSize(width: self.view.frame.size.width, height: viewModel.height)
//            }
//            return super.preferredContentSize
//        }
//        set(size) {
//
//        }
//    }
}


