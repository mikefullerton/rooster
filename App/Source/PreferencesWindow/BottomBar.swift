//
//  BottomBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation
import UIKit


class BottomBar : UIView {
    
    init(frame: CGRect, withCancelButton: Bool) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear

        let layout = HorizontalViewLayout(hostView: self,
                                              insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20),
                                              spacing: UIOffset(horizontal: 10, vertical: 10),
                                              alignment: .right)

        layout.addSubview(self.doneButton)
        if withCancelButton {
            layout.addSubview(self.cancelButton)
        }
        
        self.addBlurView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBlurView() {
        let visualEffect = UIBlurEffect(style: .systemThinMaterial)
        
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
    
    let buttonSize = CGSize(width: 100, height: 100)
    
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

        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 60),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

    }
    
}
