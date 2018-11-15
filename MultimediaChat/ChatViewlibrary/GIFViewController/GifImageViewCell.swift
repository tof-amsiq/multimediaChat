//
//  GifImageViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 14/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import UIKit

class GifImageViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func setup (gifURL: String) {
        let _gifURL: String = gifURL
        let imageURL = UIImage.gifImageWithURL(_gifURL)
        self.imageView.image = imageURL
        
        
    }
}


