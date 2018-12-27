//
//  ViewController.swift
//  CollectionView
//
//  Created by Tobias Frantsen on 13/09/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import BRYXBanner
import NVActivityIndicatorView
import FileBrowser
import RxSwift
import UIKit


//enum cellType {
//    case footer
//    case receiver
//    case sender
//    case input
//}

class ViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GifPickerDelegate, UITextFieldDelegate, AudioPickerDelegate {
    
    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    
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
    
    private var chatMessages = [[]]
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.inputTextField.delegate = self
        
      self.indicatorView.type = .ballPulse
      self.indicatorView.color = .red
        
        
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
                let newTextMessage = Message(messageType: .text, isSender: false, time: Date(), nameSender: nickname , filePath: "", messageText: text)!
                
                self.addNewMessageToCollectionView(newMessage: newTextMessage)
            }
            
        }
        
        
        _ = SocketIOManager.shared.socket.rx.on("audio").subscribe { (audio) in
            
            if self.userName != audio.element?[1] as? String {
                if let imageBase64String = audio.element?[0] as? String {
     
                    let newAudioMessage = Message(messageType: .audio, isSender: false, time: Date(), nameSender: self.userName, filePath: imageBase64String, messageText: "")!
                    self.addNewMessageToCollectionView(newMessage: newAudioMessage)
                }
            }
        }
        
        
        _ = SocketIOManager.shared.socket.rx.on("image").subscribe { (image) in
            
            if self.userName != image.element?[1] as? String {
            if let imageBase64String = image.element?[0] as? String {
                let imageData = Data(base64Encoded: imageBase64String, options: .ignoreUnknownCharacters)
            
            let image = UIImage(data: imageData!)

                let newImageMesssage = Message(messageType: .photo, isSender: false, time: Date(), nameSender: self.userName, filePath: "", messageText: "")!
                self.addNewMessageToCollectionView(newMessage: newImageMesssage)
            }
            }
        }
        
        _ = SocketIOManager.shared.socket.rx.on("gif").subscribe { (gif) in
            
            if self.userName != gif.element?[1] as? String {
                let path = gif.element![0]
                let imageURL = UIImage.gifImageWithURL(path as! String)
                let newGifMessage = Message(messageType: .gif, isSender: false, time: Date(), nameSender: gif.element![1] as! String, filePath: path as! String, messageText: "")!
                self.addNewMessageToCollectionView(newMessage: newGifMessage)
                }
            }
        
        _ = SocketIOManager.shared.socket.rx.on("userTypingUpdate").subscribe { (user) in
           
            var totalTypingUser = 0

            for (_, typingUser) in user.element!.enumerated() {
                if let user = typingUser as? [String: AnyObject] {
                    if (user.first?.key != self.userName) && (user.first?.value as? Int  == 1) {
                        totalTypingUser += 1
                    }
                }
            }
            
            if totalTypingUser > 0 {
                self.indicatorView.startAnimating()
            } else {
                self.indicatorView.stopAnimating()
            }
            
        }
        
        _ = SocketIOManager.shared.socket.rx.on("userConnectUpdate").subscribe { (user) in
            
            let nameJoined = user.element?[1] as! String
            
            if nameJoined != self.userName {
                let banner = Banner(title: "\(nameJoined) has just join the chat", backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                banner.dismissesOnTap = true
                banner.show(duration: 2.0)
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
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        
        
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
       
        
//        let photoAlbumTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(photoAlbumIconTapped(tapGestureRecognizer:)))
//        self.photoalbumImageView.isUserInteractionEnabled = true
//        self.photoalbumImageView.addGestureRecognizer(photoAlbumTapGestureRecognizer)
        
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
            
            let newFileMessage = Message(messageType: .file, isSender: true, time: Date(), nameSender: "Tobias", filePath: file.displayName, messageText: "")!
            self.addNewMessageToCollectionView(newMessage: newFileMessage)
            self.dismiss(animated: true)
        }
    }
    @objc func videoIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
//        CameraController.shared.authorisationStatus(attachmentTypeEnum: .video, vc: self)
//        CameraController.shared.imagePickedBlock = {(image) in
//            debugPrint(image)
//        }
    }
