//
//  TruncationItem.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 06/08/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

/// The item matches Apple's `•` symbols used as truncation indicators. Used it by default in table index.
@objc (MYTruncationItem)
open class TruncationItem : UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let circleBounds = circleBoundsForSize(size)
        return CGSize(width: circleBounds.width, height: circleBounds.height * 1.8)
    }
    
    private func circleBoundsForSize(_ size: CGSize) -> CGRect {
        let radius = round(size.height * 0.25)
        return CGRect(origin: CGPoint.zero, size: CGSize(width: radius * 2, height: radius * 2))
    }
    
    open override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        var circleFrame = circleBoundsForSize(rect.size)
        circleFrame.center = rect.center
        
        context?.addEllipse(in: circleFrame)
        context?.setFillColor(tintColor.cgColor)
        context?.fillPath()
    }
}
