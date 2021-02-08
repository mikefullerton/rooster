//
//  SoundMetaDataUpdater.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

class SoundMetaDataUpdater: DeveloperAction {
    
    let soundsPath = "Resources/Sounds"
    
    func run() {
    
        if let roosterURL = self.findRoosterProjectDirectory() {
            let soundsURL = roosterURL.appendingPathComponent(self.soundsPath)
            guard FileManager.default.directoryExists(atURL: soundsURL) else {
                self.showErrorAlert(withMessage: "Can't find Sounds folder!", info: "WTH!")
                return
            }
            
            do {
                    
                let dir = try Directory(withID: soundsURL.absoluteString, url: soundsURL)
                
                print("\(dir.description)")
                
            } catch {
                self.showErrorAlert(withMessage: "\(error)", info: "")
            }
            
        }
    }
}
