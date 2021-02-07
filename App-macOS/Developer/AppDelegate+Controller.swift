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

}
