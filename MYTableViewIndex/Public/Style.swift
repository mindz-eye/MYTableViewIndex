//
//  Style.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 13/07/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

@objc(MYTableViewIndexStyle)
public protocol Style {
    
    var font: UIFont { get }
    
    var itemSpacing: CGFloat { get }
    
    var indexInset: UIEdgeInsets { get }
    
    var indexOffset: UIOffset { get }
}

struct StyleDefaults {
    
    static let font = UIFont.boldSystemFont(ofSize: 11.0)
 
    // Seems like Apple uses this constant and not the actual pixel size value
    static let itemSpacing: CGFloat = 0.5
    
    static let indexInset = UIEdgeInsets(top: CGFloat.greatestFiniteMagnitude, left: pixelScale(),
                                           bottom: CGFloat.greatestFiniteMagnitude, right: pixelScale())
    
    static let indexOffset = UIOffset(horizontal: 0.0, vertical: 1.0)
}
