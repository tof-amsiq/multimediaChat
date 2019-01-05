//
//  ReceiverViewCell.swift
//  CollectionView
//
//  Created by Tobias Frantsen on 14/09/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import UIKit

class ReceiverViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UILabel!
    
    private var type: messageType?
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(type: messageType, path: String?, image: UIImage?){
        var data = ""
        switch type {
        case .text:
            data = "this is normal text"
        case .gif:
            data = "this is gif"
            if let _path = path, path != "unknow" {
                let _gifURL: String = _path
                let imageURL = UIImage.gifImageWithURL(_gifURL)
                self.imageView.image = imageURL
                self.layoutIfNeeded()
            } else {
                let _gifURL: String = "https://media.giphy.com/media/Z4Sek3StLGVO0/giphy.gif"
                let imageURL = UIImage.gifImageWithURL(_gifURL)
                self.imageView.image = imageURL
                self.layoutIfNeeded()
            }
            
        case .photo:

            data = "this is photo"
            if let _image = image {
             self.imageView.image = _image
            }
        case .video:
            data = "this is video"
        case .audio:
            data = "this is aduio"
        case .file:
            
            imageView.image = UIImage(named: "icon")
            if let _path = path , path != "unknow" {
                data = _path

            } else {
                data = "this is file"
            }
            
            
        case .linkPreView:
            break
        case .unknow:
            break
       
        }
        imageView.backgroundColor = .black
        if type == .file {
            let underlineAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
            let underlineAttributedString = NSAttributedString(string: data, attributes: underlineAttribute)
            textView.attributedText = underlineAttributedString
        } else {
            textView.text = data
        }
    }
    
    private func load(fileName: String) -> UIImage? {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }

}
