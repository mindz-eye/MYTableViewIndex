//
//  KeyValueObserver.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 27/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import Foundation

private var KVOContext = 0

final class KeyValueObserver : NSObject {
    
    private weak var observedObject: NSObject?
    private let observedKeyPaths: [String]
    private let observeHandler: (keyPath: String) -> ()
    private var observing: Bool = false
    
    init(object: NSObject, keyPaths: [String], handler: (keyPath: String) -> ()) {
        observedObject = object
        observedKeyPaths = keyPaths
        observeHandler = handler
        super.init()
        
        observe()
        
        object.my_deinitHandler = {[weak self, unowned(unsafe) object] in
            self?.unobserveObject(object)
        }
    }
    
    deinit {
        unobserve()
    }
    
    private func observe() {
        if observing {
            return
        }
        for keyPath in observedKeyPaths {
            observedObject?.addObserver(self, forKeyPath: keyPath, options: [.Initial, .New], context: &KVOContext)
        }
        observing = true
    }
    
    private func unobserve() {
        if let observed = observedObject {
            unobserveObject(observed)
        }
    }
    
    private func unobserveObject(object: NSObject) {
        if !observing {
            return
        }
        for keyPath in observedKeyPaths {
            object.removeObserver(self, forKeyPath: keyPath)
        }
        observing = false
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let keyPath = keyPath where context == &KVOContext {
            observeHandler(keyPath: keyPath)
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}