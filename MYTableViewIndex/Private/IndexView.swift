//
//  IndexView.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 02/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

class IndexView : UIView {
    
    private(set) var items: [UIView]?
    private(set) var layout: ItemLayout<UIView>?
    
    // MARK: - Init
    
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
    
    // MARK: - Updates
    
    public func reload(with items: [UIView], layout: ItemLayout<UIView>) {
        let oldItems: [UIView] = self.items ?? []
        
        self.items = items
        self.layout = layout
        
        for item in oldItems where !items.contains(item) {
            removeItem(item)
        }
        for (index, item) in items.enumerated() where !oldItems.contains(item) {
            addItem(item, withFrame: layout.frames[index])
        }
        setNeedsLayout()
    }
    
    private func removeItem(_ item: UIView) {
        // A little trickery to make item removal look nice when performed inside an animation block
        // (e.g. when the keyboard shows up)
        CATransaction.setCompletionBlock {
            item.alpha = 1
            
            if let items = self.items, !items.contains(item) {
                item.removeFromSuperview()
            }
        }
        item.alpha = 0
    }
    
    private func addItem(_ item: UIView, withFrame frame: CGRect) {
        addSubview(item)
        
        // Make the item appear with a nice fade in animation when performed inside an animation block
        // (e.g. when the keyboard shows up)
        UIView.performWithoutAnimation {
            item.frame = frame
            item.alpha = 0
        }
        item.alpha = 1
    }
    
    // MARK: - Layout 
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let items = items, let layout = layout else {
            return
        }
        for (index, item) in items.enumerated() {
            item.frame = layout.frames[index]
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        if let layout = layout {
            return layout.size
        } else {
            return CGSize()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: intrinsicContentSize.width, height: intrinsicContentSize.height)
    }
}
