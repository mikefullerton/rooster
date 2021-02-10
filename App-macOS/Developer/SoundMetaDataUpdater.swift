//
//  SoundMetaDataUpdater.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

class SoundMetaDataUpdater: DeveloperAction, Loggable {
    
    let soundsPath = "Resources/Sounds"
    
    func run() {
    
        if let roosterURL = self.findRoosterProjectDirectory() {
            let soundsURL = roosterURL.appendingPathComponent(self.soundsPath)
            guard FileManager.default.directoryExists(atURL: soundsURL) else {
                self.showErrorAlert(withMessage: "Can't find Sounds folder!", info: "WTH!")
                return
            }
            
//            do {
//                let dir = try DirectoryIterator(withURL: soundsURL)
//
//                let soundFolder = SoundFolder(withDirectory: dir)
//
//                let soundFolderDictionary = soundFolder.asDictionary
//
//                let soundFolderURL = soundsURL.deletingLastPathComponent().appendingPathComponent("Sounds.json")
//
//                try soundFolderDictionary.writeJSON(toURL: soundFolderURL)
                
//                print("\(soundFolder.debugDescription)")
                
//            } catch {
//                self.showErrorAlert(withMessage: "\(error)", info: "")
//            }
            
        }
    }
}
