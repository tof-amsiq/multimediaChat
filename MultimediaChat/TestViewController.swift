//
//  TestViewController.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 12/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import SwiftyJSON
import UIKit

class TestViewController: UIViewController, MessageDelegate {
    
 
    
    func newMessagdeAdded(message: Message) {
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
                if ackString == "NO ACK" {
                    message.isSent = false
                    self.test.collectionView.reloadData()
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
    
    
   
    
   

    @IBOutlet weak var test: ChatView!
       var userName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.test.messageDelegate = self
        self.test.setUsername(name: self.userName!)
      
        
        SocketIOManager.shared.getChatHistory(last: 20)

        // Do any additional setup after loading the view.
        _ = SocketIOManager.shared.socket.rx.on("testnewChatMessage").subscribe { (message) in
            debugPrint(message)
            
            }
        
        _ =  SocketIOManager.shared.socket.rx.on("chatHistory")
            .subscribe { (jsonArray) in
                
                if let responseString = jsonArray.element?[0] as? String, let dataFromString = responseString.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    
                    let json = try? JSON(data: dataFromString)
                    debugPrint("plen\(json)")
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                  
                    for (message) in json ?? [] {

                        let user = message.1["user"].stringValue
                        let date = message.1["date"].stringValue
                        let text = message.1["messageText"].stringValue
                        let type = messageType(rawValue: message.1["messageType"].stringValue) ?? messageType.text
                        let path = message.1["path"].stringValue
                        let nameOfFile = message.1["fileName"].stringValue
                        
                        
                       let datevalue = dateFormatter.date(from: date) ?? Date()
                        
                        if  let newMessage = self.test.createMessage(user: user, date: datevalue, type: type, filePath: path, messageText: text, fileName: nameOfFile) {
                              self.test.addNewMessageToCollectionView(newMessage: newMessage)
                        }
                      
                    }
                    
               

                }
                
                
        }
      
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
