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
    let title: String
    let action: (() -> Void)?
}

class TipView : UIView {
    
    let tip: Tip
    
    var imageView: UIImageView? = nil
    var textView: UITextField? = nil
    
    init(frame: CGRect,
         tip: Tip) {
        self.tip = tip
        super.init(frame: frame)
        
        if tip.image != nil {
            self.addTipImage(tip.image!)
        }
        
        self.addTextView(tip.title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTextView(_ text: String) {
        let titleView = UITextField(frame: self.bounds)
        titleView.text = text
        titleView.isUserInteractionEnabled = false
        titleView.textColor = UIColor.secondaryLabel
        titleView.textAlignment = .left
        titleView.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        
        self.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        let size = titleView.sizeThatFits(CGSize(width: 1000, height: 1000))
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: self.imageView!.trailingAnchor, constant: 4.0),
            titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleView.widthAnchor.constraint(equalToConstant: size.width),
            titleView.heightAnchor.constraint(equalToConstant: size.height)
        ])
        
        self.textView = titleView
    }
    
    func addTipImage(_ image: UIImage) {
        let view = UIImageView(image: image)
        view.frame = self.bounds
        view.tintColor = UIColor.systemBlue
        
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageSize: CGFloat = 14.0
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            view.widthAnchor.constraint(equalToConstant: imageSize),
            view.heightAnchor.constraint(equalToConstant: imageSize)
        ])
        
        self.imageView = view
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var outSize = size
        outSize.height = self.textView!.sizeThatFits(size).height + 4
        return outSize
    }
    

}

/*
 "exclamationmark.triangle.fill"
 
 "info.circle.fill"
 */
