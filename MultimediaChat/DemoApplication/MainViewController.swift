//
//  TestViewController.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 12/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import BRYXBanner
import SwiftyJSON
import RealmSwift
import Reachability
import UIKit

class MainViewController: UIViewController, MessageDelegate, typningMessageDelegate {
    
    func getTypningStatus(isEditning: Bool) {
        if isEditning {
//            self.multimediaChatView.typeIndicatorView.startAnimating()
            SocketIOManager.shared.startTypning(_nickName: self.userName ?? "")
        } else {
//            self.multimediaChatView.typeIndicatorView.stopAnimating()
            SocketIOManager.shared.stopTypning(nickName: self.userName ?? "")
        }
    }
    
    
 
    
    func newMessageAdded(message: Message) {
        let newMessage = message.copy() as! Message
        
        if (newMessage.type == .video ) || (newMessage.type == .file) || (newMessage.type == .audio) {
            
            newMessage.fileName = message.fileName
            if let url = URL(string: message.linkToFile), let data = NSData(contentsOf: url) {
                let strBase64 = data.base64EncodedString(options: .lineLength64Characters)
                newMessage.linkToFile = strBase64
            }
        }
        
     let ack = SocketIOManager.shared.sendNewMessage(message: newMessage)
        ack?.timingOut(after: 3, callback: { (response) -> Void in
            if let ackString = response.first as? String {
                if ackString == "NO ACK" && self.reachability.connection == .none {
                    message.isSent = false
                    self.multimediaChatView.collectionView.reloadData()
                    let realm = try! Realm()
                    
                    try! realm.write {
                        let message = MultimediaMessage(messageType: newMessage.type.rawValue, time: newMessage.timestamp, nameSender: newMessage.nameOfSender, filePath: newMessage.linkToFile, messageText: newMessage.text, fileName: newMessage.fileName)
                        message.isSent = false
                        realm.add(message, update: true)
                    }
                }
                if ackString == "true" {
                    message.isSent = true
                }
            }
        })
    }
    
    func userSendNewMessage(text: String, user: String) {
//         SocketIOManager.shared.sendMessage(message: text, withNickname: user)
    }
    
    
   
    
   

    @IBOutlet weak var multimediaChatView: ChatView!
       var userName: String?
     let reachability = Reachability()!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.multimediaChatView.messageDelegate = self
        self.multimediaChatView.delegate = self
        self.multimediaChatView.setUsername(name: self.userName!)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        
        self.reachability.whenUnreachable = { _ in
//          SocketIOManager.shared.disconnectSocket()
        }
        
        
        self.reachability.whenReachable = { _ in
            SocketIOManager.shared.connectSocket()
            let realm = try! Realm()
         let notSendMessage = realm.objects(MultimediaMessage.self).filter("isSent = false")
        self.sendOfflineMessageToServer(messageResults: notSendMessage)
            
        }
        
       

        let ack = SocketIOManager.shared.getChatHistory(last: 20)
        
        ack?.timingOut(after: 3, callback: { (response) -> Void in
            if let ackString = response.first as? String {
                if ackString == "NO ACK" {
                    let realm = try! Realm()
                    let results = realm.objects(MultimediaMessage.self)
                   let listOfMessage = results.reduce(List<MultimediaMessage>()) { (list, element) -> List<MultimediaMessage> in
                        list.append(element)
                        return list
                    }
                    
                    for message in listOfMessage {
                        let type = messageType(rawValue: message.type) ?? messageType.unknow
                        if let newMessage = self.multimediaChatView.createMessage(user: message.nameOfSender, date: message.timestamp ?? "", type: type, filePath: message.linkToFile, messageText: message.text, fileName: message.fileName) {
                            self.multimediaChatView.addNewMessageToCollectionView(newMessage: newMessage)
                            
                        }
                    }
                    
                   
                    
                }
            }
        })

