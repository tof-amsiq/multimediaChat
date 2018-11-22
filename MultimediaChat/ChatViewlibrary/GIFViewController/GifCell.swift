//
//  GifCell.swift
//  CollectionView
//
//  Created by Tobias Frantsen on 26/09/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import UIKit
import Nuke
import NukeFLAnimatedImagePlugin
import FLAnimatedImage

class GifCell: UICollectionViewCell {
   
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imageView: FLAnimatedImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.display(image: nil)
        
    }

    public func setup (gifURL: String?) {
         self.activityIndicator.hidesWhenStopped = true

        if let url = URL(string: gifURL ?? "") {

            self.activityIndicator.startAnimating()
            Nuke.loadImage(
                with: url,
                options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)),
                into: imageView,
                completion: { [weak self] _, _ in
                    self?.activityIndicator.stopAnimating()
            })
        }
    }
}
