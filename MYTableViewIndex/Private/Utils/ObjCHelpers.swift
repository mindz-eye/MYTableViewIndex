//
//  ObjCHelpers.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 27/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import Foundation

// MARK: - Associated objects

func setAssociatedObject<T>(_ object: AnyObject, key: UnsafeRawPointer, value: T?, policy: objc_AssociationPolicy) {
    if let value = value {
        objc_setAssociatedObject(object, key, value,  policy)
    } else {
        removeAssociatedObject(object, key: key)
    }
}

func removeAssociatedObject(_ object: AnyObject, key: UnsafeRawPointer) {
    objc_setAssociatedObject(object, key, nil,  .OBJC_ASSOCIATION_ASSIGN)
}

func getAssociatedObject<T>(_ object: AnyObject, key: UnsafeRawPointer) -> T? {
    if let v = objc_getAssociatedObject(object, key) as? T {
        return v
    } else {
        return nil
    }
}

// MARK: - Swizzling

func swizzle(_ selector: Selector, with withSelector: Selector, for clazz: AnyClass) {
    if let originalMethod = class_getInstanceMethod(clazz, selector),
       let swizzledMethod = class_getInstanceMethod(clazz, withSelector) {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

var swizzled = false

func swizzleOnce(_ selector: Selector, with withSelector: Selector, for clazz: AnyClass) {
    if (!swizzled) {
        swizzle(selector, with: withSelector, for: clazz)
        swizzled = true
    }
}

// MARK: - Deinit handling

private var deinitKey = 0

extension NSObject {
    
    private final class DeinitHandler {
        
        var active: Bool = true        
        private let handler: () -> Void
        
        init(handler: @escaping () -> Void) {
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
