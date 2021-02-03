//
//  URL+Randomized.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation

extension URL {
    
    static var randomizedSound: URL {
        return URL(string: "rooster://randomized")!
    }
    
    var isRandomizedSound: Bool {
        return self == URL.randomizedSound
    }
}
