//
//  GlobalSoundVolume.swift
//  RoosterCoreTests
//
//  Created by Mike Fullerton on 2/27/21.
//

import Foundation

public struct GlobalSoundVolume {
    public static let volumeChangedNotification = NSNotification.Name("GlobalSoundVolumeChanged")
    
    public static var volume: Float = 1.0 {
        didSet {
            if oldValue != Self.volume {
                NotificationCenter.default.post(name: Self.volumeChangedNotification, object: nil)
            }
        }
    }
}
