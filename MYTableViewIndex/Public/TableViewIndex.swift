//
//  TableViewIndex.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 28/04/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

@objc(MYTableViewIndex)
open class TableViewIndex : UIControl {
    
    // MARK: - Properties
    
    /// Data source for the table index object. See TableViewIndexDataSource protocol for details.
    @IBOutlet public weak var dataSource: TableViewIndexDataSource? {
        didSet {
            reloadData()
        }
    }
    
    /// Delegate for the table index object. See TableViewIndexDelegate protocol for details.
    @IBOutlet public weak var delegate: TableViewIndexDelegate?
    
    /// Background view is displayed below the index items and can customized with any UIView.
    /// If not set or set to nil, creates a default view which mimics the system index appearance.
    public var backgroundView: UIView! {
        didSet {
            if let view = backgroundView {
                insertSubview(view, at: 0)
            } else {
                backgroundView = BackgroundView()
            }
        }
    }
    
    /// Font for the index view items. If not set or set to nil, uses a default font which is chosen to
    /// match system appearance.
    public var font: UIFont! {
        get {
            return style.font
        }
        set {
            style = ConcreteStyle(font: newValue, itemSpacing: style.itemSpacing, indexInset: style.indexInset, indexOffset: style.indexOffset)
        }
    }
    
    /// Vertical spacing between the items. Equals to 1 point by default to match system appearance.
    public var itemSpacing: CGFloat! {
        get {
            return style.itemSpacing
        }
        set {
            style = ConcreteStyle(font: style.font, itemSpacing: newValue, indexInset: style.indexInset, indexOffset: style.indexOffset)
        }
    }
    
    /// The distance that index items are inset from the enclosing background view. The property
    /// doesn't change the position of index items. Instead, it changes the size of the background view
    /// to match the inset. In other words, the background view "wraps" the content. Affects intrinsic
    /// content size.
    /// Set inset value to CGFloat.max to make the background view fill all the available space.
    /// Default value matches the system index appearance.
    public var indexInset: UIEdgeInsets! {
        get {
            return style.indexInset
        }
        set {
            style = ConcreteStyle(font: style.font, itemSpacing: style.itemSpacing, indexInset: newValue, indexOffset: style.indexOffset)
        }
    }

    /// The distance that index items are shifted inside the enclosing background view. The property
    /// changes position of the items and doesn't affect the size of the background view.
    /// Default value matches the system index appearance.
    public var indexOffset: UIOffset! {
        get {
            return style.indexOffset
        }
        set {
            style = ConcreteStyle(font: style.font, itemSpacing: style.itemSpacing, indexInset: style.indexInset, indexOffset: newValue)
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        let layout = ItemLayout(items: items, style: style)
        let width = layout.size.width + style.indexInset.left + style.indexInset.right
        let minWidth: CGFloat = 44.0
        return CGSize(width: max(width, minWidth), height: UIViewNoIntrinsicMetric)
    }

    /// The list of all items provided by the data source.
    public private(set) var items: [UIView] = []
    
    /// Returns a set of items suitable for displaying within the current bounds. If there is not enough space
    /// to display all the items provided by the data source, some of them are replaced with a special truncation item.
    /// To customize the class of truncation item, use the corresponding TableViewIndexDataSource method.
    public var displayedItems: [UIView] {
        if let items = indexView.items {
            return items
        } else {
            return []
        }
    }
    
    private var truncation: Truncation<UIView>?
    
    private var style = ConcreteStyle() {
        didSet {
            applyStyleToItems()
            setNeedsLayout()
        }
    }
    
    private lazy var indexView: IndexView = { [unowned self] in
        let view = IndexView()
        self.addSubview(view)
        return view
    }()
    
    // MARK: - Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clear
        
        backgroundView = BackgroundView()
        
        isExclusiveTouch = true
        isMultipleTouchEnabled = false
    }
    
    // MARK: - Updates
    
    /// Forces table index to reload its items. This causes table index to discard its current items
    /// and refill itself from the data source.
    public func reloadData() {
        items = queryItems()
        truncation = queryTruncation()
        applyStyleToItems()
        setNeedsLayout()
    }
    
    private func queryItems() -> [UIView] {
        return dataSource != nil ? dataSource!.indexItems(for: self) : []
    }
    
    private func queryTruncation() -> Truncation<UIView>? {
        guard let dataSource = dataSource else {
            return nil
        }
        var truncationItemClass = TruncationItem.self
        
        // Check if the data source provides a custom class for truncation item
        if dataSource.responds(to: #selector(TableViewIndexDataSource.truncationItemClass(for:))) {
            truncationItemClass = dataSource.truncationItemClass!(for: self) as! TruncationItem.Type
        }
        // Now we now the item class and can create truncation items on demand
        return Truncation(items: items, truncationItemFactory: {
            return truncationItemClass.init()
        })
    }
    
    private func applyStyleToItems() {
        for item in items {
            item.applyStyle(style)
        }
    }
        
