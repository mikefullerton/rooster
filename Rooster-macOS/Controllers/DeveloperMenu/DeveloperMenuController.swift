//
//  DeveloperController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Cocoa
import Foundation
import RoosterCore

public class DeveloperMenuController: Loggable {
    func showDeveloperMenuIfNeeded() {
        if  UserDefaults.standard.bool(forKey: "developer"),
            let mainMenu = NSApp.mainMenu {
            mainMenu.addItem(self.createDeveloperMenu())
        }
    }

    private func createDeveloperMenu() -> NSMenuItem {
        let developerMenuItem = NSMenuItem(title: "Developer", action: nil, keyEquivalent: "")
        let developerMenu = NSMenu(title: "Developer")

        developerMenuItem.submenu = developerMenu

        developerMenu.addItem(MenuItem(title: "Test Sending Apple Event to Notes") { [weak self] _ in
            self?.testSendAppleEventToNotes()
        })

        developerMenu.addItem(MenuItem(title: "Regenerate Sound SideCar files") { [weak self] _ in
            self?.regenerateSideCars()
        })
        return developerMenuItem
    }

    private func testSendAppleEventToNotes() {
        let date = Date().shortDateAndTimeString

        let script = """
        tell application "Notes"
            tell account "Apple"
                make new note at folder "Notes" with properties {name:"Meeting agenda: \(date)", body:"and more text"}
            end tell
        end tell
        """

        let applescript = NSAppleScript(source: script)

        // swiftlint:disable legacy_objc_type
        var errorInfo: NSDictionary?
        let descriptor = applescript?.executeAndReturnError(&errorInfo)
        // swiftlint:enable legacy_objc_type

        print("\(String(describing: descriptor)))")
        print("\(String(describing: errorInfo)))")

        /*

         NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:
         @"\
         set app_path to path to me\n\
         tell application \"System Events\"\n\
         if \"AddLoginItem\" is not in (name of every login item) then\n\
         make login item at end with properties {hidden:false, path:app_path}\n\
         end if\n\
         end tell"];

         returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
         */
    }

    private func regenerateSideCars() {
        if let roosterURL = NSOpenPanel.findRoosterProjectDirectory() {
            do {
                let soundsURL = roosterURL.appendingPathComponent("Rooster-Shared/Resources/Sounds")

                let iterator = DirectoryIterator(withURL: soundsURL)
                try iterator.scan()

                iterator.visitEach { item, _ in
                    do {
                        if  item.exists,
                            item.url.pathExtension.contains("roosterSound") ||
                                item.url.pathExtension.contains("roosterFolder") {
                            try item.delete()
                        }
                    } catch {
                    }
                }

                try iterator.scan()

                let soundFolder = try SoundFolder(withCreatingDescriptorsInDirectory: iterator,
                                                  withID: SoundFolder.defaultSoundFolderID)

                self.logger.log("Created folder ok: \(soundFolder)")
            } catch {
                self.logger.error("\(String(describing: error))")
            }
        }
    }
}
