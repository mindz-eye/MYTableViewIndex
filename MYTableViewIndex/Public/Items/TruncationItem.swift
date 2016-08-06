//
//  TruncationItem.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 06/08/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit


public class TruncationItem : UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        let circleBounds = circleBoundsForSize(size)
        return CGSize(width: circleBounds.width, height: circleBounds.height * 1.8)
    }
    
    private func circleBoundsForSize(size: CGSize) -> CGRect {
        let radius = round(size.height * 0.25)
        return CGRect(origin: CGPointZero, size: CGSize(width: radius * 2, height: radius * 2))
    }
    
    public override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        var circleFrame = circleBoundsForSize(rect.size)
        circleFrame.center = rect.center
        
        CGContextAddEllipseInRect(context, circleFrame)
        CGContextSetFillColorWithColor(context, tintColor.CGColor)
        CGContextFillPath(context)
    }
}
