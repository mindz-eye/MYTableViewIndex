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
        didSet {
            updateWithItems(items, oldItems: oldValue)
        }
    }
    
    var style: Style? {
        didSet {
            updateLayout()
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        if let layout = layout {
            return layout.metrics.size
        } else {
            return CGSize()
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
        isUserInteractionEnabled = false
        backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard var layout = layout else {
            return
        }
        layout.layout(in: bounds)
        
        for (index, item) in items.enumerated() {
            item.frame = layout.itemFrames[index]
        }
    }
    
    private func updateLayout() {
        if style != nil && items.count > 0 {
            layout = Layout(items: items, style: style!)
            setNeedsLayout()
        }
    }
    
    private func updateWithItems(_ items: [UIView], oldItems: [UIView]) {
        for item in oldItems where !items.contains(item) {
            removeItem(item)
        }
        
        updateLayout()
        
        guard var layout = layout else {
            return
        }
        layout.layout(in: bounds)
        
        for (index, item) in items.enumerated() where !oldItems.contains(item) {
            addItem(item, withFrame: layout.itemFrames[index])
        }
    }
    
    private func removeItem(_ item: UIView) {
        // A little trickery to make item removal look nice when performed inside animation block
        CATransaction.setCompletionBlock {
            item.alpha = 1
            
            if (!self.items.contains(item)) {
                item.removeFromSuperview()
            }
        }
        item.alpha = 0
    }
    
    private func addItem(_ item: UIView, withFrame frame: CGRect) {
        addSubview(item)
        
        // Make item appear with nice fade in animation when layout is called inside animation block
        UIView.performWithoutAnimation {
            item.frame = frame
            item.alpha = 0
        }
        item.alpha = 1
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: intrinsicContentSize.width, height: intrinsicContentSize.height)
    }
}
