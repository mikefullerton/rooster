//
//  TableViewAdornmentView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/23/21.
//

import Foundation
import Cocoa

protocol TableViewAdornmentView {
    func setContents(_ contents: TableViewSectionAdornmentProtocol)
}
