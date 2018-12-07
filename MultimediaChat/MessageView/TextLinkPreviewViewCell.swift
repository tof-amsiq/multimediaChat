//
//  TextLinkPreviewViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 19/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import URLEmbeddedView
import Nuke
import ReadMoreTextView
import SwiftLinkPreview
import UIKit
import MisterFusion

class TextLinkPreviewViewCell: UICollectionViewCell {
    @IBOutlet weak var preViewContrainerView: UIView!
    //    @IBOutlet weak var container: UIView!
//
//    @IBOutlet weak var textDescriptionView: ReadMoreTextView!
//    @IBOutlet weak var imageView: UIImageView!
//
//    @IBOutlet weak var textTitle: UILabel!
//    @IBOutlet weak var textLabel: UILabel!
//
    @IBOutlet weak var viewTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var textLabel: UILabel!
     let embeddedView = URLEmbeddedView()
//    private var slp: SwiftLinkPreview?
//    private var result = SwiftLinkPreview.Response()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        
        embeddedView.textProvider[.title].font = .boldSystemFont(ofSize: 16)
        embeddedView.textProvider[.title].fontColor = .lightGray
        embeddedView.textProvider[.title].numberOfLines = 0
        embeddedView.borderWidth = 0
        embeddedView.textProvider[.description].numberOfLines = 0
        
       
        self.preViewContrainerView.addLayoutSubview(embeddedView, andConstraints:
            embeddedView.top |+| 8,
                                                    embeddedView.right |-| 12,
                                                    embeddedView.left |+| 12,
                                                    embeddedView.bottom |-| 7.5
        )
        
    
//         self.slp = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: DispatchQueue.main, cache:  DisabledCache.instance)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
//        self.textDescription.numberOfLines = 0
//        let readMoreTextAttributes: [NSAttributedStringKey: Any] = [
//            NSAttributedStringKey.foregroundColor: self.tintColor,
//            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)
//        ]
//        let readLessTextAttributes = [
//            NSAttributedStringKey.foregroundColor: UIColor.red,
//            NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 16)
//        ]
//        self.textDescriptionView.attributedReadMoreText = NSAttributedString(string: "... Read more", attributes: readMoreTextAttributes)
//        self.textDescriptionView.attributedReadLessText = NSAttributedString(string: " Read less", attributes: readLessTextAttributes)
//        self.textDescriptionView.maximumNumberOfLines = 1
//        self.textDescriptionView.shouldTrim = true
//        self.textTitle.numberOfLines = 0
//
//
//        self.textLabel.padding = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0)
//        self.textTitle.padding = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
   
        embeddedView.didTapHandler = { [weak self] embeddedView, URL in
            guard let URL = URL else { return }
            
            let browserAlert = UIAlertController(title: "Open in browser", message: "Will you open link in browser", preferredStyle: UIAlertControllerStyle.alert)
            
            self?.getCurrentViewController()?.present(browserAlert, animated: true, completion: nil)
            
            browserAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
              UIApplication.shared.open(URL, options: [:])
            }))
            
            browserAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
        }
    
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.embeddedView.prepareViewsForReuse()
        self.textLabel.text = nil
        
//        imageView.display(image: nil)
//        self.textLabel.text = ""
//        self.textTitle.text = ""
//        self.textDescriptionView.text = ""
        
    }

    
    func setup(url: String, fullText: String, isSender: Bool, isSent: Bool?) {
        if let _isSent = isSent, _isSent == false {
            self.containerView.alpha = 0.1
        }
        if isSender {
           self.viewLeadingConstraint.constant = 50
           self.viewTrailingConstraint.constant = 0
        } else {
            self.viewLeadingConstraint.constant = 0
            self.viewTrailingConstraint.constant = 50
        }
        
        self.textLabel.text = fullText
      
        
//        self.textTitle.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.setupView()
        self.embeddedView.load(withURLString: url)
        self.embeddedView.layoutIfNeeded()
        self.layoutIfNeeded()
//
//        self.slp?.preview(url, onSuccess: { (result) in
//
//                        if let url_string = result[.image] as? String {
//                if let url = URL(string: url_string) {
//
//                    Nuke.loadImage(with: url, options: ImageLoadingOptions(
//                        failureImage: UIImage(named: "unknow" )
//                    ), into: self.imageView)
//                }
//            }
//
//            if let title = result[.title] as? String {
//                self.textTitle.text = title
//            }
//            if let description = result[.description] as? String {
////                self.textDescription.text = description
//                self.textDescriptionView.text = description
//
//
//            }
//
////            let range               = (fullText as NSString).range(of: url)
////            let attributedString    = NSMutableAttributedString(string: fullText)
//
////            attributedString.addAttribute(NSAttributedStringKey.link, value: NSURL(string: url) as Any, range: range)
////            attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber(value: 1), range: range)
////            attributedString.addAttribute(NSAttributedStringKey.underlineColor, value: UIColor.orange, range: range)
////
////            self.textLabel.attributedText = attributedString
//
//            // Set the 'click here' substring to be the link
////            attributedString.setAttributes([.link: url], range: range)
////
////            self.textLabel.attributedText = attributedString
////            self.textLabel.isUserInteractionEnabled = true
//
//
//
//
//            self.layoutIfNeeded()
//
//        }) { (error) in
//            print(error)
//        }
    }
    
    func setupView() {
        self.containerView.layer.borderWidth = 2
        self.containerView.layer.masksToBounds = false
        self.containerView.layer.borderColor = UIColor.black.cgColor
        self.containerView.layer.cornerRadius = 18
        self.containerView.clipsToBounds = true
        
//        self.textTitle.backgroundColor = .white
//        self.textDescription.backgroundColor = .white
//        self.textDescriptionView.backgroundColor = .white
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
    
    func getCurrentViewController() -> UIViewController? {
        
        //        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
        //            var currentController: UIViewController! = rootController
        //            while( currentController.presentedViewController != nil ) {
        //                currentController = currentController.presentedViewController
        //            }
        //            return currentController
        //        }
        //        return nil
        if let naviagtionController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            let currentController = naviagtionController.topViewController
            return currentController
        }
        return nil
    }
}
