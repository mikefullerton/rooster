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
    let view: UIView
}

class VerticalTabViewController : UIViewController, VerticalButtonBarViewDelegate {
    let items: [VerticalTabItem]
    
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
        let view = VerticalTabView(with: self.items)
        view.buttonBar.delegate = self;
        self.view = view
    }

    func verticalButtonBarView(_ verticalButtonBarView: VerticalButtonBarView, didChooseItem item: VerticalTabItem) {
        self.verticalTabView.setContentView(item.view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.verticalTabView.buttonBar.selectedIndex = 0
    }
    
    override var preferredContentSize: CGSize {
        get {
            return self.view.intrinsicContentSize
        }
        set (size) {
            
        }
    }
}
