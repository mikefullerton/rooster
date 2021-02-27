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
    
    private var semaphore = DispatchSemaphore(value: 1)
    
    init(withPath path: URL? ) {
        self.loadedFolder = nil
        self.path = path
        
        if path == nil {
            self.semaphore.signal()
            self.loadedFolder = SoundFolder.empty
        }
    }
    
    public func startLoading() {

        let url = self.path!
        
        self.logger.log("Starting to load sound folder for url: \(url.path)")

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let strongSelf = self {
                do {
                    let directory = try DirectoryIterator(withURL: url)
                    let soundFolder = try SoundFolder(withDirectory: directory)
                    strongSelf.loadedFolder = soundFolder
                    strongSelf.logger.log("Creating SoundFolder ok: \(soundFolder.description)")
                    
                } catch {
                    strongSelf.logger.error("Creating SoundFolder failed with error: \(error.localizedDescription)")
                    strongSelf.loadedFolder = SoundFolder.empty
                    
                }
                strongSelf.semaphore.signal()
            }
        }
    }
    
    public var soundFolder: SoundFolder {
        self.semaphore.wait()
        return self.loadedFolder!
    }
}
