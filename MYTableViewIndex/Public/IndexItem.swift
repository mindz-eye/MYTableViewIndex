//
//  IndexItem.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 02/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

@objc public protocol IndexItem {
    
    func sizeThatFits(size: CGSize) -> CGSize
    
    func blocksEdgeTruncation() -> Bool
    
    func applyStyle(style: Style)
}

extension UIView : IndexItem {
    
    public func blocksEdgeTruncation() -> Bool {
        return false
    }
    
    public func applyStyle(style: Style) {}
}

public class StringItem : UILabel {
    
    public init(text: String) {
        super.init(frame: CGRect())
        self.text = text
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func blocksEdgeTruncation() -> Bool {
        return text == "#"
    }
    
    public override func applyStyle(style: Style) {
        font = style.font
    }
    
    public override func tintColorDidChange() {
        textColor = tintColor
    }
    
    public override func didMoveToWindow() {
        textColor = tintColor
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        if shouldDrawNumberSign() {
            return CGSize(width: 8.0, height: 14.0)
        } else {
            return super.sizeThatFits(size)
        }
    }
    
    public override func drawRect(rect: CGRect) {
        if shouldDrawNumberSign() {
            drawNumberSignInRect(rect)
        } else {
            super.drawTextInRect(rect)
        }
    }
    
    private func shouldDrawNumberSign() -> Bool {
        return text == "#" && font.my_isEqual(StyleDefaults.font)
    }
    
    private func drawNumberSignInRect(r: CGRect) {
        let insetRect = r.insetBy(UIEdgeInsets(top: 4.0, left: 1.0, bottom: 1.0, right: 1.0))
        let rect = CGRect(x: 0, y: 0, width: insetRect.width, height: insetRect.height)
        
        let scale = UIScreen.mainScreen().scale;
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, min(scale, 2.0))
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetStrokeColorWithColor(context, textColor.CGColor)
        
        let horMargin: CGFloat = roundToPixelBorder(1.5)
        let verMargin: CGFloat = roundToPixelBorder(2.5)
        
        let x1 = roundToPixelBorder(rect.x + horMargin)
        let y1 = roundToPixelBorder(rect.y)
        
        let x2 = roundToPixelBorder(rect.x + rect.width - horMargin)
        let y2 = roundToPixelBorder(rect.y + rect.height)
        
        let x3 = roundToPixelBorder(rect.x)
        let y3 = roundToPixelBorder(rect.y + verMargin)
        
        let x4 = roundToPixelBorder(rect.x + rect.width)
        let y4 = roundToPixelBorder(rect.y + rect.height - verMargin)
        
        let lineWidth: CGFloat = 1.0 / scale * 2
        
        CGContextSetShouldAntialias(context, false)
        
        CGContextSetLineWidth(context, lineWidth);
        
        CGContextMoveToPoint(context, x1, y1);
        CGContextAddLineToPoint(context, x1, y2);
        CGContextClosePath(context)
        
        CGContextMoveToPoint(context, x2, y1);
        CGContextAddLineToPoint(context, x2, y2);
        CGContextStrokePath(context);
        
        CGContextMoveToPoint(context, x3, y3);
        CGContextAddLineToPoint(context, x4, y3);
        CGContextClosePath(context)
        
        CGContextMoveToPoint(context, x3, y4);
        CGContextAddLineToPoint(context, x4, y4);
        CGContextStrokePath(context);
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            var imageRect = CGRect(origin: CGPoint(), size: image.size)
            imageRect.center = r.center
            image.drawInRect(imageRect)
        } else {
            UIGraphicsEndImageContext()
        }
    }
    
    public override var description: String {
        return text ?? ""
    }
}

public class ImageItem : UIImageView {
    
    public var contentInset = UIEdgeInsets()
    
    override public init(image: UIImage?) {
        super.init(image: image)
        contentMode = .ScaleAspectFit
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        guard let image = image else {
            return CGSize()
        }
        let imageRect = CGRect(origin: CGPoint(), size: image.size)
        let targetSize = CGSize(width: min(imageRect.width, size.width), height: min(imageRect.height, size.height))
        return CGRect(origin: CGPoint(), size: targetSize).insetBy(contentInset).size
    }
}

public class SearchItem : UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: size.width * 0.75, height: ceil(size.height * 1.15))
    }
    
    public override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let xMargin = max(rect.width - rect.height, 0) / 2
        let yMargin = max(rect.height - rect.width, 0) / 2
        
        let targetRect = rect.insetBy(dx: xMargin, dy: yMargin)
        
        let radius = targetRect.width / 3.1
        let lineWidth = targetRect.width / 6.0
        
        let circleFrame = CGRect(origin: CGPoint(x: targetRect.x + lineWidth / 2, y: targetRect.y + lineWidth / 2),
                                 size: CGSize(width: radius * 2, height: radius * 2))
        
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetStrokeColorWithColor(context, tintColor.CGColor)
        
        CGContextAddEllipseInRect(context, circleFrame)
        
        CGContextStrokePath(context)
        
        let handlePt1 = CGPoint(x: circleFrame.centerX + CGFloat(cos(315 * M_PI / 180)) * radius,
                                y: circleFrame.centerY + CGFloat(cos(315 * M_PI / 180)) * radius)
        let handlePt2 = CGPoint(x: targetRect.right - lineWidth / 3.0, y: targetRect.bottom - lineWidth / 3.0)
        
        CGContextMoveToPoint(context, handlePt1.x, handlePt1.y)
        CGContextAddLineToPoint(context, handlePt2.x, handlePt2.y)
        
        CGContextStrokePath(context)
    }
    
    public override func blocksEdgeTruncation() -> Bool {
        return true
    }
    
    public override var description: String {
        return "search"
    }
}

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
    
    public override var description: String {
        return "*"
    }
}

