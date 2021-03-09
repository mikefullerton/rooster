//
//  SpaceAdornment.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/30/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

extension ListViewModel {
    public class SpacerAdornment: Adornment {
        public init(withHeight height: CGFloat) {
            super.init(withContent: height, withViewClass: SpacerView.self)
        }
    }
}
