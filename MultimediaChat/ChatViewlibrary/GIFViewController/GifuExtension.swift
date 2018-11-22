//
//  GifuExtension.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 14/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import Gifu
import Nuke
import UIKit



extension Gifu.GIFImageView {
    public override func display(image: Image?) {
        prepareForReuse()
        if let data = image?.animatedImageData {
//            animate(withGIFData: data)
            animate(withGIFData: data, loopCount: 2, completionHandler: nil)
        } else {
            self.image = image
        }
    }
    
    
}


