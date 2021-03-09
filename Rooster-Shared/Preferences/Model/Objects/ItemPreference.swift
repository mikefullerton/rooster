//
//  ItemPreference.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation
import RoosterCore

public struct ItemPreference: CustomStringConvertible, Codable, Equatable {
    public var soundPreference: SoundPreferences
    
    public init(with soundPreferences: SoundPreferences) {
        self.soundPreference = soundPreferences
    }
    
    public init() {
        self.init(with: SoundPreferences.default)
    }

    public var description: String {
        return """
        type(of:self)
        """
    }
    
}
