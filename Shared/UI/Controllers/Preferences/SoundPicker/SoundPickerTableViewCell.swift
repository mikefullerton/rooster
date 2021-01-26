//
//  SoundPickerTableViewCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class SoundPickerTableViewCell : SDKCollectionViewItem, TableViewRowCell {
    
    typealias ContentType = URL
    
    private var url: URL?
    private var soundIndex: SoundPreference.SoundIndex = .sound1
    
    override func loadView() {
        self.view = SDKView()
        
        self.view.wantsLayer = true
        
        self.addPlayButton()
        self.addTitleView()
    }
    
    func viewWillAppear(withContent content: URL) {
        self.url = content
        self.playButton.url = url
        self.playButton.isEnabled = true
        
        if let fileName = self.url?.soundName {
            self.titleView.stringValue = fileName
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.url = nil
        self.playButton.url = nil
    }

    static var preferredHeight: CGFloat {
        return 32.0
    }
    
    let buttonHeight:CGFloat = 20

    lazy var playButton: PlaySoundButton = PlaySoundButton()

    lazy var titleView: SDKTextField = {
        let titleView = SDKTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self.view).secondaryLabelColor
        titleView.alignment = .left
        titleView.drawsBackground = false
        titleView.isBordered = false

        return titleView
    }()
    
    func addTitleView() {
        
        let titleView = self.titleView
        
        self.view.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
            titleView.trailingAnchor.constraint(equalTo: self.playButton.leadingAnchor, constant: -20),
            titleView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }
    
    func addPlayButton() {
        let button = self.playButton
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)

        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set(selected) {
            super.isSelected = selected
            
            if selected {
                self.view.sdkBackgroundColor = SDKColor.systemBlue
            } else {
                self.view.sdkBackgroundColor = SDKColor.clear
            }
        }
    }
}
