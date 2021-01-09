//
//  VerticalButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
import UIKit

protocol VerticalButtonDelegate : AnyObject {
    func verticalButtonWasPressed(_ button: VerticalButton)
}

class VerticalButton : UIView {
    
    weak var delegate: VerticalButtonDelegate?
    
    let insets = UIEdgeInsets.twenty
    
    let item: VerticalTabItem
    
    static var selectedBackgroundColor = UIColor.systemBackground
    
    var isSelected: Bool = false {
        didSet {
            if self.isSelected {
                self.backgroundColor = VerticalButton.selectedBackgroundColor
                self.titleView.tintColor = UIColor.label
            } else {
                self.backgroundColor = UIColor.clear
                self.titleView.tintColor = UIColor.secondaryLabel
            }
        }
    }
     
    init(with item: VerticalTabItem) {
        self.item = item
        super.init(frame: CGRect.zero)
    
        self.titleView.text = item.title
        self.addTitleView()
        
        self.addGestureRecognizer(self.gestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func buttonPressed(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.verticalButtonWasPressed(self)
        }
    }

    lazy var gestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(buttonPressed(_:)))
    
    lazy var titleView: UILabel = {
        let view = UILabel()
        view.textAlignment = .right
        
        return view
    }()
    
    func addTitleView() {
        let button = self.titleView
        
        self.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            button.topAnchor.constraint(equalTo: self.topAnchor),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        var size = self.titleView.intrinsicContentSize
        size.height += self.insets.top + self.insets.bottom
        size.width += self.insets.left + self.insets.right
        return size
    }
}
