//
//  File.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/27/21.
//

import Foundation

public protocol RandomizerProtocol {
    var randomYesNo: Bool { get }

    func randomize(in range: ClosedRange<Int>) -> Int
    func randomChoice(withLikelihoodPercent percent: Float) -> Bool
}

public struct Randomizer: RandomizerProtocol {
    public init() {
    }

    public func randomize(in range: ClosedRange<Int>) -> Int {
        Int.random(in: range)
    }
}

extension RandomizerProtocol {
    public func randomChoice(withLikelihoodPercent percent: Float) -> Bool {
        let randomInt = self.randomize(in: 1...100)
        let likelihood = Int(percent * 100)
        return randomInt <= likelihood
    }

    public var randomYesNo: Bool {
        self.randomChoice(withLikelihoodPercent: 0.5)
    }
}
