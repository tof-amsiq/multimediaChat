//
//  ViewController.swift
//  CollectionView
//
//  Created by Tobias Frantsen on 13/09/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import FileBrowser
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
    
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
//        self.topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        collectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
         collectionView.register(UINib.init(nibName: "ReceiverViewCell", bundle: nil), forCellWithReuseIdentifier: "ReceiverViewCell")
        
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
        
        
        self.messageArray = self.getMessage()
        
        
        
    }
    @objc func fileIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        let fileBrowser = FileBrowser()
        present(fileBrowser, animated: true, completion: nil)
        
        fileBrowser.didSelectFile = { (file: FBFile) -> Void in
            print(file.displayName)
            let newFileMessage = Message(messageType: .file, isSender: true, time: Date(), nameSender: "Tobias", filePath: file.displayName, imageTest: nil)!
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
        CameraController.shared.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self)
        CameraController.shared.imagePickedBlock = {(image) in
            debugPrint("Tobias \(image)")
            let newPhotoMessage = Message(messageType:.photo , isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: image)!
            self.addNewMessageToCollectionView(newMessage: newPhotoMessage)
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
        
        let messageType = self.messageArray[indexPath.row].type
        let messagePath = self.messageArray[indexPath.row].linkToFile
        let messageImage = self.messageArray[indexPath.row].image
        
        guard let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReceiverViewCell", for: indexPath) as? ReceiverViewCell else {
            return UICollectionViewCell()
        }
        
        menuCell.setup(type: messageType, path: messagePath, image: messageImage)
        
        if messageType == .file {
            let image = menuCell.imageView.image
            let size = CGSize(width: 20, height: 20)
            menuCell.imageView.image = self.ResizeImage(image: image!, targetSize: size)
            menuCell.imageView.contentMode = .right
            menuCell.imageView.backgroundColor = .white
        }
        
        return menuCell
        
        
        
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
        
    }
    
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
    
    func getMessage() -> [Message]{
        // Message.parse(json: JSON)
       var getMessageArray: [Message] = []
        let message1 = Message( messageType: .text, isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: nil)!
        let message2 = Message( messageType: .photo, isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: nil)!
        let message3 = Message( messageType: .gif, isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: nil)!
        let message4 = Message( messageType: .aduio, isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: nil)!
        let message5 = Message( messageType: .file, isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: nil)!
        let message6 = Message( messageType: .video, isSender: true, time: Date(), nameSender: "Tobias", filePath: "unknow", imageTest: nil)!
        
        getMessageArray.append(message1)
        getMessageArray.append(message2)
        getMessageArray.append(message3)
        getMessageArray.append(message4)
        getMessageArray.append(message5)
        getMessageArray.append(message6)
        
        return getMessageArray
    }
   
    
    func getLink(_ url: String?) {
        if let _url = url {
            let newGifMessage = Message(messageType: .gif, isSender: true, time: Date(), nameSender: "Tobias", filePath: _url, imageTest: nil)!
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
    
}
