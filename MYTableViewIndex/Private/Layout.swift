//
//  Layout.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 06/06/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

struct ItemLayout<T: IndexItem> {
    
    let frames: [CGRect]
    let size: CGSize
    
    init(items: [T], style: Style) {
        let bbox = style.font.my_boundingSize()
        
        var height: CGFloat = 0
        var frames: [CGRect] = [CGRect]()
        
        for item in items {
            let size = item.sizeThatFits(CGSize(width: bbox.width, height: bbox.height)).pixelCeiled()
            
            var frame = CGRect(origin: CGPoint(x: 0, y: height), size: size)
            frame.centerX = bbox.width / 2
            frame.origin = frame.origin.pixelRounded()
            
            frames.append(frame)
            
            height += frame.height + style.itemSpacing
        }
        self.frames = frames
        self.size = CGSize(width: bbox.width, height: height).pixelRounded()
    }
}

struct Layout<T: IndexItem> {
    
    let itemLayout: ItemLayout<T>
    let backgroundFrame: CGRect
    let contentFrame: CGRect

    init(items: [T], style: Style, bounds: CGRect) {
        self.itemLayout = ItemLayout(items: items, style: style)
        
        var contentFrame = CGRect(origin: CGPoint(), size: itemLayout.size)
        if style.userInterfaceDirection == .rightToLeft {
            contentFrame.left = bounds.left + style.indexInset.right + style.indexOffset.horizontal
        } else {
            contentFrame.right = bounds.right - style.indexInset.right + style.indexOffset.horizontal
        }
        contentFrame.centerY = bounds.centerY + style.indexOffset.vertical
        
        self.contentFrame = contentFrame
        
        var backgroundFrame = contentFrame.insetBy(UIEdgeInsets(top: 0, left: -style.indexInset.left, bottom: 0, right: -style.indexInset.right))
        
        let unboundTopInset = style.indexInset.top == CGFloat.greatestFiniteMagnitude
        let unboundBottomInset = style.indexInset.bottom == CGFloat.greatestFiniteMagnitude

        backgroundFrame.moveTop(unboundTopInset ? 0 : backgroundFrame.top - style.indexInset.top)
        backgroundFrame.moveBottom(unboundBottomInset ? bounds.bottom : backgroundFrame.bottom + style.indexInset.bottom)

        self.backgroundFrame = backgroundFrame
    }
}
