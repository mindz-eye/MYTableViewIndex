//
//  GeometryHelpers.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 02/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

extension CGRect {
    var x: CGFloat {
        get { return origin.x }
        set { origin.x = newValue }
    }
    
    var y: CGFloat {
        get { return origin.y }
        set { origin.y = newValue }
    }
    
    var centerX: CGFloat {
        get { return x + width / 2 }
        set { x = newValue - width / 2 }
    }
    
    var centerY: CGFloat {
        get { return y + height / 2 }
        set { y = newValue - height / 2 }
    }
    
    var center: CGPoint {
        get { return CGPoint(x: centerX, y: centerY) }
        set { centerX = newValue.x; centerY = newValue.y }
    }
    
    var left: CGFloat {
        get { return origin.x }
        set { origin.x = newValue }
    }
    
    var top: CGFloat {
        get { return origin.y }
        set { origin.y = newValue }
    }
    
    var right: CGFloat {
        get { return x + width }
        set { x = newValue - width }
    }
    
    var bottom: CGFloat {
        get { return y + height }
        set { y = newValue - height }
    }
    
    func insetBy(_ inset: UIEdgeInsets) -> CGRect {
        var rect = self
        rect.left += inset.left
        rect.top += inset.top
        rect.size = CGSize(width: width - (inset.left + inset.right), height: height - (inset.top + inset.bottom))
        return rect
    }
}

func pixelScale() -> CGFloat {
    return 1.0 / UIScreen.main.scale
}

func roundToPixelBorder(_ value: CGFloat) -> CGFloat {
    let scale = UIScreen.main.scale
    return round(value * scale) / scale
}

func roundToPixelBorder(_ point: CGPoint) -> CGPoint {
    return CGPoint(x: roundToPixelBorder(point.x), y: roundToPixelBorder(point.y))
}
