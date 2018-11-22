//
//  TextViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 16/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import UIKit

class TextViewCell: UICollectionViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var containerTextView: UIView!
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel.numberOfLines = 0
        self.textLabel.textColor = .white
        // Initialization code
        
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
    
    
    func setup(text: String, isSender: Bool) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm"
       let date = dateFormatterGet.string(from: Date())
        self.dateLabel.text = date
        if isSender {
            self.textLeadingConstraint.constant = 50
            self.textTrailingConstraint.constant = 0
            self.setupView(withColor: UIColor.blue.cgColor, secoundColor: .blue)
        } else {
            self.textTrailingConstraint.constant = 50
            self.textLeadingConstraint.constant = 0
            self.setupView(withColor: UIColor.green.cgColor, secoundColor: .green)
        }
        
        self.textLabel.text = text
    }

    
    func setupView(withColor: CGColor, secoundColor: UIColor ) {
        self.containerTextView.layer.borderWidth = 2
        self.containerTextView.layer.masksToBounds = false
        self.containerTextView.layer.borderColor = withColor
        self.containerTextView.layer.cornerRadius = 18
        self.containerTextView.clipsToBounds = true
        self.containerTextView.backgroundColor = secoundColor
        self.layoutIfNeeded()
    }
}

