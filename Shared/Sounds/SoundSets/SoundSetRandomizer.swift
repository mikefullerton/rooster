//
//  SoundSetRandomizer.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/8/21.
//

import Foundation

struct SoundSetRandomizer: CustomStringConvertible {
    
    enum Priority : String {
        case none = "none"
        case never = "never"
        case normal = "normal"
        case high = "high"
    }
   
    let priority: Priority
    
    private init() {
        self.priority = .none
    }
    
    init(withPriority priority: Priority) {
        self.priority = priority
    }
    
    var description: String {
        return "\(type(of:self)): priority: \(self.priority.rawValue)"
    }
    
    static var none = SoundSetRandomizer()
}

extension SoundSetRandomizer {
    
    enum CodingKeys: String, CodingKey {
        case priority = "priority"
    }
    
    init?(withDictionary dictionaryOrNil: [AnyHashable : Any]?) {
        if let dictionary = dictionaryOrNil,
           let priority = dictionary[CodingKeys.priority.rawValue] as? String {
            self.init(withPriority: Priority(rawValue: priority) ?? .never)
        } else {
            return nil
        }
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.priority.rawValue] = self.priority.rawValue
        return dictionary
    }
}
