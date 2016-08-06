//
//  IndexItem.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 02/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

@objc public protocol IndexItem {
    
    func sizeThatFits(size: CGSize) -> CGSize
    
    func blocksEdgeTruncation() -> Bool
    
    func applyStyle(style: Style)
}

extension UIView : IndexItem {
    
    public func blocksEdgeTruncation() -> Bool {
        return false
    }
    
    public func applyStyle(style: Style) {}
}

