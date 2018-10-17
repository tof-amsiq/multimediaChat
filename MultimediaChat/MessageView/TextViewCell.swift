//
//  TextViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 16/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import UIKit

class TextViewCell: UICollectionViewCell {

    @IBOutlet weak var containerTextView: UIView!
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLabel: UILabel!
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textLabel.numberOfLines = 0
        self.textLabel.textColor = .white
        self.containerTextView.layer.borderWidth = 2
        self.containerTextView.layer.masksToBounds = false
        self.containerTextView.layer.borderColor = UIColor.blue.cgColor
        self.containerTextView.layer.cornerRadius = 18
        self.containerTextView.clipsToBounds = true
        self.containerTextView.backgroundColor = .blue
        
    }
  
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        setNeedsLayout()
//        layoutIfNeeded()
//        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//        var frame = layoutAttributes.frame
//        frame.size.height = ceil(size.height)
//        layoutAttributes.frame = frame
//        return layoutAttributes
//
//    }
    
    
    func setup(text: String, index: Int) {
        if index % 2 == 0 {
            self.textLeadingConstraint.constant = 50
        } else {
            self.textTrailingConstraint.constant = 50
        }
        
        self.textLabel.text = text
    }

}

