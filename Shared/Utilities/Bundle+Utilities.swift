//
//  Bundle+Utilities.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

extension Bundle {
    
    static var availableSoundResources: [URL] = {
        let bundle = Bundle.main
        if let resourcePath = bundle.resourceURL {
            let soundsPath = resourcePath.appendingPathComponent("Sounds")
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: soundsPath.path)
                
                var outUrls:[URL] = []
                
                for file in contents {
                    if file.hasPrefix(".") {
                        continue
                    }
                    outUrls.append(soundsPath.appendingPathComponent(file))
                }
                
                return outUrls
            } catch {
            }
        }
        return []
    }()
    
}

extension URL {
    var fileName: String {
        return self.deletingPathExtension().lastPathComponent
    }
}
