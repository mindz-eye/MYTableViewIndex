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
    private let observeHandler: (_ keyPath: String) -> ()
    private var observing: Bool = false
    
    init(object: NSObject, keyPaths: [String], handler: @escaping (_ keyPath: String) -> ()) {
        observedObject = object
        observedKeyPaths = keyPaths
        observeHandler = handler
        super.init()
        
        observe()
        
        object.my_deinitHandler = {[weak self, unowned(unsafe) object] in
            self?.unobserve(object)
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
            observedObject?.addObserver(self, forKeyPath: keyPath, options: [.initial, .new], context: &KVOContext)
        }
        observing = true
    }
    
    private func unobserve() {
        if let observed = observedObject {
            unobserve(observed)
        }
    }
    
    private func unobserve(_ object: NSObject) {
        if !observing {
            return
        }
        for keyPath in observedKeyPaths {
            object.removeObserver(self, forKeyPath: keyPath)
        }
        observing = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let keyPath = keyPath , context == &KVOContext {
            observeHandler(keyPath)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
