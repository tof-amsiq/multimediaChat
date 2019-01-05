//
//  DownloadController.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 10/12/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import UIKit
class DownloadController {
    
    class func load(url: String, completion: @escaping (_ path: URL?) -> ()) {
        // Create destination URL
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        
    
        let fileArray = url.components(separatedBy: ".")
        let fileName = fileArray.first ?? ""
        let fileType = fileArray.last ?? ""
        var _fileName = ""
        if let range = fileName.range(of: "uploads/") {
             _fileName = fileName[range.upperBound...].trimmingCharacters(in: .whitespaces)
            
        }
        
        let destinationFileUrl = documentsUrl.appendingPathComponent("downloadedFile_\(_fileName).\(fileType)")
        
       
        if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
            completion(destinationFileUrl)
            return 
        }
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: url)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    completion(destinationFileUrl)
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
            }
        }
        task.resume()
        
    }
}
