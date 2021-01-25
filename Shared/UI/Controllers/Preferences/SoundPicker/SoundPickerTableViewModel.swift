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
        return TableViewSectionAdornment(withTitle: self.folder.folderURL.soundName,
                                         height: 30)
            
            
//            withView: SectionHeaderView(with: self.folder.folderURL.soundName, disclosed: self.folder.disclosed),
//                                         height: 30)
    }
    
}

