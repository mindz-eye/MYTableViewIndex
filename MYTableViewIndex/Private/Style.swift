//
//  Style.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 06/06/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

class Style : IndexItemAttributes {
    
    let userInterfaceDirection: UIUserInterfaceLayoutDirection
    let font: UIFont
    let itemSpacing: CGFloat
    let indexInset: UIEdgeInsets
    let indexOffset: UIOffset
    let minWidth: CGFloat
    
    init(userInterfaceDirection: UIUserInterfaceLayoutDirection,
         font: UIFont? = nil,
         itemSpacing: CGFloat? = nil,
         indexInset: UIEdgeInsets? = nil,
         indexOffset: UIOffset? = nil,
         minWidth: CGFloat? = nil) {
        self.userInterfaceDirection = userInterfaceDirection
        self.font = font ?? StyleDefaults.font
        self.itemSpacing = itemSpacing ?? StyleDefaults.itemSpacing
        self.indexInset = indexInset ?? StyleDefaults.indexInset
        self.indexOffset = indexOffset ?? StyleDefaults.indexOffset
        self.minWidth = minWidth ?? StyleDefaults.minWidth
    }
    
    func copy(applying userInterfaceDirection: UIUserInterfaceLayoutDirection) -> Style {
        return Style(userInterfaceDirection: userInterfaceDirection, font: font, itemSpacing: itemSpacing, indexInset: indexInset, indexOffset: indexOffset, minWidth: minWidth)
    }
    
    func copy(applying font: UIFont) -> Style {
        return Style(userInterfaceDirection: userInterfaceDirection, font: font, itemSpacing: itemSpacing, indexInset: indexInset, indexOffset: indexOffset, minWidth: minWidth)
    }
    
    func copy(applying itemSpacing: CGFloat) -> Style {
        return Style(userInterfaceDirection: userInterfaceDirection, font: font, itemSpacing: itemSpacing, indexInset: indexInset, indexOffset: indexOffset, minWidth: minWidth)
    }

    func copy(applying indexInset: UIEdgeInsets) -> Style {
        return Style(userInterfaceDirection: userInterfaceDirection, font: font, itemSpacing: itemSpacing, indexInset: indexInset, indexOffset: indexOffset, minWidth: minWidth)
    }

    func copy(applying indexOffset: UIOffset) -> Style {
        return Style(userInterfaceDirection: userInterfaceDirection, font: font, itemSpacing: itemSpacing, indexInset: indexInset, indexOffset: indexOffset, minWidth: minWidth)
    }

    func copy(applyingMinWidth minWidth: CGFloat) -> Style {
        return Style(userInterfaceDirection: userInterfaceDirection, font: font, itemSpacing: itemSpacing, indexInset: indexInset, indexOffset: indexOffset, minWidth: minWidth)
    }
}

struct StyleDefaults {
    
    static let font = UIFont.boldSystemFont(ofSize: 11.0)
    
    // Seems like Apple uses this constant and not the actual pixel size value
    static let itemSpacing: CGFloat = 0.5
    
    static let indexInset = UIEdgeInsets(top: CGFloat.greatestFiniteMagnitude, left: 1.0,
                                         bottom: CGFloat.greatestFiniteMagnitude, right: 1.0)
    
    static let indexOffset = UIOffset()
    static let minWidth: CGFloat = 44.0
}
