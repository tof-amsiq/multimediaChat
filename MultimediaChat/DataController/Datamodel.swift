//
//  Datamodel.swift
//  CollectionView
//
//  Created by Tobias Frantsen on 01/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import UIKit

class Datamodel: NSObject {
    
    private var mesageArray: [Message]
    private let sender: Bool
    private var timestamp: Date
    
    init?(message: [Message], isSender: Bool, time: Date) {
        self.mesageArray = message
        self.sender = isSender
        self.timestamp = time
        
    }
    
    
}

//import UIKit
//
//class Chair {
//    var name: String
//    var designer: String
//    var image: UIImage
//
//    init?(name: String, designer: String, image: UIImage? = UIImage(named: "defaultImage")) {
//
//        guard !name.isEmpty || !designer.isEmpty else {
//            return nil
//        }
//        guard let chairImage = image else {
//            return nil
//        }
//        self.name = name
//        self.designer = designer
//        self.image = chairImage
//    }
//}
