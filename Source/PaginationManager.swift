//
//  PaginationManager.swift
//  PaginationManager
//
//  Created by Taimur Ayaz on 2016-09-27.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2016 Taimur Ayaz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation
import UIKit

// Alias for the pagination manager reset block.
public typealias PaginationManagerResetBlock = (shouldReset: Bool) -> ()

/// The pagination manager delegate.
public protocol PaginationManagerDelegate: class {
    
    
    /// Tells the conforming object that the pagination manager has exceeded the given threshold.
    ///
    /// - parameter manager:   The pagination manager.
    /// - parameter threshold: The threshold that was exceeded.
    /// - parameter reset:     The reset block for the pagination manager. Used to tell the pagination manager to reset its state.
    func paginationManagerDidExceedThreshold(manager: PaginationManager, threshold: CGFloat, reset: PaginationManagerResetBlock)
}

/// Private enum defining the possible states of the pagination manager.
private enum PaginationManagerState {
    case normal
    case exceeded
}

/// The scroll direction for the pagination manager
public enum PaginationManagerDirection {
    case horizontal
    case vertical
}

public class PaginationManager: NSObject, UIScrollViewDelegate {
    
    // Weak reference to the pagination manager delegate
    public weak var delegate: PaginationManagerDelegate?
    
    // The percentage scrolled by the user. The main logic for the pagination manager resides in the `didSet` block.
    public private(set) var percentageScrolled: CGFloat = 0 {
        didSet {
            if percentageScrolled > thresholdPercentage && state != .exceeded {
                state = .exceeded
                delegate?.paginationManagerDidExceedThreshold(self, threshold: thresholdPercentage, reset: { [weak self] (shouldReset) in
                    if shouldReset {
                        self?.state = .normal
                    }
                    })
            }
        }
    }
    // The default threshold percentage for the pagination manager.
    public var thresholdPercentage: CGFloat = 0.6
    
    // The default direction for the pagination manager. Overridable in the initializer.
    public private(set) var direction: PaginationManagerDirection = .vertical
    
    // The default state of the pagination manager.
    private var state: PaginationManagerState = .normal
    
    // The last offset of the scrollview. Used to make sure that threshold exceeded requests
    // are not made if the scrollview is scrolled in the opposite direction.
    private var lastOffset: CGFloat = 0
    
    // Weak reference to the scrollView.
    private weak var scrollView: UIScrollView?
    
    // Weak reference to the original delegate of the scrollView.
    private weak var originalDelegate: UIScrollViewDelegate?
    
    
    /// Designated initializer for the pagination manager.
    ///
    /// - parameter scrollView: The scrollView to be associated with the apgination manager
    /// - parameter direction:  The scroll direction of the scrollView.
    ///
    /// - returns: A newly created pagnination manager.
    public init(scrollView: UIScrollView, direction: PaginationManagerDirection) {
        self.scrollView = scrollView
        self.originalDelegate = scrollView.delegate
        self.direction = direction
        super.init()
        scrollView.delegate = self
    }
}

public extension PaginationManager {
    
    // Hook into the scrollview delegate method to compute the percentage scrolled.
    func scrollViewDidScroll(scrollView: UIScrollView) {
        originalDelegate?.scrollViewDidScroll?(scrollView)
        
        let directionalOffset = direction == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        guard state == .normal &&
            scrollView.contentSize != CGSizeZero &&
            directionalOffset >= lastOffset
            else { return }
        
        let scrollViewContentInsets = scrollView.contentInset
        
        var scrollViewKeyOffset = scrollView.contentOffset.y
        var scrollViewKeyDimension = scrollView.frame.size.height
        var scrollViewContentKeyDimension = scrollView.contentSize.height
        var normalizedOffset = scrollViewKeyOffset + scrollViewContentInsets.top
        var normalizedSize = scrollViewContentKeyDimension - (scrollViewKeyDimension - scrollViewContentInsets.top - scrollViewContentInsets.bottom)
        
        if direction == .horizontal {
            scrollViewKeyOffset = scrollView.contentOffset.x
            scrollViewKeyDimension = scrollView.frame.size.width
            scrollViewContentKeyDimension = scrollView.contentSize.width
            normalizedOffset = scrollViewKeyOffset + scrollViewContentInsets.left
            normalizedSize = scrollViewContentKeyDimension - (scrollViewKeyDimension - scrollViewContentInsets.left - scrollViewContentInsets.right)
        }
        
        if normalizedSize > 0 && normalizedOffset >= 0 {
            let percentageScrolled = normalizedOffset / normalizedSize
            self.percentageScrolled = percentageScrolled
        }
        
        lastOffset = direction == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
    }
    
    // Pass unsed delegate methods back to the original delegate.
    
    override func respondsToSelector(aSelector: Selector) -> Bool {
        if let delegateResponds = self.originalDelegate?.respondsToSelector(aSelector) where delegateResponds == true {
            return true
        }
        return super.respondsToSelector(aSelector)
    }
    
    override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        return self.originalDelegate
    }
}
