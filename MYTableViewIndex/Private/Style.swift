//
//  Style.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 06/06/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

class Style : IndexItemAttributes {
    
    let font: UIFont
    
    let itemSpacing: CGFloat
    
    let indexInset: UIEdgeInsets
    
    let indexOffset: UIOffset
    
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

struct StyleDefaults {
    
    static let font = UIFont.boldSystemFont(ofSize: 11.0)
    
    // Seems like Apple uses this constant and not the actual pixel size value
    static let itemSpacing: CGFloat = 0.5
    
    static let indexInset = UIEdgeInsets(top: CGFloat.greatestFiniteMagnitude, left: 1.0,
                                         bottom: CGFloat.greatestFiniteMagnitude, right: 1.0)
    
    static let indexOffset = UIOffset()
}
