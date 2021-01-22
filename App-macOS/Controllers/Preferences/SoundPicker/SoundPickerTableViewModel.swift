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

class SectionHeaderView : BlurView {
    
    init(with title: String, disclosed: Bool) {
        super.init(frame: CGRect.zero)
        self.titleView.stringValue = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleView: NSTextField = {
        let titleView = NSTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.alignment = .left
        titleView.font = NSFont.boldSystemFont(ofSize: NSFont.labelFontSize)
        titleView.drawsBackground = false
        titleView.isBordered = false

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
    
}
