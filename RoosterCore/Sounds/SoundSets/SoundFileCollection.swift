//
//  SoundFileCollection.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/2/21.
//

import Foundation

public struct SoundFileCollection: Codable, CustomStringConvertible, Equatable {

    public private(set) var randomizerMap: [String: SoundPlayerRandomizer]
    public private(set) var relativePathMap: [String: URL]
    
    private let timestamp: Date
    
    public var description: String {
        return """
        type(of:self): \
        relativePaths: \(self.relativePathMap)
        """
    }
    
    public var count: Int {
        return self.relativePathMap.count
    }
    
    public init() {
        self.timestamp = Date()
        self.randomizerMap = [:]
        self.relativePathMap = [:]
    }
    
    public var allSoundIDs: [String] {
        return self.relativePathMap.keys.map { $0 as String }
    }
    
    public func randomizer(forID id: String) -> SoundPlayerRandomizer? {
        return self.randomizerMap[id]
    }
    
    public func relativePath(forID id: String) -> URL? {
        return self.relativePathMap[id]
    }
    
    public mutating func addSound(_ soundFile: SoundFile, randomizer: SoundPlayerRandomizer) {
        self.randomizerMap[soundFile.id] = randomizer
        self.relativePathMap[soundFile.id] = soundFile.relativePath
    }

    public static func == (lhs: SoundFileCollection, rhs: SoundFileCollection) -> Bool {
        return  lhs.randomizerMap == rhs.randomizerMap &&
                lhs.relativePathMap == rhs.relativePathMap
    }
    
    var randomSoundID: String? {
        return self.relativePathMap.keys.randomElement()
    }
}
