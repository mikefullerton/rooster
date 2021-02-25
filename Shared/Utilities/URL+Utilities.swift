//
//  URL+Utilities.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

extension URL {
    var fileName: String {
        return self.deletingPathExtension().lastPathComponent
    }
    
    static var emptyRoosterURL: URL {
        return self.roosterURL("empty")
    }
    
    static func roosterURL(_ string: String) -> URL {
        
        let encodedString = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return URL(string:"rooster:\(encodedString)")!
    }
    
    var isRoosterURL: Bool {
        return self.absoluteString.contains("rooster")
    }
    
    func url(fromURL url: URL) -> URL? {
        
        let path = self.path;
        let parentPath = url.path;
        
        let finalPath = path.replacingOccurrences(of: parentPath, with: "")
        
        return URL(fileURLWithPath: finalPath)
    }
    
    func fullURL(relativeTo url: URL) -> URL? {
        return URL(fileURLWithPath: self.path, relativeTo: url)
    }
}