        // Do any additional setup after loading the view.
        _ = SocketIOManager.shared.socket.rx.on("testnewChatMessage").subscribe { (message) in
          
            if let array = message.element?[0] as? [String: Any] {
                let fileName = array["fileName"] as? String ?? ""
                let date = array["date"] as? String ?? ""
                let messageText = array["messageText"] as? String ?? ""
                let path = array["path"] as? String ?? ""
                let type = array["messageType"] as? String ?? ""
                let user = array["user"] as? String ?? ""

            
            
            let typeOfMessage = messageType(rawValue: type) ?? messageType.unknow
 
            
            var shouldAddMessageToCollectionView = true
            if user == self.userName {
                shouldAddMessageToCollectionView = false
            }
            

            if let newMessage = self.multimediaChatView.createMessage(user: user, date: date, type: typeOfMessage, filePath: path, messageText: messageText, fileName: fileName), shouldAddMessageToCollectionView {
                self.multimediaChatView.addNewMessageToCollectionView(newMessage: newMessage)
            }
            }
            
            }
        
        _ =  SocketIOManager.shared.socket.rx.on("chatHistory")
            .subscribe { (jsonArray) in
                var messageArray: [MultimediaMessage] = [MultimediaMessage]()
                if let responseString = jsonArray.element?[0] as? String, let dataFromString = responseString.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    
                    if let json = try? JSON(data: dataFromString) {
                        messageArray = MultimediaMessage.parse(json: json)
                    }
                    let realm = try! Realm()
                    
                    let allMessageObjects = realm.objects(MultimediaMessage.self)
                    
                    try! realm.write {
                        realm.delete(allMessageObjects)
                    }
                   
                    self.addArrayToChatView(messageArray: messageArray)

                    
               

                }
                
                
        }
        
        
        _ = SocketIOManager.shared.socket.rx.on("userTypingUpdate").subscribe { (user) in
            
            var totalTypingUser = 0
            
            for (_, typingUser) in user.element!.enumerated() {
                debugPrint("NU ER JEG I FOR")
                if let user = typingUser as? [String: AnyObject] {
                    if (user.first?.key != self.userName) && (user.first?.value as? Int  == 1) {
                        totalTypingUser += 1
                    }
                }
            }
            debugPrint(totalTypingUser)
            if totalTypingUser > 0 {
                self.multimediaChatView.indicatorView.startAnimating()
            } else {
                self.multimediaChatView.indicatorView.stopAnimating()
            }
            
        }
        
        _ = SocketIOManager.shared.socket.rx.on("userConnectUpdate").subscribe { (user) in
            debugPrint(user)
            let userJoined = user.element?[0] as? [String : Any]
            let name = userJoined?["nickname"] as? String ?? ""
           
            if name != self.userName {
                let banner = Banner(title: "\(name) has just join the chat", backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                banner.dismissesOnTap = true
                banner.show(duration: 2.0)
            }
            
            
        }
        
        
       
      
    }
    
    
    
    
    func addArrayToChatView(messageArray: [MultimediaMessage]) {
        for message in messageArray {
            let user = message.nameOfSender
            let date = message.timestamp ?? ""
            let type = messageType(rawValue: message.type) ?? messageType.unknow
            let filePath = message.linkToFile
            let text = message.text
            let fileName = message.fileName
            
            if let newMessage = self.multimediaChatView.createMessage(user: user, date: date, type: type, filePath: filePath, messageText: text, fileName: fileName) {
                self.multimediaChatView.addNewMessageToCollectionView(newMessage: newMessage)
                
                
                let realm = try! Realm()
                try! realm.write {
                    realm.add(message, update: true)
                }
                
            }
            
        }
    }
    
    func sendOfflineMessageToServer(messageResults: Results<MultimediaMessage>) {
        for message in messageResults {
            let user = message.nameOfSender
            let date = message.timestamp ?? ""
            let type = messageType(rawValue: message.type) ?? messageType.unknow
            let filePath = message.linkToFile
            let text = message.text
            let fileName = message.fileName
            
            if let newMessage = self.multimediaChatView.createMessage(user: user, date: date, type: type, filePath: filePath, messageText: text, fileName: fileName) {
                newMessage.isSent = true
                
                
               _ = SocketIOManager.shared.sendNewMessage(message: newMessage)
            }
        }
        self.multimediaChatView.collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SocketIOManager.shared.exitUser(clientNickname: self.userName ?? "")
    }
    
   
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
