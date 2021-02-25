//
//  DeveloperController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation
import Cocoa

extension AppDelegate {
    
    func showDeveloperMenuIfNeeded() {
        let mainMenu = NSApplication.shared.mainMenu
        let developerMenu = mainMenu?.item(withTag: 999)
        developerMenu?.isHidden = UserDefaults.standard.bool(forKey: "developer") == false
    }

    @IBAction @objc func updateSoundMetaData(_ sender: Any) {
        let action = SoundMetaDataUpdater()
        action.run()
    }

    @IBAction @objc func developerTest(_ sender: Any) {
        
        let date = Date().shortDateAndTimeString
        
        let script = """
        tell application "Notes"
            tell account "Apple"
                make new note at folder "Notes" with properties {name:"Meeting agenda: \(date)", body:"and more text"}
            end tell
        end tell
        """
        
        let applescript = NSAppleScript(source: script)
        
        var errorInfo: NSDictionary? = nil
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
}
