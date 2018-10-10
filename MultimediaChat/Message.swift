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
    case aduio
    case file
}

class Message: NSObject {
    
    public var type: messageType
    public let sender: Bool
    public var timestamp: Date
    public var nameOfSender: String
    public var linkToFile: String
    public var image: UIImage?
    
    init?(messageType: messageType, isSender: Bool, time: Date, nameSender: String, filePath: String, imageTest: UIImage?) {
        
        self.type = messageType
        self.sender = isSender
        self.timestamp = time
        self.nameOfSender = nameSender
        self.linkToFile = filePath
        self.image = imageTest
       
    }
    
    
}
