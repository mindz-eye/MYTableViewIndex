//
//  IndexView.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 02/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

class IndexView : UIView {
        
    var items = [UIView]() {
        willSet {
            for item in items {
                if newValue.contains(item) {
                    continue
                }
                CATransaction.setCompletionBlock({
                    item.alpha = 1
                    
                    if (!self.items.contains(item)) {
                        item.removeFromSuperview()
                    }
                })
                item.alpha = 0
            }
        }
        
        didSet {
            updateLayout()
            
            guard var layout = layout else {
                return
            }
            layout.layoutInRect(bounds)
            
            for (index, item) in items.enumerate() {
                if oldValue.contains(item) {
                    continue
                }
                addSubview(item)
                
                UIView.performWithoutAnimation({
                    if (layout.itemFrames.count > index) {
                        item.frame = layout.itemFrames[index]
                        item.alpha = 0
                    }
                })
                item.alpha = 1
            }
        }
    }
    
    var style: Style? {
        didSet {
            updateLayout()
        }
    }
    
    private var layout: Layout?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        userInteractionEnabled = false
        backgroundColor = UIColor.clearColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard var layout = layout else {
            return
        }
        layout.layoutInRect(bounds)
        
        for (index, item) in items.enumerate() {
            item.frame = layout.itemFrames[index]
        }
    }
    
    private func updateLayout() {
        if style != nil && items.count > 0 {
            layout = Layout(items: items, style: style!)
            setNeedsLayout()
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        if let layout = layout {
            return layout.metrics.size
        } else {
            return CGSize()
        }
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: intrinsicContentSize().width, height: intrinsicContentSize().height)
    }
}
