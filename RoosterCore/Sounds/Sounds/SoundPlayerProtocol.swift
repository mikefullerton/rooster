//
//  AlarmSound.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation

public protocol SoundDelegate : AnyObject {
    func soundWillStartPlaying(_ sound: SoundPlayerProtocol)
    func soundDidStartPlaying(_ sound: SoundPlayerProtocol)
    func soundDidStopPlaying(_ sound: SoundPlayerProtocol)
    func soundDidUpdate(_ sound: SoundPlayerProtocol)
}

public struct SoundState: DescribeableOptionSet, CustomStringConvertible, Codable, Equatable {
    
    
    public let rawValue: Int
    
    public static var zero                                  = SoundState([])
    public static let started                               = SoundState(rawValue: 1 << 1)
    public static let playing                               = SoundState(rawValue: 1 << 2)
    public static let stopped                               = SoundState(rawValue: 1 << 3)
    public static let updated                               = SoundState(rawValue: 1 << 4)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static var descriptions: [(Self, String)] = [
        (.started, "started"),
        (.playing, "playing"),
        (.stopped, "stopped"),
        (.updated, "updated"),
    ]

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

}

public protocol SoundPlayerProtocol: AnyObject, Loggable {
    var delegate: SoundDelegate? { get set }
    
    var id: String { get }
    var displayName: String { get }
    var duration: TimeInterval { get }
//    var behavior: SoundBehavior { get }
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var volume: Float { get }
    func set(volume: Float, fadeDuration: TimeInterval)
    func play(withBehavior behavior: SoundBehavior)
    func stop()
}

