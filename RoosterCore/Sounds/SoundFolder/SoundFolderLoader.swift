//
//  SoundFolderLoader.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/27/21.
//

import Foundation

class SoundFolderLoader: Loggable {

    private var loadedFolder: SoundFolder?
    private var path: URL?
    
    private var folderLoadingSemaphore: DispatchSemaphore?
    
    init(withPath path: URL? ) {
        self.loadedFolder = nil
        self.path = path
        
        if path == nil {
            self.loadedFolder = SoundFolder.empty
        }
       
        self.folderLoadingSemaphore = DispatchSemaphore(value: 1)
    }
    
    public func startLoading() {

        let url = self.path!
        
        
        self.logger.log("Starting to load sound folder for url: \(url.path)")

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let strongSelf = self {
                do {
                    let directory = DirectoryIterator(withURL: url)
                    try directory.scan()
                    
                    let soundFolder = try SoundFolder(withDirectory: directory)
                    strongSelf.loadedFolder = soundFolder
                    strongSelf.logger.log("Creating SoundFolder ok: \(soundFolder.description)")
                    
                } catch {
                    strongSelf.logger.error("Creating SoundFolder failed with error: \(error.localizedDescription)")
                    strongSelf.loadedFolder = SoundFolder.empty
                    
                }
                strongSelf.folderLoadingSemaphore?.signal()
            }
        }
    }
    
    public var soundFolder: SoundFolder {
        if let semaphore = self.folderLoadingSemaphore {
            self.logger.log("Waiting for folder to load...")
            semaphore.wait()
            self.folderLoadingSemaphore = nil
            self.logger.log("Done loading...")
        }
        
        return self.loadedFolder!
    }
}
