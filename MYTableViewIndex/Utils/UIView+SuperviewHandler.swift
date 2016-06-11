//
//  UIView+SuperviewHandler.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 26/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

private var didMoveToSuperviewHandlerKey = 0

extension UIView {
    
    var my_didMoveToSuperviewHandler: ((UIView?) -> Void)? {
        get {
            return getAssociatedObject(self, key: &didMoveToSuperviewHandlerKey)
        }
        set {
            setAssociatedObject(self, key: &didMoveToSuperviewHandlerKey, value: newValue, policy: .OBJC_ASSOCIATION_COPY)

            swizzleSelectorOnce(#selector(UIView.didMoveToSuperview), withSelector: #selector(UIView.my_didMoveToSuperview),
                                forClass: UIView.self)
            
            if let handler = newValue, superview = superview {
                handler(superview)
            }
        }
    }
    
    func my_didMoveToSuperview() {
        my_didMoveToSuperview()
        
        if let handler = my_didMoveToSuperviewHandler {
            handler(superview)
        }
    }
}


