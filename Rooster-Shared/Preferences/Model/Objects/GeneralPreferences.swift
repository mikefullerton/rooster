//
//  GeneralPreferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public struct GeneralPreferences: CustomStringConvertible, Loggable, Equatable {
    public var options: Options

    public static let `default` = GeneralPreferences(options: .all)

    public init(options: Options) {
        self.options = options
    }

    public var description: String {
        """
        "\(type(of: self)): \
        Options: \(self.options.description)
        """
    }
}

extension GeneralPreferences: Codable {
    private enum CodingKeys: String, CodingKey {
        case options
    }

    public init(from decoder: Decoder) throws {
        let defaults = Self.default

        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.options = try values.decodeIfPresent(Options.self, forKey: .options) ?? defaults.options
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.options, forKey: .options)
    }
}

extension GeneralPreferences {
    public struct Options: DescribeableOptionSet {
        public let rawValue: Int

        public static var zero                 = Options([])
        public static let automaticallyLaunch  = Options(rawValue: 1 << 1)

        public static let all: Options = [ .automaticallyLaunch ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static var descriptions: [(Self, String)] = [
            (.automaticallyLaunch, "automaticallyLaunch")
        ]
    }
}
