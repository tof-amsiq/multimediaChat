//
//  RxExtension.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 22/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import RxSwift
import SocketIO

extension Reactive where Base: SocketIOClient {
    
    public func on(_ event: String) -> Observable<[Any]> {
        return Observable.create { observer in
            let id = self.base.on(event) { items, _ in
                observer.onNext(items)
            }
            
            return Disposables.create {
                self.base.off(id: id)
            }
        }
    }
}
