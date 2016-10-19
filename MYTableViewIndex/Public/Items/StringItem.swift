//
//  StringItem.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 06/08/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

/// Use this class for displaying text based items.
@objc (MYStringItem)
open class StringItem : UILabel {
    
    public init(text: String) {
        super.init(frame: CGRect())
        self.text = text
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func blocksEdgeTruncation() -> Bool {
        // UITableView never truncates items before # sign.
        return text == "#"
    }
    
    open override func applyStyle(_ style: Style) {
        font = style.font
    }
    
    open override func tintColorDidChange() {
        textColor = tintColor
    }
    
    open override func didMoveToWindow() {
        textColor = tintColor
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        if shouldDrawNumberSign() {
            // Hardcoded values are safe to use here since we draw # sign for one font size only
            return CGSize(width: 8.0, height: 14.0)
        } else {
            return super.sizeThatFits(size)
        }
    }
    
    open override func draw(_ rect: CGRect) {
        if shouldDrawNumberSign() {
            drawNumberSignInRect(rect)
        } else {
            super.drawText(in: rect)
        }
    }
    
    /// Handle # sign in a special way to match native index appearance. It's not clear why
    /// Apple uses a bitmap instead of a font glyph for this character - most likely due to
    /// the blurry look of the symbol on non-retina devices. Obviously, this custom shape
    /// drawing only makes for default font. Otherwise we would have to support various font
    /// faces, styles, etc.
    private func shouldDrawNumberSign() -> Bool {
        return text == "#" && font.my_isEqual(StyleDefaults.font)
    }
    
    private func drawNumberSignInRect(_ r: CGRect) {
        let insetRect = r.insetBy(UIEdgeInsets(top: 4.0, left: 1.0, bottom: 1.0, right: 1.0))
        let rect = CGRect(x: 0, y: 0, width: insetRect.width, height: insetRect.height)
        
        let scale = UIScreen.main.scale;
        
        // Why do I use image context instead of direct drawing into the layer? Fair question - I just
        // didn't get how to draw the exact copy of Apple's `#` bitmap on 3x devices. This little hack -
        // drawing at 2x and than upscaling the image - gives an acceptable result.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, min(scale, 2.0))
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setStrokeColor(textColor.cgColor)
        
        // The constants below are carefully tuned to match the Apple's "pound sign" icon
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
        
        context?.setShouldAntialias(false)
        
        context?.setLineWidth(lineWidth);
        
        context?.move(to: CGPoint(x: x1, y: y1))
        context?.addLine(to: CGPoint(x: x1, y: y2))
        context?.closePath()
        
        context?.move(to: CGPoint(x: x2, y: y1))
        context?.addLine(to: CGPoint(x: x2, y: y2))
        context?.strokePath();
        
        context?.move(to: CGPoint(x: x3, y: y3))
        context?.addLine(to: CGPoint(x: x4, y: y3))
        context?.closePath()
        
        context?.move(to: CGPoint(x: x3, y: y4))
        context?.addLine(to: CGPoint(x: x4, y: y4))
        context?.strokePath();
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            var imageRect = CGRect(origin: CGPoint(), size: image.size)
            imageRect.center = r.center
            image.draw(in: imageRect)
        } else {
            UIGraphicsEndImageContext()
        }
    }
}
