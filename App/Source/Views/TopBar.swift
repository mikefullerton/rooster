//
//  TopBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation

import UIKit


class TopBar : UIView {
    
    var preferredHeight:CGFloat {
        return 40.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
        self.addBlurView()
        
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        self.setContentHuggingPriority(., for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addBlurView() {
        self.backgroundColor = UIColor.clear
        let visualEffect = Theme(for: self).blurEffect

        let visualEffectView = UIVisualEffectView(effect: visualEffect)
        
        self.insertSubview(visualEffectView, at: 0)
        
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: self.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    lazy var titleView: UITextField = {
        let titleView = UITextField()
        titleView.isUserInteractionEnabled = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.textAlignment = .center
        return titleView
    }()
        
    func addTitleView(withText text: String) {
        let titleView = self.titleView
        titleView.text = text
        
        self.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            
            
//            titleView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            titleView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
//
//            titleView.topAnchor.constraint(equalTo: self.topAnchor),
//            titleView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    func addToView(_ view: UIView) {
        
        view.addSubview(self)

        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: self.preferredHeight),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.preferredHeight)
    }
}
