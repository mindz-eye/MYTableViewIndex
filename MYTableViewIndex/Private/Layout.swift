//
//  Layout.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 06/06/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

struct Layout {
    
    let items: [IndexItem]
    let metrics: Metrics
    var itemFrames = [CGRect]()
    
    init(items: [IndexItem], style: Style) {
        self.items = items
        metrics = Metrics(items: items, style: style)
    }
    
    mutating func layout(in rect: CGRect) {
        var yPos: CGFloat = 0
        
        var frames = [CGRect]()
        
        for (index, _) in items.enumerated() {
            var itemRect = CGRect(origin: CGPoint(x: 0, y: yPos), size: metrics.itemSizes[index])
            itemRect.centerX = rect.centerX
            itemRect.origin = roundToPixelBorder(itemRect.origin)
            
            frames.append(itemRect)
            
            yPos += itemRect.height + metrics.style.itemSpacing
        }
        itemFrames = frames
    }
}
