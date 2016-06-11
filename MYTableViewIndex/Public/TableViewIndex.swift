//
//  TableViewIndex.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 28/04/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

public class TableViewIndex : UIControl {
    
    @IBOutlet public weak var dataSource: TableViewIndexDataSource? {
        didSet {
            reloadData()
        }
    }
    
    @IBOutlet public weak var delegate: TableViewIndexDelegate?
    
    public var backgroundView: UIView? {
        didSet {
            if let view = backgroundView {
                insertSubview(view, atIndex: 0)
            } else {
                addDefaultBackgroundView()
            }
        }
    }
    
    public var font: UIFont? {
        didSet {
            updateStyle()
        }
    }
    
    public var itemSpacing: CGFloat? {
        didSet {
            updateStyle()
        }
    }
    
    public var indexInset = UIEdgeInsets(top: CGFloat.max, left: pixelScale(), bottom: CGFloat.max, right: pixelScale()) {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var indexOffset = UIOffset(horizontal: 0.0, vertical: 1.0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var style: Style! {
        didSet {
            indexView.style = style
            updateVisibleItems()
            setNeedsLayout()
        }
    }
    
    private lazy var indexView: IndexView = { [unowned self] in
        let view = IndexView()
        self.addSubview(view)
        return view
    }()
    
    public private(set) var items: [UIView] = []
    
    public var displayedItems: [UIView] {
        return indexView.items
    }
    
    private var truncation: Truncation<UIView>?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clearColor()
        
        addDefaultBackgroundView()
        updateStyle()
        
        exclusiveTouch = true
        multipleTouchEnabled = false
    }
    
    private func addDefaultBackgroundView() {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        view.userInteractionEnabled = false
        insertSubview(view, atIndex: 0)
        backgroundView = view
    }
    
    // MARK: - Updates
    
    public func reloadData() {
        items = queryItems()
        truncation = queryTruncation()
        
        applyStyle()
        updateVisibleItems()
        setNeedsLayout()
    }
    
    private func queryItems() -> [UIView] {
        return dataSource != nil ? dataSource!.indexItems(forTableViewIndex: self) : []
    }
    
    private func queryTruncation() -> Truncation<UIView>? {
        guard let dataSource = dataSource else {
            return nil
        }
        var truncationItemClass = TruncationItem.self
        if dataSource.respondsToSelector(#selector(TableViewIndexDataSource.truncationItemClass(forTableViewIndex:))) {
            truncationItemClass = dataSource.truncationItemClass!(forTableViewIndex: self) as! TruncationItem.Type
        }
        return Truncation(items: items, truncationItemFactory: {
            return truncationItemClass.init()
        })
    }
    
    private func updateStyle() {
        style = ConcreteStyle(font: font, itemSpacing: itemSpacing)
        applyStyle()
    }
    
    private func applyStyle() {
        for item in items {
            item.applyStyle(style)
        }
    }
    
    private func updateVisibleItems() {
        let availableSize = CGSize(width: bounds.width, height: bounds.height)
        
        if let truncation = truncation {
            indexView.items = truncation.truncate(forHeight: availableSize.height, style: style)
        } else {
            indexView.items = items
        }
    }
    
    // MARK: - Layout
    
    public func indexRect() -> CGRect {
        var frame = CGRect(origin: CGPoint(), size: indexView.sizeThatFits(bounds.size)).integral
        frame.right = bounds.right - indexInset.right + indexOffset.horizontal
        frame.centerY = bounds.centerY + indexOffset.vertical
        return frame
    }
    
    public func backgroundRect() -> CGRect {
        let indexFrame = indexRect()
        
        let width = indexFrame.width + indexInset.left + indexInset.right
        let height = min(indexFrame.height + indexInset.top + indexInset.bottom, bounds.height)
        
        var rect = CGRect(origin: CGPoint(x: bounds.width - width, y: 0),
                          size: CGSize(width: width, height: height))
        rect.centerY = indexFrame.centerY
        
        if indexInset.top == CGFloat.max {
            rect.top = 0.0
        }
        if indexInset.bottom == CGFloat.max {
            rect.bottom = bounds.bottom
        }
        return rect.integral
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        updateVisibleItems()
        
        indexView.frame = indexRect()
        backgroundView?.frame = backgroundRect()
    }
    
    public override func intrinsicContentSize() -> CGSize {
        let width = indexRect().width + indexInset.left + indexInset.right
        let minWidth: CGFloat = 44.0
        return CGSize(width: max(width, minWidth), height: UIViewNoIntrinsicMetric)
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: intrinsicContentSize().width, height: size.height)
    }
    
    // MARK: - Touches
    
    private var currentTouch: UITouch?
    private var currentIndex: Int?
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first where bounds.contains(touch.locationInView(self)) {
            currentTouch = touch
            highlighted = true
            processTouch(touch)
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = currentTouch where touches.contains(touch) {
            processTouch(touch)
        }
        super.touchesMoved(touches, withEvent: event)
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = currentTouch where touches.contains(touch) {
            finalizeTouch()
        }
        super.touchesEnded(touches, withEvent: event)
    }
    
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if let touch = currentTouch, touches = touches where touches.contains(touch) {
            finalizeTouch()
        }
        super.touchesCancelled(touches, withEvent: event)
    }
    
    private func processTouch(touch: UITouch) {
        let location = touch.locationInView(indexView)
        let progress = max(0, min(location.y / indexView.bounds.height, 0.9999))
        let idx = Int(floor(progress * CGFloat(items.count)))
        
        if idx == currentIndex {
            return
        }
        currentIndex = idx
        
        if let delegate = self.delegate
            where delegate.respondsToSelector(#selector(TableViewIndexDelegate.tableViewIndex(_:didSelectItem:atIndex:))) {
            
            delegate.tableViewIndex!(self, didSelectItem: items[idx], atIndex: idx)
        }
    }
    
    private func finalizeTouch() {
        currentTouch = nil
        currentIndex = nil
        highlighted = false
    }
}

// MARK: - Protocols

@objc public protocol TableViewIndexDataSource : NSObjectProtocol {
    
    func indexItems(forTableViewIndex tableViewIndex: TableViewIndex) -> [UIView]
    
    optional func truncationItemClass(forTableViewIndex tableViewIndex: TableViewIndex) -> AnyClass
}


@objc public protocol TableViewIndexDelegate : NSObjectProtocol {
    
    optional func tableViewIndex(tableViewIndex: TableViewIndex, didSelectItem item: UIView, atIndex index: Int)
}

// MARK: - IB support

@IBDesignable
extension TableViewIndex {
    
    class TableDataSource : NSObject, TableViewIndexDataSource {
        
        func indexItems(forTableViewIndex tableViewIndex: TableViewIndex) -> [UIView] {
            return UILocalizedIndexedCollation.currentCollation().sectionIndexTitles.map{ title -> UIView in
                return StringItem(text: title)
            }
        }        
    }
    
    public override func prepareForInterfaceBuilder() {
        dataSource = TableDataSource()
    }
}