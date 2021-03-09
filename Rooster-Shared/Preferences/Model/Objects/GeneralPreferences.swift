//
//  GeneralPreferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public struct GeneralPreferences: CustomStringConvertible, Loggable, Equatable {
    public var automaticallyLaunch: Bool
    public var showInDock: Bool

    public static let `default` = GeneralPreferences(automaticallyLaunch: true, showInDock: true)

    public init(automaticallyLaunch: Bool,
                showInDock: Bool) {
        self.automaticallyLaunch = automaticallyLaunch
        self.showInDock = showInDock
    }

    public var description: String {
        """
        "\(type(of: self)): \
        Automatically Launch: \(self.automaticallyLaunch), \
        Show in Dock: \(self.showInDock)
        """
    }
}

extension GeneralPreferences: Codable {
    private enum CodingKeys: String, CodingKey {
        case automaticallyLaunch
        case showInDock
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.automaticallyLaunch = try values.decodeIfPresent(Bool.self, forKey: .automaticallyLaunch) ?? true
        self.showInDock = try values.decodeIfPresent(Bool.self, forKey: .showInDock) ?? true
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.automaticallyLaunch, forKey: .automaticallyLaunch)
        try container.encode(self.showInDock, forKey: .showInDock)
    }
}
