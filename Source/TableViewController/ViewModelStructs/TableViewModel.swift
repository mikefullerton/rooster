//
//  TableViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

struct TableViewModel : TableViewModelProtocol {
    let sections: [TableViewSectionProtocol]

    init(withSections sections: [TableViewSectionProtocol] = []) {
        self.sections = sections
    }
}

