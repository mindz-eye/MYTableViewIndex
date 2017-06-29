//
//  ConcreteStyle.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 06/06/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

class ConcreteStyle : Style, IndexItemAttributes {
    
    @objc let font: UIFont
    
    @objc let itemSpacing: CGFloat
    
    @objc let indexInset: UIEdgeInsets
    
    @objc let indexOffset: UIOffset
    
    init(font: UIFont?, itemSpacing: CGFloat?, indexInset: UIEdgeInsets?, indexOffset: UIOffset?) {
        self.font = font ?? StyleDefaults.font
        self.itemSpacing = itemSpacing ?? StyleDefaults.itemSpacing
        self.indexInset = indexInset ?? StyleDefaults.indexInset
        self.indexOffset = indexOffset ?? StyleDefaults.indexOffset
    }
    
    convenience init() {
        self.init(font: nil, itemSpacing: nil, indexInset: nil, indexOffset: nil)
    }
}
