//
//  SoundChoicesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

class SoundChoicesView : GroupBoxView {
    
    init(frame: CGRect) {
        super.init(frame: frame,
                  title: "Sounds" )
        
        self.layout.addSubview(self.firstSoundChoice)
        self.layout.addSubview(self.secondSoundChoice)
        self.layout.addSubview(self.thirdSoundChoice)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var firstSoundChoice: UIView = {
        let view = SoundChoiceView(frame: self.bounds,
                                   soundPreferenceIndex: 0)
        
        return view
    }()

    lazy var secondSoundChoice: UIView = {
        let view = SoundChoiceView(frame: self.bounds,
                                   soundPreferenceIndex: 1)

        return view
    }()

    lazy var thirdSoundChoice: UIView = {
        let view = SoundChoiceView(frame: self.bounds,
                                   soundPreferenceIndex: 2)

        
        return view
    }()
}
