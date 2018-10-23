//
//  ViewController.swift
//  CollectionView
//
//  Created by Tobias Frantsen on 13/09/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import FileBrowser
import RxSwift
import UIKit

enum cellType {
    case footer
    case receiver
    case sender
    case input
}

class ViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GifPickerDelegate {
   
    
    
    @IBOutlet weak var fileImageView: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var photoalbumImageView: UIImageView!
    @IBOutlet weak var microphoneImageView: UIImageView!
    
    @IBOutlet var keyboardTabBar: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstarint: NSLayoutConstraint!
    @IBOutlet weak var messageInputContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
//    @IBOutlet weak var topBorderView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gifImageView: UIImageView!
//    private var rows: [cellType] = []
    private var messageArray: [Message] = []
    
    public var userName: String = ""
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
      
        
        _ = SocketIOManager.shared.socket.rx.on("newChatMessage").subscribe { (message) in
            
            
            let date = message.element?[2]
            let text = message.element?[1] as! String
            let nickname = message.element?[0] as! String
            
          let usernameExists = message.element!.contains(where: { (message) -> Bool in
                let _message = message as! String
                if _message == self.userName {
                    return true
                }
                return false
            })
            
            if !usernameExists {
                let newTextMessage = Message(messageType: .text, isSender: true, time: Date(), nameSender: nickname , filePath: "", imageTest: nil, messageText: text)!
                
                self.addNewMessageToCollectionView(newMessage: newTextMessage)
            }
            
        }
    
        
        
//        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
//            let collectionView = collectionView {
//            let w = collectionView.frame.width - 20
//            flowLayout.estimatedItemSize = CGSize(width: w, height: 200)
//        }
        
//        self.topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
//        collectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
//         collectionView.register(UINib.init(nibName: "ReceiverViewCell", bundle: nil), forCellWithReuseIdentifier: "ReceiverViewCell")
        
        collectionView.register(UINib.init(nibName: "ImageViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageViewCell")
          collectionView.register(UINib.init(nibName: "TextViewCell", bundle: nil), forCellWithReuseIdentifier: "TextViewCell")
        collectionView.register(UINib.init(nibName: "AudioPlayerViewCell", bundle: nil), forCellWithReuseIdentifier: "AudioPlayerViewCell")
         collectionView.register(UINib.init(nibName: "VideoPlayerViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoPlayerViewCell")
        collectionView.register(UINib.init(nibName: "FileViewCell", bundle: nil), forCellWithReuseIdentifier: "FileViewCell")
        
        

        
//      rows = self.buildRows()
        
        view.addSubview(messageInputContainerView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
          NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        inputTextField.inputAccessoryView = self.keyboardTabBar
        
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
        
        
//        self.messageArray = self.getMessage()
        
        
    }
    @objc func fileIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        let fileBrowser = FileBrowser()
        present(fileBrowser, animated: true, completion: nil)
        
        fileBrowser.didSelectFile = { (file: FBFile) -> Void in
            print("tobias\(file.displayName)")
            print("tobias\(file.filePath)")
            
            
            let url = URL(string: "file:///Users/tobiasfrantsen/Downloads/icon.png")!
            
            let imageData:NSData = NSData.init(contentsOf: url)!
            
            let newFileMessage = Message(messageType: .file, isSender: true, time: Date(), nameSender: "Tobias", filePath: file.displayName, imageTest: nil, messageText: "")!
            self.addNewMessageToCollectionView(newMessage: newFileMessage)
            self.dismiss(animated: true)
        }
    }
    @objc func videoIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        CameraController.shared.authorisationStatus(attachmentTypeEnum: .video, vc: self)
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
        CameraController.shared.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self)
        CameraController.shared.imagePickedBlock = {(image) in
            debugPrint("Tobias \(image)")
        
            let newPhotoMessage = Message(messageType:.photo , isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: image, messageText: "")!
            self.addNewMessageToCollectionView(newMessage: newPhotoMessage)
            let imageData: NSData = UIImagePNGRepresentation(image) as NSData!
            SocketIOManager.shared.uploadData(data: imageData, nameOfFile: stringDate)
        }
        CameraController.shared.imagePickedURL = {(url) in
            debugPrint("Tobias \(url)")
           
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        CameraController.shared.authorisationStatus(attachmentTypeEnum: .camera, vc: self)
    }
   
