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
import Reachability
import BRYXBanner

protocol typningMessageDelegate: class {
    func getTypningStatus(isEditning: Bool)
}

protocol MessageDelegate: class {
    func userSendNewMessage(text: String, user: String)
    func newMessageAdded(message: Message)
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
            self.newMessage(messageType: .gif, filePath: _url, fileName: nil)
        }
    }
    
    func getAudioBase64(_ url: String?) {
        self.dismissKeyboard()
        self.messageInputContainerView.isHidden = false
        self.inputTextField.inputAccessoryView = self.keyBoardTabView
        self.inputTextField.reloadInputViews()
        
        if let _url = url {
            self.newMessage(messageType: .audio, filePath: _url, fileName: nil)
        }
    }
    
 
    func newMessage(messageType: messageType, filePath: String, fileName: String?) {
        let today = Date()
        let stringDate = today.toString()
        
        
        if let message = self.createMessage(user: self.userName, date: stringDate, type: messageType, filePath: filePath, messageText: nil, fileName: fileName) {
            self.addNewMessageToCollectionView(newMessage: message)
            self.messageDelegate?.newMessageAdded(message: message)
        }
    }
    
    func createMessage(user: String, date: String, type: messageType, filePath: String,  messageText: String?, fileName: String?) -> Message?{
        
        let isSender = user == self.userName
        
        return Message(messageType: type, isSender: isSender, time: date, nameSender: user, filePath: filePath, messageText: messageText, fileName: fileName )
        
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
    
    let reachability = Reachability()!
    

    
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
        self.indicatorView.type = .ballPulse
        self.indicatorView.color = .red
        let size = CGSize(width: self.inputTextField.frame.width, height: .infinity)
        let estimatedSize = self.inputTextField.sizeThatFits(size)
        self.estamitedInputTextHeight = estimatedSize.height
        self.inputTextHeightConstraint.constant = estimatedSize.height
        
        self.inputTextField.delegate = self
        self.inputTextField.isScrollEnabled = false
        
        self.inputTextField.layer.cornerRadius = 5
        self.inputTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        self.inputTextField.layer.borderWidth = 1
        self.inputTextField.clipsToBounds = true
        
        self.collectionView?.isPrefetchingEnabled = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.keyBoardTabView.messageDelegate = self
        self.keyBoardTabView.keyboardDelegate = self
        self.inputTextField.inputAccessoryView = self.keyBoardTabView
        
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
        
        //declare this property where it won't go out of scope relative to your listener
        
       
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        let banner = Banner(title: "No Internet", backgroundColor: UIColor(red:211/255.0, green:21/255.0, blue:40/255.0, alpha:1.000))
        banner.dismissesOnTap = false
        
        self.reachability.whenUnreachable = { _ in
            banner.show()
        }
        
        self.reachability.whenReachable = { _ in
            banner.dismiss()
        }
        
        
    }
    
    @objc func dismissKeyboard() {
//        self.endEditing(true)
//        self.gifkeyboardView.textField.endEditing(true)
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
                    
                    DownloadController.load(url: path) { (url) in
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
        let isSender = self.messageArray[indexPath.row].sender
        let date = self.messageArray[indexPath.row].timestamp
        let isSent = self.messageArray[indexPath.row].isSent
        let userName = self.messageArray[indexPath.row].nameOfSender
       
        var cell = UICollectionViewCell()
        switch messageType {
        case .audio:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioPlayerViewCell", for: indexPath) as? AudioPlayerViewCell  {
                menuCell.setup(url: messagePath, isSent: isSent, userName: userName, date: date)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            
        case .text:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextViewCell", for: indexPath) as? TextViewCell  {
                let messageText = self.messageArray[indexPath.row].text
                
                menuCell.setup(text: messageText!, isSender: isSender, date: date, isSent: isSent, userName: userName)
                menuCell.textLabel.sizeToFit()
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
        case .gif:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as? ImageViewCell  {
                menuCell.setup(type: messageType, path: messagePath, isSender: isSender, isSent: isSent, userName: userName, date: date)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .photo:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as? ImageViewCell  {
                menuCell.setup(type: messageType, path: messagePath, isSender: isSender, isSent: isSent, userName: userName, date: date)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .video:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPlayerViewCell", for: indexPath) as? VideoPlayerViewCell  {
                menuCell.setup(urlString: messagePath, isSent: isSent, userName: userName, date: date)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .file:
            let nameOfFile = self.messageArray[indexPath.row].fileName
            let path = self.messageArray[indexPath.row].linkToFile
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileViewCell", for: indexPath) as? FileViewCell  {
                menuCell.setup(isSender: isSender, nameOfFile: nameOfFile, path: path, isSent: isSent, userName: userName, date: date)
                cell = menuCell
            } else {
                return UICollectionViewCell()
            }
            break
        case .linkPreView:
            if let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextLinkPreviewViewCell", for: indexPath) as? TextLinkPreviewViewCell  {
                let messageText = self.messageArray[indexPath.row].text ?? ""
                menuCell.setup(url: messagePath, fullText: messageText, isSender: isSender, isSent: isSent, userName: userName, date: date)
                cell = menuCell
            }
        case .unknow:
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
        case .text, .linkPreView:
            if let text = self.messageArray[indexPath.row].text {
                let apporximateWitdhOfTextView = 250
                
                let size = CGSize(width: apporximateWitdhOfTextView, height: 1000)
                
                let attribues = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
                
                let rect = NSString(string: text).boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: attribues, context: nil)
                
                var returnSize = CGSize(width: self.frame.width - 50 , height: rect.height + 20 + 20)
                if messageType == .linkPreView {
  
                    return CGSize(width: self.frame.width - 50 , height: rect.height + 20 + 20 + 120)
                } else {
                    if returnSize.width < 0 {
                        returnSize.width = 0
                    }
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
            return CGSize(width: self.frame.width - 50, height: 75)
        case .file:
            return CGSize(width: self.frame.width - 50, height: 60)
    
        case .unknow:
            break
            
            
        
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.getTypningStatus(isEditning: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
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
        let today = Date()
        let stringDate = today.toString()
        var newMessage : Message? = Message(messageType: .unknow, isSender: false, time: stringDate, nameSender: "", filePath: "", messageText: "")
        if shouldShowLinkView {
            if let newlinkPreViewMessage = Message(messageType: .linkPreView, isSender: true,time: stringDate, nameSender: self.userName, filePath: URL, messageText: messageText){
            self.addNewMessageToCollectionView(newMessage: newlinkPreViewMessage)
            newMessage = newlinkPreViewMessage
            }
        } else {
            if let newTextMessage = Message(messageType: .text, isSender: true, time: stringDate, nameSender: self.userName, filePath: "", messageText: messageText) {
                self.addNewMessageToCollectionView(newMessage: newTextMessage)
                newMessage = newTextMessage
            }

        }
        self.messageDelegate?.userSendNewMessage(text: messageText, user: self.userName)
        if let _message = newMessage {
            self.messageDelegate?.newMessageAdded(message: _message)
        }
       
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
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
