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
    
    
    func setup(type: messageType, path: String, isSender: Bool, isSent: Bool?) {
        var constantSize: CGFloat = 0.0
        if let _isSent = isSent, _isSent == false {
            self.imageView.alpha = 0.1
        }
        
        if ( UIDevice.current.model.range(of: "iPad") != nil){
           constantSize = 200
        } else {
            constantSize = 50
        }
        
        self.dateLabel.text = "\(Date())"
        if isSender {
            self.viewLeadingConstraint.constant = constantSize
            self.setupView(withColor: UIColor.blue.cgColor)
        } else {
            self.viewTrailingConstraint.constant = constantSize
            self.setupView(withColor: UIColor.green.cgColor)
        }
        if type == .gif {
//            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(videoPlayer(tapGestureRecognizer:)))
//            self.imageView.isUserInteractionEnabled = true
//            self.imageView.addGestureRecognizer(tapGestureRecognizer)
//
            if let url = URL(string: path ) {
                Nuke.loadImage(
                    with: url,
                    options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)),
                    into: imageView,
                    completion: { [weak self] _, _ in
                })
                
               
            }
        } else if type == .photo {
            
            if self.verifyUrl(urlString: path) {
                if let url = URL(string: path){
                    debugPrint("URL")
                    Nuke.loadImage(
                        with: url,
                        options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)),
                        into: self.imageView,
                        completion: { [weak self] _, _ in
                    })
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
            
            
            
//            let dataDecoded : Data = Data(base64Encoded: path, options: .ignoreUnknownCharacters)!
//            let decodedimage = UIImage(data: dataDecoded)
//            do {
//                let imageData = try Data(contentsOf: URL(string: path)!)
//                self.imageView.image = UIImage(data: imageData)
//            } catch {
//                print("Error loading image : \(error)")
//            }
            
//            if let url = URL(string: path) {
//
////                  let scaleImage = self.resizeImageWithAspect(image: image, scaledToMaxWidth: 250, maxHeight: 300)
//                Nuke.loadImage(
//                    with: url,
//                    options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)),
//                    into: self.imageView,
//                    completion: { [weak self] _, _ in
//                })
//
//            }
          
//
//            imageView.image = scaleImage
        
            
//            if FileManager.default.fileExists(atPath: path) {
//                let url = URL(string: path)!
//                let data = try? Data(contentsOf: url)
//                imageView.image = UIImage(data: data!)
//            } else {
//                imageView.image = image!
//            }
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
