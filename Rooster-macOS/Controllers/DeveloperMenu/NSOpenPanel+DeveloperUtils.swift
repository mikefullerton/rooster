//
//  NSOpenPanel+DeveloperUtils.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/1/21.
//

import Cocoa
import Foundation
import RoosterCore
import UniformTypeIdentifiers

extension NSOpenPanel {
    static var workspace: URL {
        URL(withRelativePath: "Rooster.xcworkspace")
    }

    static func findRoosterProjectDirectory() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false

        if let workspaceType = UTType(filenameExtension: Self.workspace.pathExtension, conformingTo: .package) {
            openPanel.allowedContentTypes = [ workspaceType ]
        }

        openPanel.title = "Find \(Self.workspace)"
        openPanel.prompt = "Choose"
        openPanel.message = openPanel.title
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                guard url.lastPathComponent == Self.workspace.lastPathComponent,
                      FileManager.default.directoryExists(atURL: url) else {
                    self.showErrorAlert(withMessage: "This doesn't seem to be \(Self.workspace)",
                                        info: "Are you sure you chose the right file?")
                    return nil
                }

                return url.deletingLastPathComponent()
            }
        }

        return nil
    }

    static func showErrorAlert(withMessage message: String, info: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = info
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