    // MARK: - Layout
    
    /// Returns a drawing area for the index items.
    public func indexRect() -> CGRect {
        return indexView.frame
    }
    
    /// Returns a drawing area for the background view.
    public func backgroundRect() -> CGRect {
        return backgroundView.frame
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        var visibleItems = items
        
        if let truncation = truncation {
            visibleItems = truncation.truncate(forHeight: bounds.height, style: style)
        }
        let layout = Layout(items: visibleItems, style: style, bounds: bounds)
        
        indexView.frame = layout.contentFrame
        backgroundView.frame = layout.backgroundFrame
        
        indexView.reload(with: visibleItems, layout: layout.itemLayout)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: intrinsicContentSize.width, height: size.height)
    }
    
    // MARK: - Touches
    
    private var currentTouch: UITouch?
    private var currentIndex: Int?
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first , bounds.contains(touch.location(in: self)) {
            beginTouch(touch)
            processTouch(touch)
        }
        super.touchesBegan(touches, with: event)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = currentTouch , touches.contains(touch) {
            processTouch(touch)
        }
        super.touchesMoved(touches, with: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = currentTouch , touches.contains(touch) {
            finalizeTouch()
        }
        super.touchesEnded(touches, with: event)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = currentTouch, touches.contains(touch) {
            finalizeTouch()
        }
        super.touchesCancelled(touches, with: event)
    }
    
    private func beginTouch(_ touch: UITouch) {
        currentTouch = touch
        isHighlighted = true
        prepareFeedbackGenerator()
    }
    
    private func processTouch(_ touch: UITouch) {
        if items.isEmpty {
            return
        }
        let location = touch.location(in: indexView)
        let progress = max(0, min(location.y / indexView.bounds.height, 0.9999))
        let idx = Int(floor(progress * CGFloat(items.count)))
        
        if idx == currentIndex {
            return
        }
        currentIndex = idx

        notifyFeedbackGenerator()
        
        if let delegate = self.delegate
            , delegate.responds(to: #selector(TableViewIndexDelegate.tableViewIndex(_:didSelect:at:))) {
            
            delegate.tableViewIndex!(self, didSelect: items[idx], at: idx)
        }
    }
    
    private func finalizeTouch() {
        currentTouch = nil
        currentIndex = nil
        isHighlighted = false
        cleanupFeedbackGenerator()
    }
    
    // MARK: - Taptic Engine support
    
    @available(iOS 10.0, *)
    private var feedbackGenerator: UISelectionFeedbackGenerator {
        if feedbackGeneratorInstance == nil {
            feedbackGeneratorInstance = UISelectionFeedbackGenerator()
        }
        return feedbackGeneratorInstance as! UISelectionFeedbackGenerator
    }
    private var feedbackGeneratorInstance: Any? = nil
    
    private func prepareFeedbackGenerator() {
        if #available(iOS 10.0, *) {
            feedbackGenerator.prepare()
        }
    }
    
    private func notifyFeedbackGenerator() {
        if #available(iOS 10.0, *) {
            feedbackGenerator.selectionChanged()
            feedbackGenerator.prepare()
        }
    }
    
    private func cleanupFeedbackGenerator() {
        if #available(iOS 10.0, *) {
            feedbackGeneratorInstance = nil
        }
    }
}

// MARK: - Protocols

@objc(MYTableViewIndexDataSource)
public protocol TableViewIndexDataSource : NSObjectProtocol {
    
    /// Provides a set of items to display in the table index. The library provides
    /// a default set of views tuned for displaying text, images, search indicator and
    /// truncation items.
    /// You can use any UIView subclass as an item basically, though using UITableView
    /// is not recommended :)
    /// Check IndexItem protocol for item customization points.
    func indexItems(for tableViewIndex: TableViewIndex) -> [UIView]
    
    /// Provides a class for truncation items. Truncation items are useful when there's not enough
    /// space for displaying all the items provided by the data source. When this happens, table
    /// index omits some of the items from being displayed and inserts one or more truncation items
    /// instead.
    /// Table index uses TruncationItem class by default, which is tuned to match the native index
    /// appearance.
    @objc optional func truncationItemClass(for tableViewIndex: TableViewIndex) -> AnyClass
}


@objc(MYTableViewIndexDelegate)
public protocol TableViewIndexDelegate : NSObjectProtocol {
    
    /// Called as a result of recognizing an index touch. Can be used to scroll table/collection view to
    /// a corresponding section.
    @objc optional func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int)
}

// MARK: - IB support

@IBDesignable
extension TableViewIndex {
    
    class TableDataSource : NSObject, TableViewIndexDataSource {
        
        func indexItems(for tableViewIndex: TableViewIndex) -> [UIView] {
            return UILocalizedIndexedCollation.current().sectionIndexTitles.map{ title -> UIView in
                return StringItem(text: title)
            }
        }        
    }
    
    open override func prepareForInterfaceBuilder() {
        dataSource = TableDataSource()
    }
}
