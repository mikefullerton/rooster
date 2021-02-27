//
//  RandomizerTests.swift
//  Rooster-macOSTests
//
//  Created by Mike Fullerton on 2/26/21.
//

import Foundation
import XCTest
@testable import RoosterCore

class RandomizerTests: XCTestCase {

    func testRandomizer() {
        let randomizer = Randomizer()

        var count = 0
        let total = 1000
        
        for _ in 1...total {
            if randomizer.randomYesNo {
                count += 1
            }
        }
        
        print("YesNo count: \(count) out of \(total)")
        
    }
    
    func testGenerator() {
        
    }
}
