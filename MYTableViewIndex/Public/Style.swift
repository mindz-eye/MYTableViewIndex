//
//  Style.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 13/07/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

@objc public protocol Style {
    
    var font: UIFont { get }
    
    var itemSpacing: CGFloat { get }
}

struct StyleDefaults {
    
    static let font = UIFont.boldSystemFontOfSize(11.0)
    
    static let itemSpacing: CGFloat = 0.5
}
