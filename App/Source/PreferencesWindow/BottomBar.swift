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
    
    init(frame: CGRect, withCancelButton: Bool) {
        var newFrame = frame
        newFrame.size.height = self.preferredHeight

        super.init(frame: newFrame)

        self.backgroundColor = UIColor.clear

        self.addSubview(self.doneButton)
        self.layout.addView(self.doneButton)
        if withCancelButton {
            self.addSubview(self.cancelButton)
            self.layout.addView(self.cancelButton)
        }
        
        self.insertSubview(self.blurView, at: 0)
        
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

        var frame = self.bounds
        frame.size.height = self.preferredHeight
        self.frame = frame

        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var layout = HorizontalViewLayout(hostView: self,
                                           insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20),
                                           spacing: UIOffset(horizontal: 10, vertical: 10),
                                           alignment: .right)
    
    override func updateConstraints() {
        super.updateConstraints()

        NSLayoutConstraint.activate([
            self.blurView.topAnchor.constraint(equalTo: self.topAnchor),
            self.blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: self.preferredHeight),
            self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor)
        ])

        self.layout.updateConstraints()
    }
    
}
