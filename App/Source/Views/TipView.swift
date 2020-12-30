//
//  TipView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/27/20.
//

import Foundation
import UIKit

struct Tip {
    let image: UIImage?
    let imageTintColor: UIColor?
    let title: String
    let action: (() -> Void)?
}

class TipView : UIView {
    
    let tip: Tip
    
    init(frame: CGRect,
         tip: Tip) {
        self.tip = tip
        super.init(frame: frame)
        
        self.layout.addSubview(self.tipImage)
        self.layout.addSubview(self.textField)
 }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textField: UITextField = {
        let titleView = UITextField(frame: self.bounds)
        titleView.text = self.tip.title
        titleView.isUserInteractionEnabled = false
        titleView.textColor = UIColor.secondaryLabel
        titleView.textAlignment = .left
        titleView.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        return titleView
    }()
    
    let imageSize: CGFloat = 14.0
    
    lazy var tipImage: UIImageView = {
        let view = UIImageView(image: self.tip.image)
        if self.tip.imageTintColor != nil {
            view.tintColor = self.tip.imageTintColor! // UIColor.systemBlue
        }
        view.frame = CGRect(x: 0,y: 0,width: self.imageSize, height: self.imageSize)
        return view
    }()
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var outSize = size
        outSize.height = self.layout.size.height
        return outSize
    }
    
    lazy var layout: ViewLayout = {
        return HorizontalViewLayout(hostView: self,
                                    insets: UIEdgeInsets(top: 2, left: 20, bottom: 10, right: 0),
                                    spacing: UIOffset(horizontal: 20, vertical: 20))
        
    }()


}

/*
 "exclamationmark.triangle.fill"
 
 "info.circle.fill"
 */
