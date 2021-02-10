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

protocol VerticalButtonListViewControllerDelegate : AnyObject {
    func verticalButtonBarViewController(_ verticalButtonBarViewController: VerticalButtonListViewController, didChooseItem item: VerticalTabItem)
}

typealias VerticalButtonBarViewModel = TableViewModel<VerticalTabItem, VerticalButtonListTableCell>

class VerticalButtonListViewController : TableViewController<VerticalButtonBarViewModel> {

    weak var delegate : VerticalButtonListViewControllerDelegate?
    
    private let tabItems: [VerticalTabItem]
     
    init(with items: [VerticalTabItem]) {
        self.tabItems = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func provideDataModel() -> VerticalButtonBarViewModel? {
        return VerticalButtonBarViewModel(withData: self.tabItems)
    }
    
    private var selectedIndex: Int {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.isSelectable = true
        self.collectionView.allowsEmptySelection = false
        
    }

    override func collectionView(_ collectionView: SDKCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let delegate = self.delegate,
           indexPaths.count == 1,
           let indexPath = indexPaths.first {
            
            delegate.verticalButtonBarViewController(self, didChooseItem: self.tabItems[indexPath.item])
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.selectedIndex = 0
        if let delegate = self.delegate {
            delegate.verticalButtonBarViewController(self, didChooseItem: self.tabItems[0])
        }
    }
}

