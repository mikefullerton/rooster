//
//  SoundPickerListViewModel.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

struct SoundPickerListViewModel : ListViewModelProtocol {
    
    typealias SoundFileRowType = ListViewRowDescriptor<SoundFile, SoundPickerListViewCell>
    
    let sections: [ListViewSectionDescriptor]
    
    let soundFolder: SoundFolder
    
    init(with soundFolder: SoundFolder) {
        
        self.soundFolder = soundFolder
        
        var sections: [ListViewSectionDescriptor] = []
        
        soundFolder.visitEach { item in
            if let soundFolder = item as? SoundFolder {
                let rows = soundFolder.soundFiles.map { SoundFileRowType(withContent: $0) }
                if rows.count > 0 {
                    var elements = soundFolder.pathComponents
                    elements.remove(at: 0)
                    
                    let section = ListViewSectionDescriptor(withRows: rows,
                                                            layout: ListViewSectionLayout.zero,
                                                            header: ListViewSectionAdornment(withTitle: elements.map { $0.displayName }.joined(separator:"/" )),
                                                            footer: nil)
                    
                    sections.append(section)
                }

            }
        }
        
        self.sections = sections
    }
    
    func soundFile(forIndexPath indexPath: IndexPath) -> SoundFile? {
        return ListViewModelContentFetcher<SoundFile, SoundPickerListViewCell>(model: self).contentForIndexPath(indexPath)
    }
    
    func indexPath(forSoundFile soundFileToFind: SoundFile) -> IndexPath? {
        return ListViewModelContentFetcher<SoundFile, SoundPickerListViewCell>(model: self).indexPath(forContent: soundFileToFind)
    }
}
