//
//  ImageViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 10/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import Nuke
import Gifu
import UIKit

class ImageViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: GIFImageView!
    class var reuseableCellidentifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
        }
    
    
    
    func setup(type: messageType, path: String, image: UIImage?, isSender: Bool) {
        
        self.dateLabel.text = "\(Date())"
        if isSender {
            self.viewLeadingConstraint.constant = 50
            self.setupView(withColor: UIColor.blue.cgColor)
        } else {
            self.viewTrailingConstraint.constant = 50
            self.setupView(withColor: UIColor.green.cgColor)
        }
        if type == .gif {
//            let imageURL = UIImage.gifImageWithURL(path)
//            self.imageView.image = imageURL
//            self.layoutIfNeeded()
            
            if let url = URL(string: path ) {
                Nuke.loadImage(
                    with: url,
                    options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)),
                    into: imageView,
                    completion: { [weak self] _, _ in
                })
            }
        } else if type == .photo {
            
            let dataDecoded : Data = Data(base64Encoded: path, options: .ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded)
            imageView.image = decodedimage
            
//            if FileManager.default.fileExists(atPath: path) {
//                let url = URL(string: path)!
//                let data = try? Data(contentsOf: url)
//                imageView.image = UIImage(data: data!)
//            } else {
//                imageView.image = image!
//            }
        }
        
    }
    
    func setupView(withColor: CGColor){
    imageView.layer.borderWidth = 3
    imageView.layer.masksToBounds = false
    imageView.layer.borderColor = withColor
    imageView.layer.cornerRadius = 30
    imageView.clipsToBounds = true
    }

}
