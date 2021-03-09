//
//  DeveloperController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation
import RoosterCore
import Cocoa

extension AppDelegate {

    
    
    func showDeveloperMenuIfNeeded() {
        if  UserDefaults.standard.bool(forKey: "developer"),
            let mainMenu = NSApp.mainMenu {
            mainMenu.addItem(self.createDeveloperMenu())
        }
    }

    func createDeveloperMenu() -> NSMenuItem {
        
        let developerMenuItem = NSMenuItem(title: "Developer", action: nil, keyEquivalent: "")
        let developerMenu = NSMenu(title: "Developer")
        
        developerMenuItem.submenu = developerMenu
        
        developerMenu.addItem(NSMenuItem(title: "Test Sending Apple Event to Notes",
                                         action: #selector(testSendAppleEventToNotes(_:)),
                                         keyEquivalent: ""))
  
        developerMenu.addItem(NSMenuItem(title: "Regenerate Sound SideCar files",
                                         action: #selector(regenerateSideCars(_:)),
                                         keyEquivalent: ""))
        
        
        return developerMenuItem
    }
    
//    @IBAction func updateSoundMetaData(_ sender: Any) {
//        let action = SoundMetaDataUpdater()
//        action.run()
//    }

    @IBAction func testSendAppleEventToNotes(_ sender: Any) {
        
        let date = Date().shortDateAndTimeString
        
        let script = """
        tell application "Notes"
            tell account "Apple"
                make new note at folder "Notes" with properties {name:"Meeting agenda: \(date)", body:"and more text"}
            end tell
        end tell
        """
        
        let applescript = NSAppleScript(source: script)
        
        var errorInfo: NSDictionary?
        let descriptor = applescript?.executeAndReturnError(&errorInfo)
        
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
    
    @IBAction func regenerateSideCars(_ sender: Any) {
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
                
            } catch let error {
                self.logger.error("\(String(describing:error))")
            }
            
          
            
        }
    }
}
