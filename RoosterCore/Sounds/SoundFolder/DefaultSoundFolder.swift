//
//  DefaultSoundFolder.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/27/21.
//

import Foundation

extension SoundFolder {

    private static var resourceSoundFolderPath: URL? {
        if  let resourcePath = Bundle.main.resourceURL {
            return resourcePath.appendingPathComponent("Sounds")
        }
        
        return nil
    }
            
    private static var _instance: SoundFolder? = nil
    
    public static var instance: SoundFolder {
        
        guard let instance = _instance else {
            self.logger.warning("Accessing SoundFolder.instance before it's loaded")
            return SoundFolder.empty
        }
        
        return instance
    }
    
    public static var defaultSoundFolderID = "de94d3de-5a26-4fda-9db8-384744844b69"
    
    public var isDefaultSoundFolder: Bool {
        return self.id == Self.defaultSoundFolderID
    }
    
    public static func startLoadingDefaultSoundFolder() {
        SoundFolder.load(soundFolderAtPath: SoundFolder.resourceSoundFolderPath) { (soundFolderOrNil, error) in
            if let soundFolder = soundFolderOrNil {
                Self._instance = soundFolder
                Self.logger.log("Set default sound folder: \(soundFolder.description)")
            } else {
                Self.logger.error("Setting default sound folder failed with error: \(error?.localizedDescription ?? "nil")")
            }
        }
    }
}

