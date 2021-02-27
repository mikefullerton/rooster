//
//  File.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/27/21.
//

import Foundation

public protocol RandomizerProtocol {
    func randomize(in range: ClosedRange<Int>) -> Int
    func randomChoice(withLikelihoodPercent percent: Float) -> Bool
    var randomYesNo: Bool { get }
}

extension RandomizerProtocol {

    public func randomChoice(withLikelihoodPercent percent: Float) -> Bool {
        let randomInt = self.randomize(in: 1...100)
        let likelihood = Int(percent * 100)
        return randomInt <= likelihood
    }
    
    public var randomYesNo: Bool {
        return self.randomChoice(withLikelihoodPercent: 0.5)
    }
}

public struct Randomizer: RandomizerProtocol {
    
    public init() {
        
    }
    
    public func randomize(in range: ClosedRange<Int>) -> Int {
        return Int.random(in: range)
    }
}
