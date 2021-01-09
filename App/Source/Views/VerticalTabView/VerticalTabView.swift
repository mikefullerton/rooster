//
//  VerticalTabView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
import UIKit

class VerticalTabView : UIView {
    
    let items: [VerticalTabItem]
    
    let buttonBar: VerticalButtonBarView
    
    let buttonBarInsets = UIEdgeInsets.zero
    
    lazy var contentContainerView : UIView = {
        let view = UIView()
        view.backgroundColor = VerticalButton.selectedBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var contentView: UIView?

    init(with items: [VerticalTabItem]) {
        self.items = items
        self.buttonBar = VerticalButtonBarView(with: self.items)
     
        super.init(frame: CGRect.zero)
        
        self.addButtonBar()
        self.addContentContainerView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addButtonBar() {
        
        self.addSubview(self.buttonBar)
        
        self.buttonBar.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            self.buttonBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.buttonBarInsets.left),
            self.buttonBar.topAnchor.constraint(equalTo: self.topAnchor, constant: self.buttonBarInsets.top),
            self.buttonBar.widthAnchor.constraint(equalToConstant: self.buttonBar.intrinsicContentSize.width + self.buttonBarInsets.right),
            self.buttonBar.heightAnchor.constraint(equalToConstant: self.buttonBar.intrinsicContentSize.height + self.buttonBarInsets.top)
        ])
        
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 800, height: 800)

//        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
    
    func addContentContainerView() {
        let view = self.contentContainerView
        self.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.buttonBar.trailingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func setContentView(_ view: UIView) {
        
        if let contentView = self.contentView {
            contentView.removeFromSuperview()
            self.contentView = nil
        }
        
        self.contentContainerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.contentContainerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.contentContainerView.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.contentContainerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.contentContainerView.bottomAnchor)
        ])
       
        self.contentView = view
    }
}
