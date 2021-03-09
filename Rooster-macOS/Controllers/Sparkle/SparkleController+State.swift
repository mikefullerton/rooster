//
//  SparkleController+SparkleUpdaterDelegate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/4/21.
//

import Foundation
import RoosterCore
import Sparkle

extension SparkleController {
    public struct State: DescribeableOptionSet {
        public typealias RawValue = Int

        public private(set) var rawValue: Int

        public static var zero                          = State([])
        public static let initializing                  = State(rawValue: 1 << 0)

        public static let checking                      = State(rawValue: 1 << 1)
        public static let userInitiated                 = State(rawValue: 1 << 2)
        public static let foundNewVersion               = State(rawValue: 1 << 3)
        public static let updatePermissions             = State(rawValue: 1 << 4)
        public static let updateDownloaded              = State(rawValue: 1 << 5)
        public static let resumeableUpdateFound         = State(rawValue: 1 << 6)
        public static let informatationalUpdateFound    = State(rawValue: 1 << 7)
        public static let showingReleaseNotes           = State(rawValue: 1 << 8)
        public static let downloadInititiated           = State(rawValue: 1 << 9)
        public static let downloading                   = State(rawValue: 1 << 10)
        public static let extracting                    = State(rawValue: 1 << 11)
        public static let readyToInstall                = State(rawValue: 1 << 12)
        public static let installing                    = State(rawValue: 1 << 13)
        public static let terminating                   = State(rawValue: 1 << 14)

        public static let finished                      = State(rawValue: 1 << 31)
        public static let failed                        = State(rawValue: 1 << 32)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static var descriptions: [(Self, String)] = [
            (.initializing, "initializing"),
            (.checking, "checking"),
            (.userInitiated, "userInitiated"),
            (.foundNewVersion, "foundNewVersion"),
            (.updatePermissions, "updatePermissions"),
            (.updateDownloaded, "updateDownloaded"),
            (.resumeableUpdateFound, "resumeableUpdateFound"),
            (.informatationalUpdateFound, "informatationalUpdateFound"),
            (.showingReleaseNotes, "showingReleaseNotes"),
            (.downloadInititiated, "downloadInititiated"),
            (.downloading, "downloading"),
            (.extracting, "extracting"),
            (.readyToInstall, "readyToInstall"),
            (.installing, "installing"),
            (.terminating, "terminating"),

            (.finished, "finished"),
            (.failed, "failed")
        ]
    }
}
