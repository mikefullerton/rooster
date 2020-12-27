//
//  SoundChoicesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

class SoundChoicesView : GroupBoxView {
    
    init() {
        super.init(frame: CGRect.zero,
                  title: "Sounds" )
        
        self.addTopSubview(view: self.firstSoundChoice)
        self.addSubview(view: self.secondSoundChoice, belowView: self.firstSoundChoice)
        self.addSubview(view: self.thirdSoundChoice, belowView: self.secondSoundChoice)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var firstSoundChoice: UIView = {
        let view = SoundChoiceView(frame: CGRect.zero,
                                   soundPreferenceIndex: 0)
        
        return view
    }()

    lazy var secondSoundChoice: UIView = {
        let view = SoundChoiceView(frame: CGRect.zero,
                                   soundPreferenceIndex: 1)

        return view
    }()

    lazy var thirdSoundChoice: UIView = {
        let view = SoundChoiceView(frame: CGRect.zero,
                                   soundPreferenceIndex: 2)

        
        return view
    }()
}
