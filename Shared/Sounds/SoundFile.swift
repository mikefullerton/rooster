//
//  SoundFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation

struct SoundFile: CustomStringConvertible, Identifiable, Equatable {
    typealias ID = String
    
    let id: String
    let url: URL?
    let displayName: String
    let randomizer: SoundSetRandomizer
    
    init() {
        self.init(withID: "",
                  url: nil,
                  displayName: "",
                  randomizer: SoundSetRandomizer.none)
    }

    init(withID id: String,
         url: URL?,
         displayName: String,
         randomizer: SoundSetRandomizer) {
        self.url = url
        self.id = id
        self.displayName = displayName
        self.randomizer = randomizer
    }

    var description: String {
        return "\(type(of:self)): \(self.id), displayName: \(self.displayName), url: \(self.url?.path ?? "nil"), randomizer: \(self.randomizer.description))"
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
        case randomizer = "randomizer"
    }
    
    init?(withDictionary dictionaryOrNil: [AnyHashable : Any]?) {
        if let dictionary = dictionaryOrNil,
          let id = dictionary[CodingKeys.id.rawValue] as? String,
           let url = dictionary[CodingKeys.url.rawValue] as? String,
           let displayName = dictionary[CodingKeys.displayName.rawValue] as? String,
           let randomizer = SoundSetRandomizer(withDictionary: dictionary[CodingKeys.randomizer.rawValue] as? [AnyHashable: Any]) {
            
            self.init(withID: id, url: URL(fileURLWithPath: url), displayName: displayName, randomizer: randomizer)
        } else {
            return nil
        }
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.id.rawValue] = self.id
        dictionary[CodingKeys.url.rawValue] = self.url?.path ?? ""
        dictionary[CodingKeys.displayName.rawValue] = self.displayName
        dictionary[CodingKeys.randomizer.rawValue] = self.randomizer.asDictionary
        
        return dictionary
    }
}
