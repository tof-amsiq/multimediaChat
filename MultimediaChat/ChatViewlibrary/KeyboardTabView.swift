//
//  KeyboardTabView.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 12/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import FileBrowser
import UIKit

protocol newMessageDelegate: class {
    func newMessage(messageType: messageType, filePath: String)
}

protocol keyboardIconTappedDelegate: class {
    func keybordButtonTapped(type: messageType)
}

class KeyboardTabView: UIView, GifPickerDelegate, AudioPickerDelegate {
  
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var fileImageView: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var photoalbumImageView: UIImageView!
    @IBOutlet weak var microphoneImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gifImageView: UIImageView!
    
    
    
     let kCONTENT_XIB_NAME = "KeyboardTabView"
   
   weak var messageDelegate: newMessageDelegate?
    weak var keyboardDelegate: keyboardIconTappedDelegate?
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        if self.subviews.count == 0 {
            commonInit()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if self.subviews.count == 0 {
            commonInit()
        }
    }
    
    func commonInit() {
        
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        self.setup()
    }
    
    
    private func setup(){
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        let gifTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gifIconTapped(tapGestureRecognizer:)))
        self.gifImageView.isUserInteractionEnabled = true
        self.gifImageView.addGestureRecognizer(gifTapGestureRecognizer)
        
        let microphoneTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mircophoneIconTapped(tapGestureRecognizer:)))
        self.microphoneImageView.isUserInteractionEnabled = true
        self.microphoneImageView.addGestureRecognizer(microphoneTapGestureRecognizer)
        
        
        let photoAlbumTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(photoAlbumIconTapped(tapGestureRecognizer:)))
        self.photoalbumImageView.isUserInteractionEnabled = true
        self.photoalbumImageView.addGestureRecognizer(photoAlbumTapGestureRecognizer)
        
        let videoTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(videoIconTapped(tapGestureRecognizer:)))
        self.videoImageView.isUserInteractionEnabled = true
        self.videoImageView.addGestureRecognizer(videoTapGestureRecognizer)
        
        let fileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fileIconTapped(tapGestureRecognizer:)))
        self.fileImageView.isUserInteractionEnabled = true
        self.fileImageView.addGestureRecognizer(fileTapGestureRecognizer)
        
    }
    
    @objc func fileIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        let fileBrowser = FileBrowser()
        let currentController = self.getCurrentViewController()
        
        currentController?.present(fileBrowser, animated: true, completion: nil)

//         present(fileBrowser, animated: true, completion: nil)
        
        fileBrowser.didSelectFile = { (file: FBFile) -> Void in
//            print("tobias\(file.displayName)")
//            print("tobias\(file.filePath)")
//
//
//            let url = URL(string: "file:///Users/tobiasfrantsen/Downloads/icon.png")!
//
//            let imageData:NSData = NSData.init(contentsOf: url)!
            
            let newFileMessage = Message(messageType: .file, isSender: true, time: Date(), nameSender: "Tobias", filePath: file.displayName, imageTest: nil, messageText: "")!
//            self.addNewMessageToCollectionView(newMessage: newFileMessage)
            currentController?.dismiss(animated: true)
            
            self.messageDelegate?.newMessage(messageType: .file, filePath: file.displayName)
//            self.delegate?.newMessage(message: newFileMessage)
//            self.dismiss(animated: true)
        }
    }
    @objc func videoIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        CameraController.shared.authorisationStatus(attachmentTypeEnum: .video, vc: self.getCurrentViewController()!)
        CameraController.shared.imagePickedBlock = {(image) in
            debugPrint(image)
        }
    }
    @objc func photoAlbumIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        
        let d = Date()
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd H:m:ss.SSSS"
        
        let stringDate = df.string(from: d)
        CameraController.shared.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self.getCurrentViewController()!)
        
        
        CameraController.shared.imagePickedBlock = {(image) in
            debugPrint("Tobias \(image)")
        
            let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            
            self.messageDelegate?.newMessage(messageType: .photo, filePath: strBase64)

            
//            let resizeSize = CGSize(width: self.frame.width - 50, height: 150)
//            let newResizeImage = image.resize(targetSize: resizeSize)
//
//
//            let newPhotoMessage = Message(messageType:.photo , isSender: true, time: Date(), nameSender: "Unknow", filePath: "unknow", imageTest: newResizeImage, messageText: "")!
//            self.delegate?.newMessage(messageType: .photo, filePath: <#T##String#>)
//            self.delegate?.newMessage(message: newPhotoMessage)
//
//            self.addNewMessageToCollectionView(newMessage: newPhotoMessage)
//            let imageData: NSData = UIImagePNGRepresentation(newResizeImage) as NSData!
//            SocketIOManager.shared.uploadData(data: imageData, nameOfFile: stringDate, userName: self.userName)
        }
//        CameraController.shared.imagePickedURL = {(url) in
//            debugPrint("Bif \(url)")
//            self.delegate?.newMessage(messageType: .photo, filePath: String(url))
//
//        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        CameraController.shared.authorisationStatus(attachmentTypeEnum: .camera, vc: self.getCurrentViewController()!)
    }
    
    @objc func gifIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
//        self.inputTextField.endEditing(true)
        // Your action
//        let newViewController =  GifView()
//        newViewController.delegate = self
//        self.navigationController?.pushViewController(newViewController, animated: true)
       
//        let newViewController = GifView()
//
//        newViewController.delegate = self
//        self.pushToViewController(viewController: newViewController)
        self.keyboardDelegate?.keybordButtonTapped(type: .gif)
        
    
    }
    
    @objc func mircophoneIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
//         Your action
//        let newViewController =  AudioViewController()
//        newViewController.delegate = self.getCurrentViewController()
//        self.navigationController?.pushViewController(newViewController, animated: true)
//                let audioMessage = Message(messageType: .aduio, isSender: true, time: Date(), nameSender: self.userName, filePath: "", imageTest: nil, messageText: nil)!
//                self.addNewMessageToCollectionView(newMessage: audioMessage)
      
        let newViewController = AudioViewController()
        newViewController.delegate = self
        self.pushToViewController(viewController: newViewController)
       
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
    
    func pushToViewController(viewController: UIViewController) {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
            
        }
    }
    
    func getLink(_ url: String?) {
        if let _url = url {
            self.messageDelegate?.newMessage(messageType: .gif, filePath: _url)
        }
    }
    
    func getAudioBase64(_ url: String?) {
        if let _url = url {
            self.messageDelegate?.newMessage(messageType: .aduio, filePath: _url)
        }
    }
}
