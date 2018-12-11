//
//  ChatView.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 12/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import QuickLook

protocol typningMessageDelegate: class {
    func getTypningStatus(isEditning: Bool)
}

protocol MessageDelegate: class {
    func userSendNewMessage(text: String, user: String)
    func newMessagdeAdded(message: Message)
}

class ChatView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, newMessageDelegate, keyboardIconTappedDelegate, GifPickerDelegate, AudioPickerDelegate, QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        guard let url = self.quickLookLink else {
            fatalError("no url")
        }
        
        return url as QLPreviewItem
//
//        guard let url = Bundle.main.url(forResource: "example", withExtension: "mp3") else {
//            fatalError("Could not load \(index).pdf")
//        }
        
        
//        let url = URL(string:  "file:///Users/tobiasfrantsen/Library/Developer/CoreSimulator/Devices/A5357B1C-93FB-4087-B67F-879A70BEA08B/data/Containers/Data/Application/A2BF3744-D94B-4977-9506-9E5FC81C784D/Documents/2018-11-28132153.png")
//        let urltest = URL(string: "http://localhost:3000/uploads/2018-12-1016:16:15.m4a")!
//        return urltest as QLPreviewItem
    }
    
   
   
    @IBOutlet var audioRecorderKeyboardView: AudioRecorder!
    @IBOutlet var gifkeyboardView: GifKeyboardView!
    
    let previewController = QLPreviewController()
    
    var quickLookLink = URL(string: "")
    
    func keybordButtonTapped(type: messageType) {
        if type == .gif {
            self.gifkeyboardView.delegate = self
            inputTextField.inputAccessoryView = self.gifkeyboardView
            inputTextField.reloadInputViews()
            self.gifkeyboardView.textField.becomeFirstResponder()
        } else if type == .audio {
            self.audioRecorderKeyboardView.delegate = self
            inputTextField.inputAccessoryView =  self.audioRecorderKeyboardView
            inputTextField.reloadInputViews()
        }
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
    
    func getAudioBase64(_ url: String?) {
        self.dismissKeyboard()
        self.messageInputContainerView.isHidden = false
        self.inputTextField.inputAccessoryView = self.keyBoardTabView
        self.inputTextField.reloadInputViews()
        
        if let _url = url {
            self.newMessage(messageType: .audio, filePath: _url)
        }
    }
    
 
    func newMessage(messageType: messageType, filePath: String) {
        if let message = self.createMessage(user: "", date: Date(), type: messageType, filePath: filePath, messageText: nil) {
            self.addNewMessageToCollectionView(newMessage: message)
            self.messageDelegate?.newMessagdeAdded(message: message)
        }
    }
    
    func createMessage(user: String, date: Date, type: messageType, filePath: String,  messageText: String?) -> Message?{
        
      let isSender = user == self.userName
        return Message(messageType: type, isSender: isSender, time: date, nameSender: user, filePath: filePath, imageTest: nil, messageText: messageText)
    }

    @IBOutlet weak var inputTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet var keyBoardTabView: KeyboardTabView!

    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    
    @IBOutlet var ContentView: UIView!
    
    @IBOutlet weak var inputTextField: UITextView!
   
    @IBOutlet weak var bottomConstarint: NSLayoutConstraint!
    @IBOutlet weak var messageInputContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var messageArray: [Message] = []
    
    public var userName: String = ""
    
    private var chatMessages = [[]]
    
    private var estamitedInputTextHeight : CGFloat = 0
    
    let kCONTENT_XIB_NAME = "ChatView"
    
    weak var delegate: typningMessageDelegate?
    
    weak var messageDelegate: MessageDelegate?

    
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
        let size = CGSize(width: self.inputTextField.frame.width, height: .infinity)
        let estimatedSize = self.inputTextField.sizeThatFits(size)
        self.estamitedInputTextHeight = estimatedSize.height
        self.inputTextHeightConstraint.constant = estimatedSize.height
        
        self.inputTextField.delegate = self
        self.inputTextField.isScrollEnabled = false
        self.collectionView?.isPrefetchingEnabled = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.keyBoardTabView.messageDelegate = self
        self.keyBoardTabView.keyboardDelegate = self
        inputTextField.inputAccessoryView = self.keyBoardTabView
        
        self.collectionView.register(UINib.init(nibName: "ImageViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageViewCell")
        self.collectionView.register(UINib.init(nibName: "TextViewCell", bundle: nil), forCellWithReuseIdentifier: "TextViewCell")
        self.collectionView.register(UINib.init(nibName: "AudioPlayerViewCell", bundle: nil), forCellWithReuseIdentifier: "AudioPlayerViewCell")
        self.collectionView.register(UINib.init(nibName: "VideoPlayerViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoPlayerViewCell")
        self.collectionView.register(UINib.init(nibName: "FileViewCell", bundle: nil), forCellWithReuseIdentifier: "FileViewCell")
        self.collectionView.register(UINib.init(nibName: "TextLinkPreviewViewCell", bundle: nil), forCellWithReuseIdentifier: "TextLinkPreviewViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        self.addGestureRecognizer(tap)

        
    }
    
    @objc func dismissKeyboard() {
//        self.endEditing(true)
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
        if let cell = collectionView.cellForItem(at: indexPath) as? FileViewCell {
            if let path =  cell.path, let url = URL(string: path){
//                Downloader.testLoad(url: path)
                let isWebURL = !url.isFileURL
                
                self.previewController.dataSource = self
                if isWebURL {
                    
                    Downloader.testLoad(url: path) { (url) in
                        DispatchQueue.main.async {
                        self.quickLookLink = url
                        if let naviagtionController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                            let currentController = naviagtionController.topViewController
                            currentController!.present(self.previewController, animated: true)
                        }
                        }
                        
                    }
                    
                   
                } else {
                    DispatchQueue.main.async {
                        self.quickLookLink = url
                        if let naviagtionController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                            let currentController = naviagtionController.topViewController
                            currentController!.present(self.previewController, animated: true)
                        }
                    }                }
                
//                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//                Downloader.load(url: path, to: URL(string: documentsPath)!) {
//                    debugPrint("FUNNY")
//                }
//                let item = path as QLPreviewItem
//                let value = QLPreviewController.canPreview(item)
//                debugPrint("mr\(value)")
                
            }
            
          
            
           
           
        }
        
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
        let date = self.messageArray[indexPath.row].timestamp
        let isSent = self.messageArray[indexPath.row].isSent
       
        var cell = UICollectionViewCell()
        switch messageType {
        case .audio:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioPlayerViewCell", for: indexPath) as? AudioPlayerViewCell  {
                menuCell.setup(url: messagePath, isSent: isSent)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            
        case .text:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextViewCell", for: indexPath) as? TextViewCell  {
                let messageText = self.messageArray[indexPath.row].text
                menuCell.setup(text: messageText!, isSender: isSender, date: date, isSent: isSent)
                menuCell.textLabel.sizeToFit()
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
        case .gif:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as? ImageViewCell  {
                menuCell.setup(type: messageType, path: messagePath, image: nil, isSender: isSender, isSent: isSent)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .photo:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as? ImageViewCell  {
                menuCell.setup(type: messageType, path: messagePath, image: nil, isSender: isSender, isSent: isSent)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .video:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPlayerViewCell", for: indexPath) as? VideoPlayerViewCell  {
                menuCell.setup(urlString: messagePath, isSent: isSent)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .file:
            let nameOfFile = self.messageArray[indexPath.row].linkToFile
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileViewCell", for: indexPath) as? FileViewCell  {
                menuCell.setup(isSender: isSender, nameOfFile: nameOfFile, path: nameOfFile, isSent: isSent)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .linkPreView:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextLinkPreviewViewCell", for: indexPath) as? TextLinkPreviewViewCell  {
                let messageText = self.messageArray[indexPath.row].text ?? ""
                menuCell.setup(url: messagePath, fullText: messageText, isSender: isSender, isSent: isSent)
                cell = menuCell
            }
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let messageType = self.messageArray[indexPath.row].type
        
        switch messageType {
        case .text, .linkPreView:
            if let text = self.messageArray[indexPath.row].text {
                let apporximateWitdhOfTextView = 250
                
                let size = CGSize(width: apporximateWitdhOfTextView, height: 1000)
                
                let attribues = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
                
                let rect = NSString(string: text).boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: attribues, context: nil)
                
                let returnSize = CGSize(width: self.frame.width - 50 , height: rect.height + 20 + 20)
                if messageType == .linkPreView {
                    
//                    if let cell = collectionView.cellForItem(at: indexPath) as? TextLinkPreviewViewCell {
//
//                        let text = cell.textLabel.text
//                        let titel = cell.textTitle.text
//                        let description = cell.textDescriptionView.text
//
//                        let textHeight = self.getTextHeight(text: text)
//                        let titelHeight = self.getTextHeight(text: titel)
//                        let descriptionHeight = self.getTextHeight(text: description)
//
//                         return CGSize(width: self.frame.width - 50 , height: rect.height + 20 + 120 + textHeight + titelHeight + descriptionHeight)
//
//                    }

                    
                    return CGSize(width: self.frame.width - 50 , height: rect.height + 20 + 20 + 120)
                } else {
                    return returnSize
                }
            }
            
        case .gif:
            break
        case .photo:
           return CGSize(width: self.frame.width - 50, height: 300)
        case .video:
            return CGSize(width: self.frame.width - 50, height: 250)
        case .audio:
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
//                self.layoutIfNeeded()
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
        
        guard let messageText = self.inputTextField.text else {
            return
        }
        
        var shouldShowLinkView = false
        var URL = ""
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: messageText, options: [], range: NSRange(location: 0, length: messageText.utf16.count))
        
        for match in matches {
            guard let range = Range(match.range, in: messageText) else { continue }
            let url = messageText[range]
            print(url)
            URL = String(url)
            shouldShowLinkView = self.verifyUrl(urlString: String(url))
        }
        let newMessage : Message
        if shouldShowLinkView {
           let newlinkPreViewMessage = Message(messageType: .linkPreView, isSender: true, time: Date(), nameSender: self.userName, filePath: URL, imageTest: nil, messageText: messageText)!
            self.addNewMessageToCollectionView(newMessage: newlinkPreViewMessage)
            newMessage = newlinkPreViewMessage
        } else {
             let newTextMessage = Message(messageType: .text, isSender: true, time: Date(), nameSender: self.userName, filePath: "", imageTest: nil, messageText: messageText)!
             self.addNewMessageToCollectionView(newMessage: newTextMessage)
            newMessage = newTextMessage
        }
        
        self.messageDelegate?.userSendNewMessage(text: messageText, user: self.userName)
        self.messageDelegate?.newMessagdeAdded(message: newMessage)
       
        
        self.dismissKeyboard()
        self.inputTextField.text = ""
        self.inputTextHeightConstraint.constant = self.estamitedInputTextHeight
    }
    
    
    func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    func getTextHeight(text: String?) -> CGFloat {
        if let _text = text {
            let apporximateWitdhOfTextView = 250
            
            let size = CGSize(width: apporximateWitdhOfTextView, height: 1000)
            
            let attribues = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
            
            let rect = NSString(string: _text).boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: attribues, context: nil)
            
            return rect.height
        }
        return 0.0
     
    }

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        var VC = UIViewController()
        if let naviagtionController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            let currentController = naviagtionController.topViewController
            VC = currentController!
        }
        return VC
    }
    
}



extension ChatView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        debugPrint(textView.text)
        // if textView gets 5 time bigger active scroll and make static height
        if self.inputTextField.frame.height < 135 {
            let size = CGSize(width: self.inputTextField.frame.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            self.inputTextHeightConstraint.constant = estimatedSize.height
        } else if !self.inputTextField.isScrollEnabled {
            self.inputTextField.isScrollEnabled = true
        }
        
    }
   
}
