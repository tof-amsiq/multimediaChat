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
        
        self.containerView.layer.borderWidth = 2
        self.containerView.layer.masksToBounds = false
        self.containerView.layer.borderColor = UIColor.blue.cgColor
        self.containerView.layer.cornerRadius = 18
        self.containerView.clipsToBounds = true
    }

    
    func setup(index: Int, nameOfFile: String, path: String) {
    
        if index % 2 == 0 {
            self.viewLeadingConstraint.constant = 50
        } else {
            self.viewTrailingConstraint.constant = 50
        }
        let lengthOfText = nameOfFile.count
        let attributedString = NSMutableAttributedString(string: nameOfFile)
        attributedString.addAttribute(.link, value: path, range: NSRange(location: 0, length: lengthOfText))
        

        
        textLabel.attributedText = attributedString
        textLabel.textColor = .white
        
        self.imagView.image = #imageLiteral(resourceName: "icon")
//        self.textLabel.text = "
    }
}
