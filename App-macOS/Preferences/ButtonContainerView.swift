//
//  ButtonContainerview.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import Cocoa

class ButtonsContainerView : NSView {
    static let buttonSize:CGFloat = 60.0
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        let lhs = NSView()
        let rhs = NSView()
        
        self.addSubview(lhs)
        self.addSubview(rhs)
        lhs.translatesAutoresizingMaskIntoConstraints = false
        rhs.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            lhs.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            lhs.trailingAnchor.constraint(equalTo: self.centerXAnchor),
            lhs.topAnchor.constraint(equalTo: self.topAnchor),
            lhs.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            rhs.leadingAnchor.constraint(equalTo: self.centerXAnchor),
            rhs.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            rhs.topAnchor.constraint(equalTo: self.topAnchor),
            rhs.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        let lhsButton = self.resetPrefsButton
        let rhsButton = self.playButton
        
        lhs.addSubview(lhsButton)
        rhs.addSubview(rhsButton)
        lhsButton.translatesAutoresizingMaskIntoConstraints = false
        rhsButton.translatesAutoresizingMaskIntoConstraints = false
        lhsButton.sizeToFit()
        rhsButton.sizeToFit()

        NSLayoutConstraint.activate([
            lhsButton.widthAnchor.constraint(equalToConstant: ButtonsContainerView.buttonSize),
            lhsButton.heightAnchor.constraint(equalToConstant: ButtonsContainerView.buttonSize),
            lhsButton.centerXAnchor.constraint(equalTo: lhs.centerXAnchor),
            lhsButton.centerYAnchor.constraint(equalTo: lhs.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            rhsButton.widthAnchor.constraint(equalToConstant: ButtonsContainerView.buttonSize),
            rhsButton.heightAnchor.constraint(equalToConstant: ButtonsContainerView.buttonSize),
            rhsButton.centerXAnchor.constraint(equalTo: rhs.centerXAnchor),
            rhsButton.centerYAnchor.constraint(equalTo: rhs.centerYAnchor),
        ])

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func resetButtonPressed(_ sender: NSButton) {
        AppDelegate.instance.preferencesController.preferences = Preferences()
    }

    @objc func tryItButtonPressed(_ sender: NSButton) {
        
    }

    lazy var resetPrefsButton: NSButton = {
        
        // "arrow.triangle.2.circlepath"
        
        let image = NSImage(systemName: "return")
        
        
        let view = NSButton.createImageButton(withImage: image)
        
        view.addTarget(self, action: #selector(resetButtonPressed(_:)), for: .touchUpInside)

        
        return view
        
    }()
    
    var redIcon: NSImage? {
        if let image = NSImage(named: "RedRoosterIcon") {
            return image
        }
        return nil
    }

    var defaultIcon: NSImage? {
        if let image = NSImage(named: "RedRoosterIcon") {
            return image
        }
        return nil
    }

    lazy var playButton: NSButton = {
        let view = NSButton.createImageButton(withImage: self.defaultIcon)

        return view
        
    } ()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: NSView.noIntrinsicMetric, height: ButtonsContainerView.buttonSize)
    }

}
