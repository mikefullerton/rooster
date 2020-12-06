//
//  DictionaryCodable.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation

protocol DictionaryCodable {

    init?(withDictionary dictionary: [AnyHashable: Any])
    
    var asDictionary:[AnyHashable: Any] { get }

}
