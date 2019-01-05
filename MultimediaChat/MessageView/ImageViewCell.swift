//
//  ImageViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 10/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import Nuke
import NukeFLAnimatedImagePlugin
import FLAnimatedImage
import UIKit

class ImageViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: FLAnimatedImageView!
    
    
    class var reuseableCellidentifier: String {
        return String(describing: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
       
        imageView.display(image: nil)
        self.imageView.alpha = 1
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
    
      
        }
//
//    @objc func videoPlayer(tapGestureRecognizer: UITapGestureRecognizer)
//    {
//      debugPrint("HALLLO")
//        self.imageView.startAnimatingGIF()
//        self.imageView.startAnimating()
//
//    }
    
    
    func setup(type: messageType, path: String, isSender: Bool, isSent: Bool?, userName: String, date: String) {
        var constantSize: CGFloat = 0.0
        if let _isSent = isSent, _isSent == false {
            self.imageView.alpha = 0.1
        }
        
        if ( UIDevice.current.model.range(of: "iPad") != nil){
           constantSize = 200
        } else {
            constantSize = 50
        }
        
        self.dateLabel.text = "\(userName) at  \(date)"
        if isSender {
            self.viewLeadingConstraint.constant = constantSize
            self.setupView(withColor: UIColor.blue.cgColor)
        } else {
            self.viewTrailingConstraint.constant = constantSize
            self.setupView(withColor: UIColor.green.cgColor)
        }
        if type == .gif {
            if let url = URL(string: path ) {
                Nuke.loadImage(
                    with: url,
                    options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)),
                    into: imageView)
                
               
            }
        } else if type == .photo {
            
            if self.verifyUrl(urlString: path) {
                if let url = URL(string: path){
                    debugPrint("URL")
                    Nuke.loadImage(
                        with: url,
                        options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)),
                        into: self.imageView)
                }
                
            } else if let decodedData = Data(base64Encoded: path, options: .ignoreUnknownCharacters) {
                debugPrint("decodedData")
                let image = UIImage(data: decodedData)
                self.imageView.image = image
            } else if FileManager.default.fileExists(atPath: path) {
                debugPrint("FileManager")
                let image = UIImage(contentsOfFile: path)
                self.imageView.image = image
            }
        }
        
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    func setupView(withColor: CGColor){
    imageView.layer.borderWidth = 3
    imageView.layer.masksToBounds = false
    imageView.layer.borderColor = withColor
    imageView.layer.cornerRadius = 30
    imageView.clipsToBounds = true
    imageView.backgroundColor = .blue
    }

    
   private func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height :CGFloat)->UIImage? {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
        
        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.main.scale);
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage
    }

}
