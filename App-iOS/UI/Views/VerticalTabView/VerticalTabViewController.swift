//
//  VerticalTabViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
import UIKit

struct VerticalTabItem {
    let title: String
    let icon: UIImage?
    let view: UIView
}

class VerticalTabViewController : UIViewController, VerticalButtonListViewControllerDelegate {
    let items: [VerticalTabItem]
    
    lazy var verticalButtonBarController : VerticalButtonListViewController = {
        let controller = VerticalButtonListViewController(with: self.items)
        controller.delegate = self
        return controller
    }()
    
    init(with items: [VerticalTabItem]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var verticalTabView: VerticalTabView {
        return self.view as! VerticalTabView
    }
    
    override func loadView() {
        let view = VerticalTabView()
        
        self.addChild(self.verticalButtonBarController)
        view.addButtonBarView(self.verticalButtonBarController.view)
        
//        view.buttonBar.delegate = self;
        self.view = view
    }

    func verticalButtonBarViewController(_ verticalButtonBarViewController: VerticalButtonListViewController,
                                         didChooseItem item: VerticalTabItem) {
        self.verticalTabView.setContentView(item.view)
    }

    override var preferredContentSize: CGSize {
        get {
            return self.view.intrinsicContentSize
        }
        set (size) {
            
        }
    }
}
