//
//  FileViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 22/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
// viewleadingC

import UIKit

class FileViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var viewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imagView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       
    }

    
    func setup(isSender: Bool, nameOfFile: String, path: String) {
    
        if isSender {
            self.viewLeadingConstraint.constant = 50
            self.setupView(withColor: UIColor.blue.cgColor)
        } else {
            self.viewTrailingConstraint.constant = 50
            self.setupView(withColor: UIColor.green.cgColor)
        }
        let lengthOfText = nameOfFile.count
        let attributedString = NSMutableAttributedString(string: nameOfFile)
        attributedString.addAttribute(.link, value: path, range: NSRange(location: 0, length: lengthOfText))
        

        
        textLabel.attributedText = attributedString
        textLabel.textColor = .white
        
        self.imagView.image = #imageLiteral(resourceName: "icon")
//        self.textLabel.text = "
    }
    
    func setupView(withColor: CGColor) {
        self.containerView.layer.borderWidth = 2
        self.containerView.layer.masksToBounds = false
        self.containerView.layer.borderColor = withColor
        self.containerView.layer.cornerRadius = 18
        self.containerView.clipsToBounds = true
    }
}
