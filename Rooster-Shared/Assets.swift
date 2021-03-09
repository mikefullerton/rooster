//
//  Assets.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/13/21.
//

import Foundation

public enum Assets {
}

extension Assets {
    // MARK: - reminders

    public static var incompleteImage: NSImage {
        NSImage.image(withSystemSymbolName: "square",
                      accessibilityDescription: "complete reminder",
                      symbolConfiguration: NSImage.SymbolConfiguration(scale: .large))!
    }

    public static var completionImage: NSImage {
        NSImage.image(withSystemSymbolName: "checkmark.square",
                      accessibilityDescription: "complete reminder",
                      symbolConfiguration: NSImage.SymbolConfiguration(scale: .large))!
    }

    public static var noPriorityImage: NSImage {
        NSImage.image(withSystemSymbolName: "minus",
                      accessibilityDescription: "complete reminder",
                      symbolConfiguration: nil )! // NSImage.SymbolConfiguration(scale: .medium)
    }

    public static var lowPriorityImage: NSImage {
        NSImage.image(withSystemSymbolName: "exclamationmark",
                      accessibilityDescription: "complete reminder",
                      symbolConfiguration: NSImage.SymbolConfiguration(scale: .medium))!
    }

    public static var mediumPriorityImage: NSImage {
        NSImage.image(withSystemSymbolName: "exclamationmark.2",
                      accessibilityDescription: "complete reminder",
                      symbolConfiguration: NSImage.SymbolConfiguration(scale: .medium))!
    }

    public static var highPriorityImage: NSImage {
        NSImage.image(withSystemSymbolName: "exclamationmark.3",
                      accessibilityDescription: "complete reminder",
                      symbolConfiguration: NSImage.SymbolConfiguration(scale: .medium))!
    }

    public static var redRoosterImage: NSImage? {
        if let image = Bundle.main.image(forResource: NSImage.Name("RedRoosterIcon")) {
            image.size = CGSize(width: 26, height: 26)
            return image.tint(color: NSColor.systemRed)
        }

        return nil
    }

    public static var whiteRoosterImage: NSImage? {
        if let image = Bundle.main.image(forResource: NSImage.Name("RedRoosterIcon")) {
            image.size = CGSize(width: 26, height: 26)
            image.isTemplate = true
            return image.tint(color: NSColor.white)
        }

        return nil
    }

    public static var yellowRoosterImage: NSImage? {
        if let image = Bundle.main.image(forResource: NSImage.Name("RedRoosterIcon")) {
            image.size = CGSize(width: 26, height: 26)
            image.isTemplate = true
            return image.tint(color: NSColor.systemYellow)
        }

        return nil
    }

    public static var questionImage: NSImage {
        NSImage.image(withSystemSymbolName: "questionmark.square",
                      accessibilityDescription: "complete reminder",
                      symbolConfiguration: NSImage.SymbolConfiguration(scale: .large))!
    }
}
