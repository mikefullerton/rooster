//
//  SoundPickerTableViewCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

class SoundPickerTableViewCell : UITableViewCell, TableViewRowCell {
    
    typealias DataType = URL
    
    private var url: URL?
    private var soundIndex: SoundPreference.SoundIndex = .sound1
    
    func configureCell(withData data: URL, indexPath: IndexPath, isSelected: Bool) {
        self.url = data
        self.playButton.url = url
        self.playButton.isEnabled = true
        
        if let fileName = self.url?.soundName {
            self.titleView.text = fileName
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.url = nil
        self.playButton.url = nil
    }
    
    static var cellHeight: CGFloat {
        return 32.0
    }
    
    let buttonHeight:CGFloat = 20

    lazy var titleView: UILabel = {
        let titleView = UILabel()
        titleView.isUserInteractionEnabled = false
        titleView.textColor = UIColor.secondaryLabel
        titleView.textAlignment = .left
//        titleView.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        
        self.contentView.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 40),
            titleView.trailingAnchor.constraint(equalTo: self.playButton.leadingAnchor, constant: 20),
            titleView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])

        return titleView
    }()
    
    lazy var playButton: PlaySoundButton = {
        
        let button = PlaySoundButton()

        self.contentView.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        
//        let size = button.sizeThatFits(self.contentView.bounds.size)
        
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            button.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

//            button.widthAnchor.constraint(equalToConstant: size.width),
//            button.heightAnchor.constraint(equalToConstant: size.height)
        ])

        return button
    }()
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set(selected) {
            super.isSelected = selected
            self.titleView.isHighlighted = selected
        }
    }
}
