//
//  SoundPickerTableViewCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import Cocoa

class SoundPickerTableViewCell : NSCollectionViewItem, TableViewRowCell {
    
    typealias DataType = URL
    
    private var url: URL?
    private var soundIndex: SoundPreference.SoundIndex = .sound1
    
    override func loadView() {
        self.view = NSView()
        
        self.view.wantsLayer = true
        
        self.addPlayButton()
        self.addTitleView()
    }
    
    func configureCell(withData data: URL, indexPath: IndexPath, isSelected: Bool) {
        self.url = data
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

    static var cellHeight: CGFloat {
        return 32.0
    }
    
    let buttonHeight:CGFloat = 20

    lazy var playButton: PlaySoundButton = PlaySoundButton()

    lazy var titleView: NSTextField = {
        let titleView = NSTextField()
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
                self.view.layer?.backgroundColor = NSColor.systemBlue.cgColor
            } else {
                self.view.layer?.backgroundColor = NSColor.clear.cgColor
            }
        }
    }
}