    @objc func gifIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.inputTextField.endEditing(true)
        // Your action
        let newViewController =  GifView()
        newViewController.delegate = self
        self.navigationController?.pushViewController(newViewController, animated: true)
      
    }
    
    @objc func mircophoneIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        let newViewController =  AudioViewController()
        self.navigationController?.pushViewController(newViewController, animated: true)
        
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFram = userInfo[UIKeyboardFrameBeginUserInfoKey] as! CGRect
            debugPrint(keyboardFram)
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            let height = keyboardFram.height + self.keyboardTabBar.frame.height
            self.bottomConstarint.constant = isKeyboardShowing ? -height : 0
            
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                //
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.inputTextField.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageArray.count
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var messageType = self.messageArray[indexPath.row].type
        let messagePath = self.messageArray[indexPath.row].linkToFile
        let messageImage = self.messageArray[indexPath.row].image
        
        
        
        var cell = UICollectionViewCell()
        switch messageType {
        case .aduio:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioPlayerViewCell", for: indexPath) as? AudioPlayerViewCell  {
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            
        case .text:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextViewCell", for: indexPath) as? TextViewCell  {
                let messageText = self.messageArray[indexPath.row].text
                menuCell.setup(text: messageText!, index: indexPath.row)
                menuCell.textLabel.sizeToFit()
                cell = menuCell
            } else {
               return UICollectionViewCell()
            }
        case .gif:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as? ImageViewCell  {
                menuCell.setup(type: messageType, path: messagePath, index: indexPath.row, image: nil)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .photo:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as? ImageViewCell  {
                menuCell.setup(type: messageType, path: messagePath, index: indexPath.row, image: messageImage)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .video:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPlayerViewCell", for: indexPath) as? VideoPlayerViewCell  {
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .file:
            let nameOfFile = self.messageArray[indexPath.row].linkToFile
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileViewCell", for: indexPath) as? FileViewCell  {
                menuCell.setup(index: indexPath.row, nameOfFile: nameOfFile, path: nameOfFile)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        }
      
        
//        menuCell.setup(type: messageType, path: messagePath, image: messageImage)
//
//        if messageType == .file {
//            let image = menuCell.imageView.image
//            let size = CGSize(width: 20, height: 20)
//            menuCell.imageView.image = self.ResizeImage(image: image!, targetSize: size)
//            menuCell.imageView.contentMode = .right
//            menuCell.imageView.backgroundColor = .white
//        }
      
        
        
        return cell
        
        
        
//        let menuElement = self.rows[indexPath.row]
//        var returnCell = UICollectionViewCell()
//        switch menuElement {
//
//        case .footer:
//            debugPrint("Top")
////            return UICollectionViewCell()
//        case .receiver:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
//            cell.setup()
//            returnCell = cell
//        case .sender:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReceiverViewCell", for: indexPath) as! ReceiverViewCell
//            cell.setup()
//            returnCell = cell
//        case .input:
//            debugPrint("Input")
////            return UICollectionViewCell()
//        }
//
//        return returnCell
    }
    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//    
//             return CGSize(width: view.frame.width/2, height: 150)
//        
//
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


//    func buildRows() -> [cellType] {
//        var rows: [cellType] = []
////        rows.append(.footer)
//        rows.append(.receiver)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
//        rows.append(.sender)
////        rows.append(.input)
//        return rows
//    }
    
//    func getMessage() -> [Message]{
//        // Message.parse(json: JSON)
//       var getMessageArray: [Message] = []
//        let message1 = Message( messageType: .text, isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: nil)!
//        let message2 = Message( messageType: .photo, isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: nil)!
//        let message3 = Message( messageType: .gif, isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: nil)!
//        let message4 = Message( messageType: .aduio, isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: nil)!
//        let message5 = Message( messageType: .file, isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: nil)!
//        let message6 = Message( messageType: .video, isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: nil)!
//
//        getMessageArray.append(message1)
//        getMessageArray.append(message2)
//        getMessageArray.append(message3)
//        getMessageArray.append(message4)
//        getMessageArray.append(message5)
//        getMessageArray.append(message6)
//
//        return getMessageArray
//    }
   
    
    func getLink(_ url: String?) {
        if let _url = url {
            let newGifMessage = Message(messageType: .gif, isSender: true, time: Date(), nameSender: "Tobias", filePath: _url, imageTest: nil, messageText: "")!
            self.addNewMessageToCollectionView(newMessage: newGifMessage)
            
        }
    }
    
    func addNewMessageToCollectionView(newMessage: Message){
        self.messageArray.append(newMessage)
        let item = self.messageArray.count - 1
        let insertIndexPath = IndexPath(item: item, section: 0)
        self.collectionView.insertItems(at: [insertIndexPath])
    }
    
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? UIImage()
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        let messageText = self.inputTextField.text
        
        let newTextMessage = Message(messageType: .text, isSender: true, time: Date(), nameSender: "Tobias", filePath: "", imageTest: nil, messageText: messageText)!
        self.addNewMessageToCollectionView(newMessage: newTextMessage)
        SocketIOManager.shared.sendMessage(message: messageText!, withNickname: self.userName)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         var messageType = self.messageArray[indexPath.row].type
       
        switch messageType {
        case .text:
            if let text = self.messageArray[indexPath.row].text {
              let apporximateWitdhOfTextView = 250
              
                let size = CGSize(width: apporximateWitdhOfTextView, height: 1000)
                
                let attribues = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
                
            let rect = NSString(string: text).boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: attribues, context: nil)
                debugPrint("Tobias \(rect.height)")
                return CGSize(width: view.frame.width - 50 , height: rect.height + 20)
            }
            
        case .gif:
            break
        case .photo:
            break
        case .video:
            CGSize(width: view.frame.width - 50, height: 250)
        case .aduio:
            break
        case .file:
            return CGSize(width: view.frame.width - 50, height: 60)
        }
        return CGSize(width: view.frame.width - 50, height: 150)
    }
}

