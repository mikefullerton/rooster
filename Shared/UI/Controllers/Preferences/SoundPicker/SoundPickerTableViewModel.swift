//
//  SoundPickerTableViewModel.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

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
    
    let layout: TableViewSectionLayout = TableViewSectionLayout.zero
    let header: TableViewSectionAdornmentProtocol?
    
    init(with folder: SoundFolder) {
        self.folder = folder
        self.header = TableViewSectionAdornment(withTitle: folder.folderURL.soundName)
    }
    
    var rows: [TableViewRowProtocol] {
        if self.folder.disclosed {
            return self.folder.soundURLs.map { return TableViewRow<URL, SoundPickerTableViewCell>(withData: $0) }
        } else {
            return []
        }
    }
    
    
}

