//
//  TextLinkPreviewViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 19/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import Nuke
import SwiftLinkPreview
import UIKit

class TextLinkPreviewViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textDescription: UILabel!
    @IBOutlet weak var textTitle: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    
    private var slp: SwiftLinkPreview?
    private var result = SwiftLinkPreview.Response()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
         self.slp = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: DispatchQueue.main, cache:  DisabledCache.instance)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textDescription.numberOfLines = 0
        
        
//        self.textLabel.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        self.textTitle.padding = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
        self.textDescription.padding = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
        
    }
    
    func setup(url: String, fullText: String) {
        self.textLabel.text = fullText
        self.textTitle.font = UIFont.boldSystemFont(ofSize: 16.0)
       self.setupView()

        self.slp?.preview(url, onSuccess: { (result) in
            
                        if let url_string = result[.image] as? String {
                if let url = URL(string: url_string) {
                    
                    Nuke.loadImage(with: url, options: ImageLoadingOptions(
                        failureImage: UIImage(named: "icon" )
                    ), into: self.imageView)
                }
            }
            
            if let title = result[.title] as? String {
                self.textTitle.text = title
            }
            if let description = result[.description] as? String {
                self.textDescription.text = description
            }
            
//            let range               = (fullText as NSString).range(of: url)
//            let attributedString    = NSMutableAttributedString(string: fullText)
            
//            attributedString.addAttribute(NSAttributedStringKey.link, value: NSURL(string: url) as Any, range: range)
//            attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber(value: 1), range: range)
//            attributedString.addAttribute(NSAttributedStringKey.underlineColor, value: UIColor.orange, range: range)
//
//            self.textLabel.attributedText = attributedString
            
            // Set the 'click here' substring to be the link
//            attributedString.setAttributes([.link: url], range: range)
//
//            self.textLabel.attributedText = attributedString
//            self.textLabel.isUserInteractionEnabled = true
        
            
        
            
            self.layoutIfNeeded()
            
        }) { (error) in
            print(error)
        }
    }
    
    func setupView() {
        self.layer.borderWidth = 2
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 18
        self.clipsToBounds = true
        self.textLabel.backgroundColor = .green
        self.textTitle.backgroundColor = .white
        self.textDescription.backgroundColor = .white
//        self.textTitle.roundCorners(corners: [.topLeft, .topRight], radius: 18)
//        self.textDescription.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 18)
//        self.textLabel.backgroundColor = .blue
//        self.textLabel.layer.addBorder(edge: .top, color: UIColor.gray, thickness: 1)
//
//        self.textDescription.layer.addBorder(edge: .bottom, color: UIColor.gray, thickness: 1)
//        self.textDescription.backgroundColor = .white
//        self.textLabel.layer.masksToBounds = false
//        self.textLabel.layer.cornerRadius = 18
//        self.textLabel.clipsToBounds = true
//        self.textLabel.backgroundColor = .blue
//
//        self.textDescription.layer.masksToBounds = false
//        self.textLabel.layer.cornerRadius = 18
//        self.textLabel.clipsToBounds = true
//        self.textLabel.backgroundColor = .white
        
        
        self.layoutIfNeeded()
    }
}
