//
//  FileManager+Utilities.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

extension FileManager {
    
    func directoryExists(atPath path: String) -> Bool {
        var isDir : ObjCBool = false
        return FileManager.default.fileExists(atPath:path, isDirectory: &isDir) && isDir.boolValue == true
    }
    
    func directoryExists(atURL url: URL) -> Bool {
        return self.directoryExists(atPath: url.path)
    }
    

}
