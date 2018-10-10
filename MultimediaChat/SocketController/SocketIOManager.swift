//
//  SocketIOManager.swift
//  socketApp
//
//  Created by Tobias Frantsen on 29/08/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import SocketIO
import UIKit

class SocketIOManager: NSObject {
    
    static let shared = SocketIOManager()
    
    static let manager = SocketManager(socketURL: URL (string: "http://localhost:3000")!)
    let socket = manager.defaultSocket
    
    
    func connectSocket(){
        socket.connect()
        
    }
    
    
    func connectToServerWithNickname(nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
        socket.emit("connectUser", nickname)
        
        socket.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(dataArray[0] as! [[String: AnyObject]])
        }
        
    }
    
    func uploadData(data: NSData, nameOfFile: String){
        socket.emit("test", data, nameOfFile)
    }
    
    func sendMessage(message: String, withNickname nickname: String) {
        socket.emit("chatMessage", nickname, message)
    }
    
    func startTypning(_nickName: String) {
        socket.emit("startType", _nickName)
        
        socket.on("userTypingUpdate") { (message, ack)  -> Void in
            debugPrint(ack)
            debugPrint(message)
        }
    }
    
    func sendMessage(nickName:String, message: String) {
        socket.emit("chatMessage", nickName, message)
        
    }
    
    func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["nickname"] = dataArray[0] as AnyObject
            messageDictionary["message"] = dataArray[1] as AnyObject
            messageDictionary["date"] = dataArray[2] as AnyObject
            
            completionHandler( messageDictionary)
        }
    }
    
    func uploadFile(){
        
        let url = URL(string: "file:///Users/tobiasfrantsen/Downloads/icon.png")!
        //        let data = try? Data(contentsOf: url!)
        
        //Now use image to create into NSData format
        let imageData:NSData = NSData.init(contentsOf: url)!
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        
        // Do whatever you want with the image
        socket.emit("start", strBase64)
        
    }
    
}
