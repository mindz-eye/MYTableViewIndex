//
//  TableViewIndexController.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 22/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

@objc(MYTableViewIndexController)
public class TableViewIndexController : NSObject {
    
    /// Table index managed by controller.
    public let tableViewIndex = TableViewIndex()
    
    /// Set closure to tune layout of the table index.
    public var layouter: ((_ tableView: UITableView, _ tableIndex: TableViewIndex) -> Void)?
    
    private(set) weak var tableView: UITableView?
    
    private enum ObservedKeyPaths: String {
        case contentInset
        case bounds
        case center
    }
    
    private var observer: KeyValueObserver?
    
    private var hidden = false
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        observeTableView()
        observeKeyboard();
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UITableView observation
    
    private func observeTableView() {
        guard let tableView = tableView else {
            return
        }
        let keyPaths = [ObservedKeyPaths.bounds.rawValue,
                        ObservedKeyPaths.center.rawValue,
                        ObservedKeyPaths.contentInset.rawValue]
        
        observer = KeyValueObserver(object: tableView, keyPaths: keyPaths, handler: {[weak self] keyPath in
            self?.layoutUsingTableInset()
        })
        
        tableView.my_didMoveToSuperviewHandler = { [weak self] superview in
            if let superview = superview, let tableIndex = self?.tableViewIndex {
                superview.addSubview(tableIndex)
                self?.layoutUsingTableInset()
            } else {
                self?.tableViewIndex.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Keyboard
    
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewIndexController.handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewIndexController.handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func handleKeyboardNotification(_ note: Notification) {
        guard let tableView = tableView, let parentView = tableView.superview, let userInfo = note.userInfo else {
            return;
        }
        
        if let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
           let curve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
           let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            
            let convertedFrame = parentView.convert(frame, from: nil)
            
            var inset = tableView.contentInset
            inset.bottom = (tableView.frame.maxY - convertedFrame.minY)
            
            UIView.animate(withDuration: duration, animations: {
                UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)

                self.layout(withInset: inset)
                parentView.layoutIfNeeded()
                
                }, completion: { _ in
                    self.layoutUsingTableInset()
            })
        }
    }
    
    // MARK: - Layout
    
    private func layoutUsingTableInset() {
        guard let tableView = tableView else {
            return
        }
        layout(withInset: tableView.contentInset)
    }
    
    private func layout(withInset inset: UIEdgeInsets) {
        guard let tableView = tableView else {
            return
        }
        let tableFrame = tableViewIndex.superview != nil
            ? tableView.convert(tableView.bounds, to: tableViewIndex.superview) : tableView.frame
        
        let width = tableFrame.width - (inset.left + inset.right)
        let height = tableFrame.height - (inset.top + inset.bottom)
        
        layoutInRect(CGRect(x: tableFrame.x, y: tableFrame.y + inset.top, width: width, height: height))
    }
    
    private func layoutInRect(_ rect: CGRect) {
        let tableIndexSize = tableViewIndex.sizeThatFits(rect.size)
        
        var frame = CGRect(origin: CGPoint(x: rect.right - tableIndexSize.width, y: rect.y), size: tableIndexSize)
        
        if hidden {
            frame.right = frame.right + tableViewIndex.backgroundRect().width
        }
        tableViewIndex.frame = frame
        
        if let layouter = layouter, let tableView = tableView {
            layouter(tableView, tableViewIndex)
        }
    }
    
    // MARK: - Visibility
    
    /// Hides or shows the table index. Completion closure is called instantly if animated flag is false.
    /// Use alongsideAnimations closure to run additional animations in the same context as the hide/show
    /// animation.
    public func setHidden(_ hidden: Bool, animated: Bool, completion: ((Void) -> ())?, alongsideAnimations: ((Void) -> ())?) {
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
                self.observeTableView()
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
    
    private func animateToHidden(_ hidden: Bool, completion: @escaping (Void) -> (), alongsideAnimations: ((Void) -> ())?) {
        if !hidden {
            tableViewIndex.isHidden = false
        }        
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutUsingTableInset()
            
            if let animations = alongsideAnimations {
                animations()
            }
        }, completion: { _ in
            completion()
        })
    }
    
}
