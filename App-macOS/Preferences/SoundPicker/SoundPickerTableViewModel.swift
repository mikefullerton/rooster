//
//  SoundPickerTableViewModel.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation
import Cocoa

//struct SoundPicker

//typealias SoundPickerTableViewModel = TableViewModel<URL, SoundPickerTableViewCell>

struct SoundPickerTableViewModel : TableViewModelProtocol {
    
    let sections: [TableViewSectionProtocol]
    
    init(with soundFolder: SoundFolder) {
        self.sections = soundFolder.subFolders.map() { (folder) in
            return SoundPickerTableViewSection(with: folder)
        }
    }
}

struct SoundPickerTableViewSection : TableViewSectionProtocol {
    
    let folder: SoundFolder
    
    init(with folder: SoundFolder) {
        self.folder = folder
    }
    
    var rows: [TableViewRowProtocol] {
        if self.folder.disclosed {
            return self.folder.soundURLs.map { return TableViewRow<URL, SoundPickerTableViewCell>(withData: $0) }
        } else {
            return []
        }
    }
    
    var header: TableViewSectionAdornmentProtocol? {
        return TableViewSectionAdornment(withView: SectionHeaderView(with: self.folder.folderURL.soundName, disclosed: self.folder.disclosed),
                                         height: 30)
    }
    
}

class SectionHeaderView : NSView {
    
    init(with title: String, disclosed: Bool) {
        super.init(frame: CGRect.zero)
        self.addBlurView()
        self.titleView.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleView: NSTextField = {
        let titleView = NSTextField()
        titleView.isUserInteractionEnabled = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.alignment = .left
        titleView.font = NSFont.boldSystemFont(ofSize: NSFont.labelFontSize)
        
        self.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            titleView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleView.topAnchor.constraint(equalTo: self.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        return titleView
    }()
    
    private func addBlurView() {
        self.backgroundColor = NSColor.clear
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
    
}
