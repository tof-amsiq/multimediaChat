//
//  GifCell.swift
//  CollectionView
//
//  Created by Tobias Frantsen on 26/09/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import UIKit

class GifCell: UICollectionViewCell {
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