//    @objc func photoAlbumIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
//    {
//        // Your action
//
//        let d = Date()
//        let df = DateFormatter()
//        df.dateFormat = "y-MM-dd H:m:ss.SSSS"
//
//        let stringDate = df.string(from: d)
//        CameraController.shared.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self)
//        CameraController.shared.imagePickedBlock = {(image) in
//            debugPrint("Tobias \(image)")
//
//            let resizeSize = CGSize(width: self.view.frame.width - 50, height: 150)
//            let newResizeImage = image.resize(targetSize: resizeSize)
//
//            let newPhotoMessage = Message(messageType:.photo , isSender: true, time: Date(), nameSender: self.userName, filePath: "unknow", imageTest: newResizeImage, messageText: "")!
//            self.addNewMessageToCollectionView(newMessage: newPhotoMessage)
//            let imageData: NSData = UIImagePNGRepresentation(newResizeImage) as NSData!
//            SocketIOManager.shared.uploadData(data: imageData, nameOfFile: stringDate, userName: self.userName)
//        }
//        CameraController.shared.imagePickedURL = {(url) in
//            debugPrint("Tobias \(url)")
//
//        }
//    }
    
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
        newViewController.delegate = self
        self.navigationController?.pushViewController(newViewController, animated: true)
//        let audioMessage = Message(messageType: .aduio, isSender: true, time: Date(), nameSender: self.userName, filePath: "", imageTest: nil, messageText: nil)!
//        self.addNewMessageToCollectionView(newMessage: audioMessage)
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
        var isSender = self.messageArray[indexPath.row].sender
        
        
        
        var cell = UICollectionViewCell()
        switch messageType {
        case .audio:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioPlayerViewCell", for: indexPath) as? AudioPlayerViewCell  {
                menuCell.setup(url: messagePath, isSent: false)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            
        case .text:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextViewCell", for: indexPath) as? TextViewCell  {
                let messageText = self.messageArray[indexPath.row].text
                menuCell.setup(text: messageText!, isSender: isSender, date: Date(), isSent: true)
                menuCell.textLabel.sizeToFit()
                cell = menuCell
            } else {
               return UICollectionViewCell()
            }
        case .gif:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as? ImageViewCell  {
                menuCell.setup(type: messageType, path: messagePath, isSender: isSender, isSent: false)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .photo:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as? ImageViewCell  {
                menuCell.setup(type: messageType, path: messagePath, isSender: isSender, isSent: false)
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
                menuCell.setup(isSender: isSender, nameOfFile: nameOfFile, path: nameOfFile, isSent: false)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .linkPreView:
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
            let newGifMessage = Message(messageType: .gif, isSender: true, time: Date(), nameSender: self.userName, filePath: _url, messageText: "")!
            self.addNewMessageToCollectionView(newMessage: newGifMessage)
            SocketIOManager.shared.sendGifMessage(giflink: _url, nickName: self.userName)
            
        }
    }
    
    
    func getAudioBase64(_ url: String?) {
        if let _url = url {
            let newAudioMessage = Message(messageType: .audio, isSender: true, time: Date(), nameSender: self.userName, filePath: _url, messageText: "")!
            self.addNewMessageToCollectionView(newMessage: newAudioMessage)
             let audioData = NSData(base64Encoded: _url)!
            
            SocketIOManager.shared.uploadData(data: audioData, nameOfFile: "joi", userName: self.userName)
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
        
        let newTextMessage = Message(messageType: .text, isSender: true, time: Date(), nameSender: "Tobias", filePath: "", messageText: messageText)!
        self.addNewMessageToCollectionView(newMessage: newTextMessage)
        SocketIOManager.shared.sendMessage(message: messageText!, withNickname: self.userName)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         var messageType = self.messageArray[indexPath.row].type
       
        switch messageType {
        case .text, .linkPreView:
            if let text = self.messageArray[indexPath.row].text {
              let apporximateWitdhOfTextView = 250
              
                let size = CGSize(width: apporximateWitdhOfTextView, height: 1000)
                
                let attribues = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
                
            let rect = NSString(string: text).boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: attribues, context: nil)
             
                let returnSize = CGSize(width: view.frame.width - 50 , height: rect.height + 20 + 20)
                return returnSize
            }
            
        case .gif:
            break
        case .photo:
            break
        case .video:
            return CGSize(width: view.frame.width - 50, height: 250)
        case .audio:
            return CGSize(width: view.frame.width - 50, height: 65)
        case .file:
            return CGSize(width: view.frame.width - 50, height: 60)
      
       
        }
        return CGSize(width: view.frame.width - 50, height: 150 + 20)
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.indicatorView.startAnimating()
        SocketIOManager.shared.startTypning(_nickName: self.userName)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.indicatorView.stopAnimating()
        SocketIOManager.shared.stopTypning(nickName: self.userName)
    }
    
   private func groupedMessagesByDate(){
   let groupedMessages = Dictionary(grouping: self.messageArray) { (element) -> Date in
        return element.timestamp
    }
    
    let sortedKeys = groupedMessages.keys.sorted()
    sortedKeys.forEach { (key) in
        let values = groupedMessages[key]
        self.chatMessages.append(values ?? [])
    }
    
    }
}

