//
//  MultimediaMessage.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 03/01/2019.
//  Copyright © 2019 Tobias Frantsen. All rights reserved.
//

import SwiftyJSON
import RealmSwift
import UIKit

class MultimediaMessage: Object {
   @objc dynamic var messageID = NSUUID().uuidString
    
   @objc dynamic  var type: String = ""
   @objc dynamic  var timestamp: String? = ""
   @objc dynamic  var nameOfSender: String = ""
   @objc dynamic  var linkToFile: String = ""
   @objc dynamic  var text: String? = nil
   @objc dynamic  var isSent = true
   @objc dynamic  var fileName: String? = nil

    
    
    convenience init(messageType: String, time: String, nameSender: String, filePath: String, messageText: String?, fileName:String? = "") {
        self.init()
        self.type = messageType
        self.timestamp = time
        self.nameOfSender = nameSender
        self.linkToFile = filePath
        self.text = messageText
        self.fileName = fileName
    }
    
    
    class func parse(json: JSON) -> [MultimediaMessage] {
        
        var messageArray: [MultimediaMessage] = [MultimediaMessage]()
        
        for (message) in json {
            let user = message.1["user"].stringValue
            let date = message.1["date"].stringValue
            let text = message.1["messageText"].stringValue
            let type = message.1["messageType"].stringValue 
            let path = message.1["path"].stringValue
            let nameOfFile = message.1["fileName"].stringValue
            
            
            
           let newMessage = MultimediaMessage(messageType: type, time: date, nameSender: user, filePath: path, messageText: text, fileName: nameOfFile)
            
            messageArray.append(newMessage)
            
            
        }
        
        return messageArray
    }
    
    override class func primaryKey() -> String? {
        return "messageID"
    }
    
}
