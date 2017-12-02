//
//  SearchItem.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 06/08/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

/// Use this class to get a magnifying glass icon similar to UITableViewIndexSearch.
@objc (MYSearchItem)
@objcMembers
open class SearchItem : UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        accessibilityLabel = NSLocalizedString("Search", comment: "Accessibility title for search icon")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width * 0.75, height: ceil(size.height * 1.15))
    }
    
    open override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let xMargin = max(rect.width - rect.height, 0) / 2
        let yMargin = max(rect.height - rect.width, 0) / 2
        
        let targetRect = rect.insetBy(dx: xMargin, dy: yMargin)
        
        // The constants below are carefully tuned to match the Apple's UITableViewIndexSearch icon
        let radius = targetRect.width / 3.1
        let lineWidth = targetRect.width / 6.0
        
        let circleFrame = CGRect(origin: CGPoint(x: targetRect.x + lineWidth / 2, y: targetRect.y + lineWidth / 2),
                                 size: CGSize(width: radius * 2, height: radius * 2))
        
        context?.setLineWidth(lineWidth)
        context?.setStrokeColor(tintColor.cgColor)
        
        context?.addEllipse(in: circleFrame)
        
        context?.strokePath()
        
        let handlePt1 = CGPoint(x: circleFrame.centerX + cos(315 * CGFloat.pi / 180) * radius,
                                y: circleFrame.centerY + cos(315 * CGFloat.pi / 180) * radius)
        let handlePt2 = CGPoint(x: targetRect.right - lineWidth / 3.0, y: targetRect.bottom - lineWidth / 3.0)
        
        context?.move(to: handlePt1)
        context?.addLine(to: handlePt2)
        
        context?.strokePath()
    }
    
    open override func blocksEdgeTruncation() -> Bool {
        return true
    }
}
