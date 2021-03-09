//
//  VerticalButtonBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public protocol VerticalButtonListViewControllerDelegate : AnyObject {
    func verticalButtonBarViewController(_ verticalButtonBarViewController: VerticalButtonListViewController, didChooseItem item: VerticalTabItem)
    func verticalButtonBarViewControllerGetItems(_ verticalButtonBarViewController: VerticalButtonListViewController) -> [VerticalTabItem]
}

public typealias VerticalButtonBarViewModel = ListViewModel<VerticalTabItem, VerticalButtonListTableCell>

open class VerticalButtonListViewController : ListViewController<VerticalButtonBarViewModel> {

    public weak var delegate : VerticalButtonListViewControllerDelegate?
    
    private var tabItems: [VerticalTabItem] {
        return self.delegate?.verticalButtonBarViewControllerGetItems(self) ?? []
    }
     
    open override func provideDataModel() -> VerticalButtonBarViewModel? {
        return VerticalButtonBarViewModel(withContent: self.tabItems)
    }
    
    public var selectedIndex: Int {
        get {
            let selectedIndexPaths = self.collectionView.selectionIndexPaths
            
            if selectedIndexPaths.count == 1,
               let indexPath = selectedIndexPaths.first {
                return indexPath.item
            }
            
            return NSNotFound
        }
        set(selectedIndex) {
            self.collectionView.selectItems(at: Set<IndexPath>([ IndexPath(item: selectedIndex, section: 0)]),
                                            scrollPosition: .centeredVertically)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.isSelectable = true
        self.collectionView.allowsEmptySelection = false
        
    }

    open override func collectionView(_ collectionView: SDKCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let delegate = self.delegate,
           indexPaths.count == 1,
           let indexPath = indexPaths.first {
            
            delegate.verticalButtonBarViewController(self, didChooseItem: self.tabItems[indexPath.item])
        }
    }
    
    open override func viewWillAppear() {
        super.viewWillAppear()
        
        if !self.tabItems.isEmpty {
            self.selectedIndex = 0
            self.delegate?.verticalButtonBarViewController(self, didChooseItem: self.tabItems[0])
        }
    }
}

