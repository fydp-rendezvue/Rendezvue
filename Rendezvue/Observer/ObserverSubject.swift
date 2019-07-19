//
//  ObserverSubject.swift
//  Rendezvue
//
//  Created by Jack Lin on 2019-07-18.
//  Copyright © 2019 Rendezvue. All rights reserved.
//

class ObserverSubject {
    private var observerArray = [Observer]()
    private var _number = Int()
    var number : Int {
        set {
            _number = newValue
            notify()
        }
        
        get {
            return _number
        }
    }
    
    func attachObserver(observer : Observer) {
        observerArray.append(observer)
    }
    
    public func notify() {
        for observer in observerArray {
            observer.update()
        }
    }
}
