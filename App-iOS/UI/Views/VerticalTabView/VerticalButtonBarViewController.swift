//
//  VerticalButtonBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
import UIKit

protocol VerticalButtonListViewControllerDelegate : AnyObject {
    func verticalButtonBarViewController(_ verticalButtonBarViewController: VerticalButtonListViewController, didChooseItem item: VerticalTabItem)
}

typealias VerticalButtonBarViewModel = TableViewModel<VerticalTabItem, VerticalButtonListTableCell>

class VerticalButtonListViewController : ListViewController<VerticalButtonBarViewModel> {

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
            if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                return selectedIndexPath.item
            }
            
            return NSNotFound
        }
        set(selectedIndex) {
            self.tableView.selectRow(at: IndexPath(item: selectedIndex, section: 0), animated: true, scrollPosition: .top)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.borderWidth = 1.0
        self.view.layer.borderColor = Theme(for: self.view).borderColor.cgColor
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = self.delegate {
            delegate.verticalButtonBarViewController(self, didChooseItem: self.tabItems[indexPath.item])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectedIndex = 0
        if let delegate = self.delegate {
            delegate.verticalButtonBarViewController(self, didChooseItem: self.tabItems[0])
        }
    }
    
    
//    var selectedButton: VerticalButton? {
//        let index = self.selectedIndex
//
//        if index != NSNotFound {
//            return self.buttons[index]
//        }
//
//        return nil
//    }
//
//
//    func verticalButtonWasPressed(_ clickedButton: VerticalButton) {
//
//        self.buttons.forEach { (button) in
//            button.isSelected = button === clickedButton
//        }
//
//        if let delegate = self.delegate {
//            delegate.verticalButtonBarView(self, didChooseItem: clickedButton.item)
//        }
//    }
    
//    lazy var layout = VerticalViewLayout(hostView: self,
//                                         insets:UIEdgeInsets.zero,
//                                         spacing: UIOffset.zero)

    
//    override var intrinsicContentSize: CGSize {
//        let size = self.layout.intrinsicContentSize
//        return size
//    }
    
}

//
//class OldVerticalButtonBarView : UIView, VerticalButtonDelegate {
//
//    weak var delegate : VerticalButtonBarViewDelegate?
//
//    let items: [VerticalTabItem]
//
//    private var buttons: [VerticalButton] = []
//
//    init(with items: [VerticalTabItem]) {
//        self.items = items
//
//        super.init(frame: CGRect.zero)
//
//        for item in items {
//            let button = VerticalButton(with: item)
//            button.delegate = self
//            self.buttons.append(button)
//            self.addSubview(button)
//        }
//
//        self.layout.setViews(self.buttons)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    var selectedIndex: Int {
//        get {
//            return self.buttons.firstIndex { button in
//                return button.isSelected
//            } ?? NSNotFound
//        }
//        set(selectedIndex) {
//            for (index, button) in self.buttons.enumerated() {
//                button.isSelected = selectedIndex == index
//            }
//
//            if let delegate = self.delegate,
//               let selectedButton = self.selectedButton {
//                delegate.verticalButtonBarView(self, didChooseItem: selectedButton.item)
//            }
//        }
//    }
//
//    var selectedButton: VerticalButton? {
//        let index = self.selectedIndex
//
//        if index != NSNotFound {
//            return self.buttons[index]
//        }
//
//        return nil
//    }
//
//
//    func verticalButtonWasPressed(_ clickedButton: VerticalButton) {
//
//        self.buttons.forEach { (button) in
//            button.isSelected = button === clickedButton
//        }
//
//        if let delegate = self.delegate {
//            delegate.verticalButtonBarView(self, didChooseItem: clickedButton.item)
//        }
//    }
//
//    lazy var layout = VerticalViewLayout(hostView: self,
//                                         insets:UIEdgeInsets.zero,
//                                         spacing: UIOffset.zero)
//
//
//    override var intrinsicContentSize: CGSize {
//        let size = self.layout.intrinsicContentSize
//        return size
//    }
//
//}
