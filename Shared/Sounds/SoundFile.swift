//
//  SoundFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation

class SoundFile: CustomStringConvertible, Identifiable, Equatable {
    typealias ID = String
    
    let id: String
    let url: URL?
    let displayName: String
    weak private(set) var parent: SoundFolder?
    
    init() {
        self.parent = nil
        self.url = nil
        self.id = ""
        self.displayName = ""
    }

    init(withID id: String,
         url: URL,
         displayName: String,
         parent: SoundFolder?) {
        self.parent = parent
        self.url = url
        self.id = id
        self.displayName = displayName
    }

    var description: String {
        return "\(type(of:self)): \(self.id), displayName: \(self.displayName), url: \(self.url?.path ?? "nil"), parent: \(self.parent?.id ?? "nil")"
    }

    static func == (lhs: SoundFile, rhs: SoundFile) -> Bool {
        return lhs.id == rhs.id &&
            lhs.displayName == rhs.displayName &&
            lhs.url == rhs.url &&
            lhs.displayName == rhs.displayName
    }
}

extension SoundFile {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case url = "url"
        case displayName = "displayName"
    }
    
    convenience init?(withDictionary dictionary: [AnyHashable : Any], parent: SoundFolder) {
        if let id = dictionary[CodingKeys.id.rawValue] as? String,
           let url = dictionary[CodingKeys.url.rawValue] as? String,
           let displayName = dictionary[CodingKeys.displayName.rawValue] as? String {
            
            self.init(withID: id, url: URL(fileURLWithPath: url), displayName: displayName, parent: parent)
        }
        
        return nil
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.id.rawValue] = self.id
        dictionary[CodingKeys.url.rawValue] = self.url?.path ?? ""
        dictionary[CodingKeys.displayName.rawValue] = self.displayName
        return dictionary
    }
}
