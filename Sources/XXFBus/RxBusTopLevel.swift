//
//  RxBusTopLevel.swift
//  xxf_ios
//
//  Created by xxf on 6/29.
//

import RxSwift

public func postEvent<T>(_ event: T) {
    return RxBus.shared.post(event)
}

public func postEventSticky<T>(_ event: T) {
    return RxBus.shared.postSticky(event)
}

public func subscribeEvent<T>(_ type: T.Type) -> Observable<T> {
    return RxBus.shared.observe(type)
}

public func observeEventSticky<T>(_ type: T.Type) -> Observable<T> {
    return RxBus.shared.observeSticky(type)
}
