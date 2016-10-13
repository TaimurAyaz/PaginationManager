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
    /// - parameter reset:     The reset block for the pagination manager. Used to tell the pagination manager to reset its state.
    func paginationManagerDidExceedThreshold(manager: PaginationManager, reset: PaginationManagerResetBlock)
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

/// The threshold type for the pagination manager
public enum PaginationManagerThresholdType {
    
    /// Percentage based threshold. 
    /// The `value` argument defines the threshold percentage.
    case percentage(value: CGFloat)
    
    /// Constant value based threshold. This is taken as a constant threshold value from the end of the scrollView. 
    /// The `value` argument defines the threshold constant from the end of the scrollView's content.
    case constant(value: CGFloat)
}

public let PaginationManagerConstantThresholdScreenDimension: CGFloat = -1

public class PaginationManager: NSObject, UIScrollViewDelegate {
    
    // Weak reference to the pagination manager delegate
    public weak var delegate: PaginationManagerDelegate?
    
    // The threshold type for the pagination manager.
    public var thresholdType: PaginationManagerThresholdType = .constant(value: PaginationManagerConstantThresholdScreenDimension)
    
    // The default direction for the pagination manager. Overridable in the initializer.
    public private(set) var direction: PaginationManagerDirection = .vertical
    
    // The default state of the pagination manager.
    private var state: PaginationManagerState = .normal
    
    // The last offset of the scrollview. Used to make sure that threshold exceeded requests
    // are not made if the scrollview is scrolled in the opposite direction.
    private var lastOffset: CGFloat = 0
    
    // Weak reference to the original delegate of the scrollView.
    private weak var originalDelegate: UIScrollViewDelegate?
    
    // Static constant threshold initializer for objective-c interop. With scrollView.
    static func constantThresholdManager(forScrollView scrollView: UIScrollView, direction: PaginationManagerDirection, constant: CGFloat) -> PaginationManager {
        let paginationManager = PaginationManager(scrollView: scrollView, direction: direction, thresholdType: .constant(value: constant))
        return paginationManager
    }
    
    // Static constant threshold initializer for objective-c interop. Without scrollView.
    static func constantThresholdManager(withDirection direction: PaginationManagerDirection, constant: CGFloat) -> PaginationManager {
        let paginationManager = PaginationManager(direction: direction, thresholdType: .constant(value: constant))
        return paginationManager
    }
    
    // Static percentage threshold initializer for objective-c interop. With scrollView.
    static func percentageThresholdManager(forScrollView scrollView: UIScrollView, direction: PaginationManagerDirection, percentage: CGFloat) -> PaginationManager {
        let paginationManager = PaginationManager(scrollView: scrollView, direction: direction, thresholdType: .percentage(value: percentage))
        return paginationManager
    }
    
    // Static percentage threshold initializer for objective-c interop. Without scrollView.
    static func percentageThresholdManager(withDirection direction: PaginationManagerDirection, percentage: CGFloat) -> PaginationManager {
        let paginationManager = PaginationManager(direction: direction, thresholdType: .percentage(value: percentage))
        return paginationManager
    }
    
    /// Initializer for the pagination manager.
    ///
    /// - parameter scrollView: The scrollView to be associated with the apgination manager
    /// - parameter direction:  The scroll direction of the scrollView.
    /// - parameter thresholdType:  The threshold type for the pagination manager. See `PaginationManagerThresholdType`
    ///
    /// - returns: A newly created pagnination manager.
    public init(scrollView: UIScrollView, direction: PaginationManagerDirection, thresholdType: PaginationManagerThresholdType = .constant(value: PaginationManagerConstantThresholdScreenDimension)) {
        self.originalDelegate = scrollView.delegate
        self.direction = direction
        self.thresholdType = thresholdType
        super.init()
        scrollView.delegate = self
    }
    
    ///  Initializer for the pagination manager without hooking into the scrollView delegate methods. In this
    ///  case you need to call the manager's `scrollViewDidScroll:` from your scrollView delegate.
    ///
    /// - parameter direction:  The scroll direction of the scrollView.
    /// - parameter thresholdType:  The threshold type for the pagination manager. See `PaginationManagerThresholdType`
    ///
    /// - returns: A newly created pagnination manager.
    public init(direction: PaginationManagerDirection, thresholdType: PaginationManagerThresholdType = .constant(value: PaginationManagerConstantThresholdScreenDimension)) {
        self.direction = direction
        self.thresholdType = thresholdType
        super.init()
    }
}


public extension PaginationManager {
    
    // Hook into the scrollview delegate method to compute the percentage scrolled.
    func scrollViewDidScroll(scrollView: UIScrollView) {
        originalDelegate?.scrollViewDidScroll?(scrollView)
        handleScroll(forScrollView: scrollView)
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


private extension PaginationManager {
    
    func informDelegateIfPossible() {
        if state != .exceeded {
            state = .exceeded
            delegate?.paginationManagerDidExceedThreshold(self, reset: { [weak self] (shouldReset) in
                if shouldReset {
                    self?.state = .normal
                }
            })
        }
    }
    
    func handleScroll(forScrollView scrollView: UIScrollView) {

        guard judge(shouldProceedForScrollView: scrollView, lastOffset: lastOffset, state: state, direction: direction) == true else { return }
        
        let normalizedTuple = normalized(sizeAndOffsetForScrollView: scrollView, direction: direction)
        
        judge(managerDidExceedbasedOnOffset: normalizedTuple.offset, size: normalizedTuple.size, thresholdType: thresholdType)
        
        lastOffset = direction == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
    }
}


private extension PaginationManager {
    
    func judge(managerDidExceedbasedOnOffset offset: CGFloat, size: CGFloat, thresholdType: PaginationManagerThresholdType) {
        if size > 0 && offset >= 0 {
            switch thresholdType {
            case .percentage(let value):
                let percentageScrolled = offset / size
                if percentageScrolled > value {
                    informDelegateIfPossible()
                }
                break
            case .constant(let value):
                let normalizedValue = normalized(constantForConstantThresholdValue: value, direction: direction)
                let distanceFromBottom = fabs(size - offset)
                if distanceFromBottom < normalizedValue {
                    informDelegateIfPossible()
                }
                break
            }
        }
    }
    
    func judge(shouldProceedForScrollView scrollView: UIScrollView, lastOffset: CGFloat, state: PaginationManagerState, direction: PaginationManagerDirection) -> Bool {
        let directionalOffset = direction == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        guard state == .normal && scrollView.contentSize != CGSizeZero && directionalOffset >= lastOffset else { return false }
        return true
    }
}


private extension PaginationManager {
    
    func normalized(constantForConstantThresholdValue value: CGFloat, direction: PaginationManagerDirection) -> CGFloat {
        var normalizedValue: CGFloat = value >= -1 ? value : 0
        if direction == .vertical {
            normalizedValue = value == PaginationManagerConstantThresholdScreenDimension ? UIScreen.mainScreen().bounds.size.height : value
        } else {
            normalizedValue = value == PaginationManagerConstantThresholdScreenDimension ? UIScreen.mainScreen().bounds.size.width : value
        }
        return normalizedValue
    }
    
    func normalized(sizeAndOffsetForScrollView scrollView: UIScrollView, direction: PaginationManagerDirection) -> (size: CGFloat, offset: CGFloat)  {
        
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
        
        return (normalizedSize, normalizedOffset)
    }
}
