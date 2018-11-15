//
//  ChatView.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 12/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol typningMessageDelegate: class {
    func getTypningStatus(isEditning: Bool)
}

class ChatView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, newMessageDelegate, keyboardIconTappedDelegate, GifPickerDelegate {
   
    @IBOutlet var gifkeyboardView: GifKeyboardView!
    
    func keybordButtonTapped(type: messageType) {
        self.gifkeyboardView.delegate = self
        inputTextField.inputAccessoryView = self.gifkeyboardView
        inputTextField.reloadInputViews()
        self.gifkeyboardView.textField.becomeFirstResponder()
        self.messageInputContainerView.isHidden = true 
    }
    
    
    func getLink(_ url: String?) {
        self.dismissKeyboard()
        self.messageInputContainerView.isHidden = false
        self.inputTextField.inputAccessoryView = self.keyBoardTabView
        self.inputTextField.reloadInputViews()
        if let _url = url {
            self.newMessage(messageType: .gif, filePath: _url)
        }
    }
    
 
    func newMessage(messageType: messageType, filePath: String) {
        if let message = self.createMessage(type: messageType, filePath: filePath, messageText: nil) {
            self.addNewMessageToCollectionView(newMessage: message)
        }
    }
    
    func createMessage(type: messageType, filePath: String,  messageText: String?) -> Message?{
      
        return Message(messageType: type, isSender: true, time: Date(), nameSender: self.userName, filePath: filePath, imageTest: nil, messageText: messageText)
    }

    @IBOutlet var keyBoardTabView: KeyboardTabView!

    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    
    @IBOutlet var ContentView: UIView!
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstarint: NSLayoutConstraint!
    @IBOutlet weak var messageInputContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var messageArray: [Message] = []
    
    public var userName: String = ""
    
    private var chatMessages = [[]]
    
    let kCONTENT_XIB_NAME = "ChatView"
    
    weak var delegate: typningMessageDelegate?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        ContentView.fixInView(self)
        self.setup()
    }
    
    func setup(){
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.keyBoardTabView.messageDelegate = self
        self.keyBoardTabView.keyboardDelegate = self
        inputTextField.inputAccessoryView = self.keyBoardTabView
        
        self.collectionView.register(UINib.init(nibName: "ImageViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageViewCell")
        self.collectionView.register(UINib.init(nibName: "TextViewCell", bundle: nil), forCellWithReuseIdentifier: "TextViewCell")
        self.collectionView.register(UINib.init(nibName: "AudioPlayerViewCell", bundle: nil), forCellWithReuseIdentifier: "AudioPlayerViewCell")
        self.collectionView.register(UINib.init(nibName: "VideoPlayerViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoPlayerViewCell")
        collectionView.register(UINib.init(nibName: "FileViewCell", bundle: nil), forCellWithReuseIdentifier: "FileViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.addGestureRecognizer(tap)

        
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
        self.gifkeyboardView.textField.endEditing(true)
        self.inputTextField.endEditing(true)
    }
    

    func setUsername(name: String) {
        self.userName = name 
    }
    
    //TODO: Make to array, so you can insert array of messages
    func addNewMessageToCollectionView(newMessage: Message){
        self.messageArray.append(newMessage)
        let item = self.messageArray.count - 1
        let insertIndexPath = IndexPath(item: item, section: 0)
        self.collectionView.insertItems(at: [insertIndexPath])
        
        let section = 0
        let lastItemIndex = self.collectionView.numberOfItems(inSection: section) - 1
        let indexPath:NSIndexPath = NSIndexPath.init(item: lastItemIndex, section: section)
        self.collectionView.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: false)
        

        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.inputTextField.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let messageType = self.messageArray[indexPath.row].type
        let messagePath = self.messageArray[indexPath.row].linkToFile
//        let messageImage = self.messageArray[indexPath.row].image
        let isSender = self.messageArray[indexPath.row].sender
        
        
        
        var cell = UICollectionViewCell()
        switch messageType {
        case .aduio:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioPlayerViewCell", for: indexPath) as? AudioPlayerViewCell  {
                menuCell.setup(base64: messagePath)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            
        case .text:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextViewCell", for: indexPath) as? TextViewCell  {
                let messageText = self.messageArray[indexPath.row].text
                menuCell.setup(text: messageText!, isSender: isSender)
                menuCell.textLabel.sizeToFit()
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
        case .gif:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as? ImageViewCell  {
                menuCell.setup(type: messageType, path: messagePath, image: nil, isSender: isSender)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .photo:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as? ImageViewCell  {
                menuCell.setup(type: messageType, path: messagePath, image: nil, isSender: isSender)
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
                menuCell.setup(isSender: isSender, nameOfFile: nameOfFile, path: nameOfFile)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let messageType = self.messageArray[indexPath.row].type
        
        switch messageType {
        case .text:
            if let text = self.messageArray[indexPath.row].text {
                let apporximateWitdhOfTextView = 250
                
                let size = CGSize(width: apporximateWitdhOfTextView, height: 1000)
                
                let attribues = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
                
                let rect = NSString(string: text).boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: attribues, context: nil)
                debugPrint("Tobias \(rect.height)")
                let returnSize = CGSize(width: self.frame.width - 50 , height: rect.height + 20 + 20)
                return returnSize
            }
            
        case .gif:
            break
        case .photo:
            break
        case .video:
            return CGSize(width: self.frame.width - 50, height: 250)
        case .aduio:
            return CGSize(width: self.frame.width - 50, height: 65)
        case .file:
            return CGSize(width: self.frame.width - 50, height: 60)
        }
        return CGSize(width: self.frame.width - 50, height: 150 + 20)
    }
    
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFram = userInfo[UIKeyboardFrameBeginUserInfoKey] as! CGRect
            debugPrint(keyboardFram)
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            let height = keyboardFram.height + self.keyBoardTabView.frame.height
            self.bottomConstarint.constant = isKeyboardShowing ? -height : 0
            
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.layoutIfNeeded()
            }) { (completed) in
                if isKeyboardShowing {
                    let indexpath = IndexPath(item: self.messageArray.count - 1, section: 0)
                    self.collectionView.scrollToItem(at: indexpath, at: .bottom, animated: true)
                }
            }
        }
    }
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.getTypningStatus(isEditning: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.getTypningStatus(isEditning: false)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        let messageText = self.inputTextField.text
       
        let newTextMessage = Message(messageType: .text, isSender: true, time: Date(), nameSender: self.userName, filePath: "", imageTest: nil, messageText: messageText)!
        self.addNewMessageToCollectionView(newMessage: newTextMessage)
        self.dismissKeyboard()
        self.inputTextField.text = ""
    }
    
    
}
