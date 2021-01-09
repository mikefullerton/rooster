//
//  VerticalButtonBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
import UIKit

protocol VerticalButtonBarViewDelegate : AnyObject {
    func verticalButtonBarView(_ verticalButtonBarView: VerticalButtonBarView, didChooseItem item: VerticalTabItem)
}

class VerticalButtonBarView : UIView, VerticalButtonDelegate {
    
    weak var delegate : VerticalButtonBarViewDelegate? 
    
    let items: [VerticalTabItem]
    
    private var buttons: [VerticalButton] = []
     
    init(with items: [VerticalTabItem]) {
        self.items = items
        
        super.init(frame: CGRect.zero)
    
        for item in items {
            let button = VerticalButton(with: item)
            button.delegate = self
            self.buttons.append(button)
            self.addSubview(button)
        }
        
        self.layout.setViews(self.buttons)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var selectedIndex: Int {
        get {
            return self.buttons.firstIndex { button in
                return button.isSelected
            } ?? NSNotFound
        }
        set(selectedIndex) {
            for (index, button) in self.buttons.enumerated() {
                button.isSelected = selectedIndex == index
            }
            
            if let delegate = self.delegate,
               let selectedButton = self.selectedButton {
                delegate.verticalButtonBarView(self, didChooseItem: selectedButton.item)
            }
        }
    }

    var selectedButton: VerticalButton? {
        let index = self.selectedIndex
        
        if index != NSNotFound {
            return self.buttons[index]
        }
        
        return nil
    }
    
    
    func verticalButtonWasPressed(_ clickedButton: VerticalButton) {
        
        self.buttons.forEach { (button) in
            button.isSelected = button === clickedButton
        }
        
        if let delegate = self.delegate {
            delegate.verticalButtonBarView(self, didChooseItem: clickedButton.item)
        }
    }
    
    lazy var layout = VerticalViewLayout(hostView: self,
                                         insets:UIEdgeInsets.zero,
                                         spacing: UIOffset.zero)

    
    override var intrinsicContentSize: CGSize {
        let size = self.layout.intrinsicContentSize
        return size
    }
    
}
