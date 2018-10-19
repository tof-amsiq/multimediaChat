//
//  ImageViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 10/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    class var reuseableCellidentifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.blue.cgColor
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        }
    
    
    
    func setup(type: messageType, path: String, index: Int, image: UIImage?) {
        if index % 2 == 0 {
            self.viewLeadingConstraint.constant = 50
        } else {
            self.viewTrailingConstraint.constant = 50
        }
        if type == .gif {
            let imageURL = UIImage.gifImageWithURL(path)
            
            self.imageView.image = imageURL
            self.layoutIfNeeded()
        } else if type == .photo {
            
            if FileManager.default.fileExists(atPath: path) {
                let url = URL(string: path)!
                let data = try? Data(contentsOf: url)
                imageView.image = UIImage(data: data!)
            } else {
                imageView.image = image!
            }
        }
        
    }

}
