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
            
    private static let soundFolderLoader = SoundFolderLoader(withPath: SoundFolder.resourceSoundFolderPath)
    
    public static var instance: SoundFolder {
        return self.soundFolderLoader.soundFolder
    }
    
    public static var defaultSoundFolderID = "de94d3de-5a26-4fda-9db8-384744844b69"
    
    public var isDefaultSoundFolder: Bool {
        return self.id == Self.defaultSoundFolderID
    }
    
    public static func startLoadingDefaultSoundFolder() {
        self.soundFolderLoader.startLoading()
    }
}

