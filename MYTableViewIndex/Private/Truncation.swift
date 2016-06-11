//
//  Truncation.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 02/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

struct Truncation<T: IndexItem> {
    
    private let items: [T]
    private let truncationItemFactory: () -> T
    
    init(items: [T], truncationItemFactory: () -> T) {
        self.items = items
        self.truncationItemFactory = truncationItemFactory
    }
    
    func truncate(forHeight height: CGFloat, style: Style) -> [T] {
        let metrics = Metrics(items: items.map{ $0 as! IndexItem }, style: style)
        
        if (metrics.size.height <= height || height <= 0.0) {
            return items
        }
        
        var itemsToTruncate = items
        var availableHeight = height
        
        var shouldPrependFirstItem = false
        var shouldAppendLastItem = false
        
        if itemsToTruncate.count > 5 {
            if itemsToTruncate[0].blocksEdgeTruncation() {
                availableHeight -= metrics.itemSizes[0].height
                itemsToTruncate.removeAtIndex(0)
                shouldPrependFirstItem = true
            }
            if itemsToTruncate.last!.blocksEdgeTruncation() {
                availableHeight -= metrics.itemSizes.last!.height
                itemsToTruncate.removeLast()
                shouldAppendLastItem = true
            }
        }
        
        let linesAvailable = calculateAvailableLines(items: itemsToTruncate, metrics: metrics, height: availableHeight)
        if (linesAvailable <= 0) {
            return []
        }
        var result = doTruncateItems(itemsToTruncate, linesAvailable: linesAvailable)

        if shouldPrependFirstItem {
            result.insert(items[0], atIndex: 0)
        }
        if shouldAppendLastItem {
            result.append(items.last!)
        }        
        return result
    }
    
    private func calculateAvailableLines(items items: [T], metrics: Metrics, height: CGFloat) -> Int {
        let lineHeight = metrics.medianSize.height
        let truncationHeight = truncationItemFactory().sizeThatFits(metrics.style.font.my_boundingSize()).height
        
        var linesAvailable = items.count
        var currHeight = CGFloat.max
        
        while currHeight > height {
            let truncationItemsCount = CGFloat(linesAvailable / 2)
            let otherItemsCount = CGFloat(linesAvailable / 2)
            
            currHeight = CGFloat(otherItemsCount) * lineHeight + CGFloat(truncationItemsCount) * truncationHeight +
                metrics.style.itemSpacing * CGFloat(linesAvailable - 1)
            
            linesAvailable -= 1
        }
        
        if linesAvailable % 2 == 0 {
            linesAvailable -= 1
        }
        return linesAvailable
    }
    
    private func doTruncateItems(items: [T], linesAvailable: Int) -> [T] {
        var result = [T]()
        
        let step = Double(items.count) / Double(linesAvailable)
        var location = 0.0
        
        for i in 0..<linesAvailable {
            if i == linesAvailable - 1 {
                result.append(items.last!)
            } else if i % 2 == 1 {
                result.append(truncationItemFactory())
            } else {
                let charIdx = Int(round(location))
                result.append(items[charIdx])
            }
            location += step
        }
        return result
    }
}
