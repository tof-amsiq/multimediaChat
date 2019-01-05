//
//  SocketMessageController.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 22/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import RxSwift
import UIKit


class SocketMessageController  {
    
        static let shared = SocketMessageController()
    func getMessage() {
       
      
        
        let test = SocketIOManager.shared.getData().subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { (message) in
                print("Tobias\(message)")
            })
        
        
        
    }
}
