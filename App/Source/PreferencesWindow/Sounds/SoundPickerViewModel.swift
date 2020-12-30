//
//  SoundPickerViewModel.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

struct SoundPickerTableViewModel : TableViewModelProtocol {
    let sections: [TableViewSectionProtocol]

    init(withURLs urls: [URL], soundIndex: SoundPreference.SoundIndex) {
        self.sections = [ SoundPickerTableViewSection(withURLs: urls, soundIndex: soundIndex) ]
    }
}

struct SoundPickerTableViewSection : TableViewSectionProtocol {
    var rows:[TableViewRowProtocol]
    init(withURLs urls: [URL], soundIndex: SoundPreference.SoundIndex) {
        self.rows = urls.map { SoundPickerTableViewRow(withURL: $0, soundIndex: soundIndex) }
    }
}

struct SoundPickerTableViewRow : TypedTableViewRowProtocol {
    
    typealias ViewClass = SoundPickerTableViewCell
    
    let url: URL
    let soundIndex: SoundPreference.SoundIndex
    
    init(withURL url: URL, soundIndex: SoundPreference.SoundIndex) {
        self.url = url
        self.soundIndex = soundIndex
    }
    
    func willDisplay(cell: SoundPickerTableViewCell) {
        cell.setURL(self.url, soundIndex: self.soundIndex)
    }
}
