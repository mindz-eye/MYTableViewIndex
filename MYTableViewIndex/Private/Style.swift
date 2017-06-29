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
    
    init(font: UIFont = StyleDefaults.font,
         itemSpacing: CGFloat = StyleDefaults.itemSpacing,
         indexInset: UIEdgeInsets = StyleDefaults.indexInset,
         indexOffset: UIOffset = StyleDefaults.indexOffset) {
        self.font = font
        self.itemSpacing = itemSpacing
        self.indexInset = indexInset
        self.indexOffset = indexOffset
    }
    
    func copy(applying font: UIFont) -> Style {
        return Style(font: font, itemSpacing: itemSpacing, indexInset: indexInset, indexOffset: indexOffset)
    }
    
    func copy(applying itemSpacing: CGFloat) -> Style {
        return Style(font: font, itemSpacing: itemSpacing, indexInset: indexInset, indexOffset: indexOffset)
    }

    func copy(applying indexInset: UIEdgeInsets) -> Style {
        return Style(font: font, itemSpacing: itemSpacing, indexInset: indexInset, indexOffset: indexOffset)
    }

    func copy(applying indexOffset: UIOffset) -> Style {
        return Style(font: font, itemSpacing: itemSpacing, indexInset: indexInset, indexOffset: indexOffset)
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
