//
//  BottomBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation
import UIKit


class BottomBar : UIView {
    
    let preferredHeight: CGFloat = 60
    let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    let buttonSpacing: CGFloat = 10.0
    let buttonSize = CGSize(width: 100, height: 60)

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear

        let blurView = self.blurView
        self.insertSubview(blurView, at: 0)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: self.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        let button = self.doneButton
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.insets.left),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var blurView: UIView = {
        let visualEffect = UIBlurEffect(style: .systemThinMaterial)
        
        let visualEffectView = UIVisualEffectView(effect: visualEffect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false

        return visualEffectView
    }()
    
    func addLeftButton(title: String) -> UIButton {
        
        let button = self.leftButton
        button.setTitle(title, for: .normal)
        
        self.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.insets.left),
        ])
        
        return button
    }
    
    lazy var leftButton: UIButton = {
        let view = CustomButton(type: .system)
        view.role = .normal
        view.preferredSize = self.buttonSize

        return view
    }()

    func addCancelButton() -> UIButton {
        let button = self.cancelButton
        self.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: self.doneButton.leadingAnchor, constant: -self.buttonSpacing),
        ])

        return button
    }
    
    lazy var cancelButton: UIButton = {
        let view = CustomButton(type: .system)
        view.setTitle("Cancel", for: .normal)
        view.role = .cancel
        view.preferredSize = self.buttonSize
        return view
    }()

    lazy var doneButton: CustomButton = {
        let view = CustomButton(type: .system)
        view.setTitle("Done", for: .normal)
        view.role = .primary
        view.preferredSize = self.buttonSize
        return view
    }()
    
    func addToView(_ view: UIView) {
        
        view.addSubview(self)

        var frame = self.bounds
        frame.size.height = self.preferredHeight
        self.frame = frame

        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.preferredHeight)
    }

}
