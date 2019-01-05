//
//  ExtensionDate.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 05/01/2019.
//  Copyright © 2019 Tobias Frantsen. All rights reserved.
//

import Foundation

extension Date
{
    func toString() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy, h:mm:ss a "
        
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
    
        return dateFormatter.string(from: self)
    }
    
}
