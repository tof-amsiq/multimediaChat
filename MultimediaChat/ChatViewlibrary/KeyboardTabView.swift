//
//  KeyboardTabView.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 12/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import MobileCoreServices
import FileBrowser
import UIKit

protocol newMessageDelegate: class {
    func newMessage(messageType: messageType, filePath: String, fileName: String?)
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
            
//            let fileArray = file.filePath.absoluteString.components(separatedBy: ".")
//            let fileType = fileArray.last
//            print("tobias\(file.displayName)")
//            print("tobias\(file.filePath)")
//
//
//            let url = URL(string: "file:///Users/tobiasfrantsen/Downloads/icon.png")!
//
//            let imageData:NSData = NSData.init(contentsOf: url)!
            let name = file.displayName
            let type = file.type
            
            switch type {
                
            case .Directory, .JSON, .PDF, .ZIP, .PLIST:
                self.messageDelegate?.newMessage(messageType: .file, filePath: file.filePath.absoluteString, fileName: name)
            case .GIF:
                self.messageDelegate?.newMessage(messageType: .gif, filePath: file.filePath.absoluteString, fileName: nil)
            case .JPG, .PNG:
                self.messageDelegate?.newMessage(messageType: .photo, filePath: file.filePath.absoluteString, fileName: nil)
            case .Default:
               
                let audioAndVideoTypes = [
                    "mid":  messageType.audio,
                    "midi": messageType.audio,
                    "kar":  messageType.audio,
                    "mp3":  messageType.audio,
                    "ogg":  messageType.audio,
                    "m4a":  messageType.audio,
                    "ra":  messageType.audio,
                    "3gpp":  messageType.video,
                    "3gp": messageType.video,
                    "ts": messageType.video,
                    "mp4": messageType.video,
                    "mpeg": messageType.video,
                    "mpg": messageType.video,
                    "mov": messageType.video,
                    "webm": messageType.video,
                    "flv": messageType.video,
                    "m4v": messageType.video,
                    "mng": messageType.video,
                    "asx": messageType.video,
                    "asf": messageType.video,
                    "wmv": messageType.video,
                    "avi": messageType.video
                    ]

                
                let _extension = NSURL(fileURLWithPath: file.filePath.absoluteString).pathExtension
                
                if let type = audioAndVideoTypes[_extension ?? ""] {
                    if type  == .audio {
                        self.messageDelegate?.newMessage(messageType: .audio, filePath: file.filePath.absoluteString, fileName: nil)
                    } else if type == .video {
                        self.messageDelegate?.newMessage(messageType: .video, filePath: file.filePath.absoluteString, fileName: nil)
                    }
                }
               
            }
            
            
            let newFileMessage = Message(messageType: .file, isSender: true, time: "", nameSender: "Tobias", filePath: file.displayName, messageText: nil)
            
            //            self.addNewMessageToCollectionView(newMessage: newFileMessage)
            currentController?.dismiss(animated: true)
//
//
//            self.messageDelegate?.newMessage(messageType: .file, filePath: file.filePath.absoluteString)
//            self.delegate?.newMessage(message: newFileMessage)
//            self.dismiss(animated: true)
        }
    }
    @objc func videoIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
      
        DispatchQueue.main.async {
            CameraController.shared.authorisationStatus(attachmentTypeEnum: .video, vc: self.getCurrentViewController()!)
            CameraController.shared.videoPickedBlock = {(video) in
                debugPrint("Tobias \(video)")
                var urlString = video.absoluteString
                self.messageDelegate?.newMessage(messageType: .video, filePath: urlString ?? "", fileName: nil)
            }
        }
        
        
//        CameraController.shared.authorisationStatus(attachmentTypeEnum: .video, vc: self.getCurrentViewController()!)
//        CameraController.shared.imagePickedBlock = {(image) in
//
//
//                let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
//                let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
//
//                self.messageDelegate?.newMessage(messageType: .photo, filePath: strBase64)
//
//
//        }
    }
    @objc func photoAlbumIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        
//        let d = Date()
//        let df = DateFormatter()
//        df.dateFormat = "y-MM-dd H:m:ss.SSSS"
//
//        let stringDate = df.string(from: d)
        CameraController.shared.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self.getCurrentViewController()!)
        
        CameraController.shared.imageLibraryPickedBlock = {(image, url) in
            let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            
            self.messageDelegate?.newMessage(messageType: .photo, filePath: strBase64, fileName: nil)
        }
        
        CameraController.shared.videoLibraryPickedBlock = {(url) in
//            if let data = NSData(contentsOf: url) {
//                let strBase64 = data.base64EncodedString(options: .lineLength64Characters)
//                self.messageDelegate?.newMessage(messageType: .video, filePath: strBase64)
//            }
            self.messageDelegate?.newMessage(messageType: .video, filePath: url.absoluteString, fileName: nil)
        }
        
//        CameraController.shared.imagePickedBlock = {(image) in
//            debugPrint("Tobias \(image)")
        
//            let crop = image.getCropRation()
//
//            let size = CGSize(width: 100 * crop, height: 100 / crop)
//            let scaleImage = UIImage.scaleImageToSize(img: image, size: size)
//
//
//            let newImage = self.resizeImageWithAspect(image: image, scaledToMaxWidth: 250, maxHeight: 300)!
//            debugPrint("bif newscale \(newImage.size)")
//            let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
//            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
//
//            self.messageDelegate?.newMessage(messageType: .photo, filePath: strBase64)

            
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
//        }
//        CameraController.shared.imagePickedURL = {(url) in
//            debugPrint("Bif \(url)")
//            self.delegate?.newMessage(messageType: .photo, filePath: String(url))
//
//        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        DispatchQueue.main.async {
             CameraController.shared.authorisationStatus(attachmentTypeEnum: .camera, vc: self.getCurrentViewController()!)
            
            CameraController.shared.imagePickedURL = {(url) in
                self.messageDelegate?.newMessage(messageType: .photo, filePath: url, fileName: nil)
            }
        }
//            CameraController.shared.imagePickedBlock = {(image) in
//                if let fixedImage = image.fixedOrientation() {
//
////                    let crop = fixedImage.getCropRation()
////                    let maxWidth = self.getCurrentViewController()!.view.frame.width - 50
////                    let size = CGSize(width: 100 * crop, height: 100 / crop)
////                    let scaleImage = UIImage.scaleImageToSize(img: fixedImage, size: size)
////
////                    let newImage = image.resize(targetSize: size)
////                    let newImage = self.resizeImageWithAspect(image: image, scaledToMaxWidth: 250, maxHeight: 300)!
//
//                    let imageData:NSData = UIImagePNGRepresentation(fixedImage)! as NSData
//                    let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
//
//                    self.messageDelegate?.newMessage(messageType: .photo, filePath: strBase64)
//                }
//
//            }
//        }
        
        
       
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
      
//        let newViewController = AudioViewController()
//        newViewController.delegate = self
//        self.pushToViewController(viewController: newViewController)
        self.keyboardDelegate?.keybordButtonTapped(type: .audio)
       
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
            self.messageDelegate?.newMessage(messageType: .gif, filePath: _url, fileName: nil)
        }
    }
    
    func getAudioBase64(_ url: String?) {
        if let _url = url {
            self.messageDelegate?.newMessage(messageType: .audio, filePath: _url, fileName: nil)
        }
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.getCurrentViewController()!.present(alert, animated: true, completion: nil)
    }
    
    func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height :CGFloat)->UIImage? {
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

