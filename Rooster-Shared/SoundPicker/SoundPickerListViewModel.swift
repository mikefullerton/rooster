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

public class SoundPickerListViewModel: ListViewModel {
    public let soundFolder: SoundFolder

    public init(with soundFolder: SoundFolder) {
        self.soundFolder = soundFolder

        var sections: [Section] = []

        soundFolder.visitEach { item in
            if let soundFolder = item as? SoundFolder {
                let rows = soundFolder.soundFiles.map {
                    Row(withContent: $0, rowControllerClass: SoundPickerListViewCell.self)
                }

                if !rows.isEmpty {
                    var elements = soundFolder.pathComponents
                    elements.remove(at: 0)

                    let section = Section(withRows: rows,
                                          layout: SectionLayout.zero,
                                          header: Adornment(withTitle: elements.map { $0.displayName }.joined(separator: "/" )),
                                          footer: nil)

                    sections.append(section)
                }
            }
        }

        super.init(withSections: sections)
    }
}
