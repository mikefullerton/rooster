//
//  SoundIdentifier.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/5/21.
//

import Foundation

struct SoundFileDescriptor: CustomStringConvertible, Equatable, Identifiable {
    
    typealias ID = String
    
    enum RandomizerPriority : String {
        case never = "never"
        case normal = "normal"
        case high = "high"
    }
    
    let id: String
    let randomizerPriority: RandomizerPriority
    
    static let AnySoundIdentifier = "*"
 
    init() {
        self.init(with: "", randomizerPriority: .never)
    }
    
    init(with id: String,
         randomizerPriority: RandomizerPriority) {
        self.id = id
        self.randomizerPriority = randomizerPriority
    }
    
    static func == (lhs: SoundFileDescriptor, rhs: SoundFileDescriptor) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.randomizerPriority == rhs.randomizerPriority
    }
    
    var description: String {
        return "\(type(of:self)): id: \(self.id), randomizerPriority: \(self.randomizerPriority.rawValue)"
    }
    
    var isAnyRandomSound: Bool {
        return self.id == Self.AnySoundIdentifier
    }
    
    static var random: SoundFileDescriptor {
        return SoundFileDescriptor(with: Self.AnySoundIdentifier, randomizerPriority: .normal)
    }
}

extension SoundFileDescriptor {
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case randomizerPriority = "randomizerPriority"
    }
    
    init?(withDictionary dictionary: [AnyHashable : Any]) {
        if let randomizerPriorityRawValue = dictionary[CodingKeys.randomizerPriority.rawValue] as? String,
           let id = dictionary[CodingKeys.id.rawValue] as? String {
            
            let randomizerPriority = RandomizerPriority(rawValue: randomizerPriorityRawValue)!
            
            self.init(with: id, randomizerPriority: randomizerPriority)
        } else {
            return nil
        }
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.id.rawValue] = self.id
        dictionary[CodingKeys.randomizerPriority.rawValue] = self.randomizerPriority.rawValue
        return dictionary
    }
}

