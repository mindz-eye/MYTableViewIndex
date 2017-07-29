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
    
    mutating func moveLeft(_ value: CGFloat) {
        size = CGSize(width: width + origin.x - value, height: height)
        left = value
    }
    
    mutating func moveTop(_ value: CGFloat) {
        size = CGSize(width: width, height: height + origin.y - value)
        top = value
    }
    
    mutating func moveRight(_ value: CGFloat) {
        size = CGSize(width: value - x, height: height)
    }
    
    mutating func moveBottom(_ value: CGFloat) {
        size = CGSize(width: width, height: value - y)
    }
}

func pixelScale() -> CGFloat {
    return 1.0 / UIScreen.main.scale
}

extension CGFloat {
    public func pixelRounded() -> CGFloat {
        let scale = UIScreen.main.scale
        return Darwin.round(self * scale) / scale
    }
    
    public func pixelCeiled() -> CGFloat {
        let scale = UIScreen.main.scale
        return ceil(self * scale) / scale
    }
}

extension CGPoint {
    public func pixelRounded() -> CGPoint {
        return CGPoint(x: x.pixelRounded(), y: y.pixelRounded())
    }
    
    public func pixelCeiled() -> CGPoint {
        return CGPoint(x: x.pixelCeiled(), y: y.pixelCeiled())
    }
}

extension CGSize {
    public func pixelRounded() -> CGSize {
        return CGSize(width: width.pixelRounded(), height: height.pixelRounded())
    }
    
    public func pixelCeiled() -> CGSize {
        return CGSize(width: width.pixelCeiled(), height: height.pixelCeiled())
    }
}

extension CGRect {
    public func pixelRounded() -> CGRect {
        return CGRect(origin: origin.pixelRounded(), size: size.pixelRounded())
    }
    
    public func pixelCeiled() -> CGRect {
        return CGRect(origin: origin.pixelCeiled(), size: size.pixelCeiled())
    }
}
