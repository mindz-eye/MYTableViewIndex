//
//  Metrics.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 03/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

struct Metrics {
    
    private(set) var itemSizes = [CGSize]()
    private(set) var size = CGSize()
    private(set) var medianSize = CGSize()
    
    let style: Style
    
    init(items: [IndexItem], style: Style) {
        self.style = style
        calculate(with: items)
    }
    
    private mutating func calculate(with items: [IndexItem]) {
        var widths = [CGFloat]()
        var heights = [CGFloat]()
        
        var sizes = [CGSize]()
        var maxWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        
        let bbox = style.font.my_boundingSize()
        
        for item in items {
            let size = item.sizeThatFits(CGSize(width: bbox.width, height: bbox.height))
            
            sizes.append(size)
            
            if size.width > maxWidth {
                maxWidth = size.width
            }
            totalHeight += size.height + style.itemSpacing
            
            widths.append(size.width)
            heights.append(size.height)
        }
        itemSizes = sizes
        size = CGSize(width: bbox.width, height: totalHeight)
        
        widths.sort()
        heights.sort()
        
        let count = items.count
        if (count > 0) {
            if count % 2 == 0 {
                medianSize = CGSize(width: (widths[count / 2] + widths[count / 2 - 1]) / 2,
                                    height: (heights[count / 2] + heights[count / 2 - 1]) / 2)
            } else {
                medianSize = CGSize(width: widths[count / 2], height: heights[count / 2])
            }
        } else {
            medianSize = CGSize()
        }
    }
}
