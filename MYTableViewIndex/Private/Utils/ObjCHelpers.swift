//
//  ObjCHelpers.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 27/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import Foundation

// MARK: - Associated objects

private final class Box<T> {
    let value : T
    init (_ value: T) { self.value = value }
}

func setAssociatedObject<T>(object: AnyObject, key: UnsafePointer<Void>, value: T?, policy: objc_AssociationPolicy) {
    if let value = value {
        if let v = value as? AnyObject {
            objc_setAssociatedObject(object, key, v,  policy)
        } else {
            objc_setAssociatedObject(object, key, Box(value), .OBJC_ASSOCIATION_RETAIN)
        }
    } else {
        removeAssociatedObject(object, key: key)
    }
}

func removeAssociatedObject(object: AnyObject, key: UnsafePointer<Void>) {
    objc_setAssociatedObject(object, key, nil,  .OBJC_ASSOCIATION_ASSIGN)
}

func getAssociatedObject<T>(object: AnyObject, key: UnsafePointer<Void>) -> T? {
    if let v = objc_getAssociatedObject(object, key) as? T {
        return v
    } else if let v = objc_getAssociatedObject(object, key) as? Box<T> {
        return v.value
    } else {
        return nil
    }
}

// MARK: - Swizzling

func swizzleSelector(selector: Selector, withSelector: Selector, forClass: AnyClass) {
    let originalMethod = class_getInstanceMethod(forClass, selector)
    let swizzledMethod = class_getInstanceMethod(forClass, withSelector)
    method_exchangeImplementations(originalMethod, swizzledMethod)
}

func swizzleSelectorOnce(selector: Selector, withSelector: Selector, forClass: AnyClass) {
    struct Static {
        static var token: dispatch_once_t = 0
    }
    dispatch_once(&Static.token) {
        swizzleSelector(selector, withSelector: withSelector, forClass: forClass)
    }
}

// MARK: - Deinit handling

private var deinitKey = 0

extension NSObject {
    
    private final class DeinitHandler {
        
        var active: Bool = true        
        private let handler: () -> Void
        
        init(handler: () -> Void) {
            self.handler = handler
        }
        
        deinit {
            if active {
                handler()
            }
        }
    }
    
    var my_deinitHandler: (() -> Void)? {
        get {
            return getAssociatedObject(self, key: &deinitKey)
        }
        set {
            if let v = newValue {
                let hook = DeinitHandler(handler: v)
                setAssociatedObject(self, key: &deinitKey, value: hook, policy: .OBJC_ASSOCIATION_RETAIN)
            } else {
                let hook: DeinitHandler? = getAssociatedObject(self, key: &deinitKey)
                hook?.active = false
                removeAssociatedObject(self, key: &deinitKey)
            }
        }
    }
}