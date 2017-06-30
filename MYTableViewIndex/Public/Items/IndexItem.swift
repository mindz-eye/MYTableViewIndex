//
//  IndexItem.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 02/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

/// Protocol for customizing index item behavior.
@objc (MYIndexItem)
public protocol IndexItem {
    
    /// Returns the size that best fits the specified size.
    func sizeThatFits(_ size: CGSize) -> CGSize
    
    /// Indicates that the closest neighborhood of this item can not be truncated. The flag is only
    /// checked if the receiver is the first or the last item in the index sequence.
    /// The method is used to mimic UITableView behavior. E.g, it never truncates items
    /// after search item and before # sign.
    func blocksEdgeTruncation() -> Bool
    
    /// Implement this method to apply style attributes of table index to the item.
    func applyAttributes(_ attributes: IndexItemAttributes)
}

/// Container for item appearance attributes.
@objc (MYIndexItemAttributes)
public protocol IndexItemAttributes {
    
    var font: UIFont { get }
}

extension UIView : IndexItem {
    
    public func blocksEdgeTruncation() -> Bool {
        return false
    }
    
    public func applyAttributes(_ attributes: IndexItemAttributes) {}
}

