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
        
        self.addSubview(self.tipImage)
        self.addSubview(self.textField)
        
        self.layout.setViews([
            self.tipImage,
            self.textField
        ])
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
//        view.frame = CGRect(x: 0,y: 0,width: self.imageSize, height: self.imageSize)
        return view
    }()
        
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.layout.intrinsicContentSize.height)
    }
    
    lazy var layout: HorizontalViewLayout = {
        return HorizontalViewLayout(hostView: self,
                                    insets: UIEdgeInsets(top: 2, left: 20, bottom: 10, right: 0),
                                    spacing: UIOffset(horizontal: 20, vertical: 20))
        
    }()
}
