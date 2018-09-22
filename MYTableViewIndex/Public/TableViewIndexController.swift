//
//  TableViewIndexController.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 22/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

@objc(MYTableViewIndexController)
@objcMembers
public class TableViewIndexController : NSObject {
    
    /// Table index managed by controller.
    public let tableViewIndex = TableViewIndex()
    
    /// Set closure to tune layout of the table index.
    public var layouter: ((_ scrollView: UIScrollView, _ tableIndex: TableViewIndex) -> Void)?
    
    private(set) weak var scrollView: UIScrollView?
    
    private enum ObservedKeyPaths: String {
        case contentInset
        case adjustedContentInset
        case bounds
        case center
    }
    
    private var observer: KeyValueObserver?
    
    private var hidden = false
    
    public init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init()
        
        observeScrollView()
        observeKeyboard();
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UITableView observation
    
    private func observeScrollView() {
        guard let scrollView = scrollView else {
            return
        }
        var insetKeypath: String
        if #available(iOS 11.0, *) {
            insetKeypath = ObservedKeyPaths.adjustedContentInset.rawValue
        } else {
            insetKeypath = ObservedKeyPaths.contentInset.rawValue
        }
        
        let keyPaths = [ObservedKeyPaths.bounds.rawValue,
                        ObservedKeyPaths.center.rawValue,
                        insetKeypath]
        
        observer = KeyValueObserver(object: scrollView, keyPaths: keyPaths, handler: {[weak self] keyPath in
            self?.layout()
        })
        
        scrollView.my_didMoveToSuperviewHandler = { [weak self] superview in
            if let superview = superview, let tableIndex = self?.tableViewIndex {
                superview.addSubview(tableIndex)
                self?.layout()
            } else {
                self?.tableViewIndex.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Keyboard
    
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewIndexController.handleKeyboardNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewIndexController.handleKeyboardNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func handleKeyboardNotification(_ note: Notification) {
        guard let scrollView = scrollView, let parentView = scrollView.superview, let userInfo = note.userInfo else {
            return;
        }
        
        if let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            
            let convertedFrame = parentView.convert(frame, from: nil)
            
            var safeAreaInsets = UIEdgeInsets()
            if #available(iOS 11.0, *) {
                safeAreaInsets = parentView.safeAreaInsets
            }
            
            var inset = scrollView.my_effectiveContentInset
            inset.bottom = max(scrollView.frame.maxY - convertedFrame.minY, safeAreaInsets.bottom)
            
            UIView.animate(withDuration: duration, animations: {
                UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: curve)!)

                self.layout(with: inset)
                parentView.layoutIfNeeded()
                
                }, completion: { _ in
                    self.layout()
            })
        }
    }
    
    // MARK: - Layout
    
    private func layout() {
        guard let scrollView = scrollView else {
            return
        }
        layout(with: scrollView.my_effectiveContentInset)
    }
    
    private func layout(with inset: UIEdgeInsets) {
        guard let scrollView = scrollView else {
            return
        }
        let tableFrame = tableViewIndex.superview != nil
            ? scrollView.convert(scrollView.bounds, to: tableViewIndex.superview) : scrollView.frame
        
        let width = tableFrame.width - (inset.left + inset.right)
        let height = tableFrame.height - (inset.top + inset.bottom)
        
        layout(in: CGRect(x: tableFrame.x + inset.left, y: tableFrame.y + inset.top, width: width, height: height))
    }
    
    private func layout(in rect: CGRect) {
        let tableIndexSize = tableViewIndex.sizeThatFits(rect.size)
        
        let isRightToLeft = UIView.my_userInterfaceLayoutDirection(for: tableViewIndex) == .rightToLeft
        
        let trailing = isRightToLeft ? rect.left : rect.right - tableIndexSize.width
        
        var frame = CGRect(origin: CGPoint(x: trailing, y: rect.y), size: tableIndexSize)
        
        if hidden {
            frame.right = isRightToLeft
                ? frame.left - tableViewIndex.backgroundRect().width
                : frame.right + tableViewIndex.backgroundRect().width
        }
        tableViewIndex.frame = frame
        
        if let layouter = layouter, let scrollView = scrollView {
            layouter(scrollView, tableViewIndex)
        }
    }
    
    // MARK: - Visibility
    
    /// Hides or shows the table index. Completion closure is called instantly if animated flag is false.
    /// Use alongsideAnimations closure to run additional animations in the same context as the hide/show
    /// animation.
    public func setHidden(_ hidden: Bool, animated: Bool, completion: (() -> ())?, alongsideAnimations: (() -> ())?) {
        if self.hidden == hidden {
            return
        }
        self.hidden = hidden
        
        if hidden {
            observer = nil
        }
        let completionHandler = {
            self.tableViewIndex.isHidden = hidden
            
            if !hidden {
                self.observeScrollView()
            }
            if let completion = completion {
                completion()
            }
        }
        if animated {
            animateToHidden(hidden, completion: completionHandler, alongsideAnimations: alongsideAnimations)
        } else {
            completionHandler()
        }
    }
    
    public func setHidden(_ hidden: Bool, animated: Bool) {
        setHidden(hidden, animated: animated, completion: nil, alongsideAnimations: nil)
    }
    
    private func animateToHidden(_ hidden: Bool, completion: @escaping () -> (), alongsideAnimations: (() -> ())?) {
        if !hidden {
            tableViewIndex.isHidden = false
        }        
        UIView.animate(withDuration: 0.25, animations: {
            self.layout()
            
            if let animations = alongsideAnimations {
                animations()
            }
        }, completion: { _ in
            completion()
        })
    }
    
}
