//
//  Message.swift
//  CollectionView
//
//  Created by Tobias Frantsen on 14/09/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import UIKit

enum messageType: String, RawRepresentable {
    case text
    case gif
    case photo
    case video
    case audio
    case file
    case linkPreView
    case unknow
}

class Message: NSObject, NSCopying {
    
    public var type: messageType
    public let sender: Bool
    public var timestamp: String
    public var nameOfSender: String
    public var linkToFile: String
    public var text: String?
    public var isSent: Bool?
    public var fileName: String?
    
    init?(messageType: messageType, isSender: Bool, time: String, nameSender: String, filePath: String, messageText: String?, fileName:String? = "") {
        
        self.type = messageType
        self.sender = isSender
        self.timestamp = time
        self.nameOfSender = nameSender
        self.linkToFile = filePath
        self.text = messageText
        self.fileName = fileName
       
       
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Message(messageType: type, isSender: sender, time: timestamp, nameSender: nameOfSender, filePath: linkToFile, messageText: text)
        return copy!
    }
    
    
}
