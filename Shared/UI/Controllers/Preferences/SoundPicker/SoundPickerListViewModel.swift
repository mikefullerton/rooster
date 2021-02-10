//
//  SoundPickerListViewModel.swift
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

struct SoundPickerListViewModel : ListViewModelProtocol {
    
    let sections: [ListViewSectionDescriptor]
    
    init(with soundFolder: SoundFolder) {
        
        var sections: [ListViewSectionDescriptor] = []
        
        soundFolder.visitEach { item in
            if let soundFolder = item as? SoundFolder {
                let rows = soundFolder.sounds.map { ListViewRowDescriptor<SoundFile, SoundPickerListViewCell>(withContent: $0) }
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
}
