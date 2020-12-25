//
//  SwipeCell.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/12/10.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///滑动方向
public struct SwipeDirection: OptionSet {
    
    public let rawValue: UInt
    
    public init(rawValue: UInt){
        self.rawValue = rawValue
    }
    
    ///没
    public static let none = SwipeDirection([])
    
    ///向左
    public static let left = SwipeDirection(rawValue: 1)
    
    ///向右
    public static let right = SwipeDirection(rawValue: 1 << 1)
}

public protocol SwipeCell: UIView {
    
    ///可以滑动的方向
    var swipeDirection: SwipeDirection{
        get
        set
    }
    
    ///当前方向
    var currentDirection: SwipeDirection{
        get
    }
    
    ///代理
    var delegate: SwipeCellDelegate?{
        get
        set
    }
    
    ///切换按钮状态
    func setSwipeShow(_ show: Bool, direction: SwipeDirection, animated: Bool)
}

///代理
public protocol SwipeCellDelegate {
    
    ///获取按钮
    func swipeCell(_ cell: SwipeCell, swipeButtonsForDirection direction: SwipeDirection) -> [UIView]
}

///滑动显示的item
private class SwipeItem {
    
    ///按钮
    var view: UIView
    
    ///初始位置
    var startFrame: CGRect = .zero
    
    ///终点位置
    var endFrame: CGRect = .zero
    
    init(view: UIView) {
        self.view = view
    }
}

private class SwipeOverlay: UIView {
    
    ///关联的cell
    public weak var cell: SwipeCell?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let cell = self.cell, let superview = cell.superview else {
            return super.hitTest(point, with: event)
        }
        
        let rect = superview.convert(cell.frame, to: self)
        if rect.contains(point) {
            return nil
        }
        
        cell.setSwipeShow(false, direction: cell.currentDirection, animated: true)
        
        //不阻塞cell的事件
        if let tableView = self.superview as? UITableView {
            let cells = tableView.visibleCells
            for cell in cells {
                let rect = cell.superview!.convert(cell.frame, to: self)
                if rect.contains(point) {
                    return cell
                }
            }
        } else if let collectionView = self.superview as? UICollectionView {
            let cells = collectionView.visibleCells
            for cell in cells {
                let rect = cell.superview!.convert(cell.frame, to: self)
                if rect.contains(point) {
                    return cell
                }
            }
        }
        
        return super.hitTest(point, with: event)
    }
}

///侧滑帮助类
public class GKSwipeCellHelper: NSObject, UIGestureRecognizerDelegate {
    
    ///平移手势
    private var panGestureRecognizer: UIPanGestureRecognizer?

    ///内容快照
    private var snapshotView: UIImageView?

    ///当前按钮
    private var currentSwipeItems: [SwipeItem]?

    ///滑动的最大位置
    private var maxTranslationX: CGFloat = 0

    ///当前方向
    public private(set) var currentDirection: SwipeDirection = .none

    ///平移量
    private var translationX: CGFloat = 0

    ///覆盖物
    private var overlay: SwipeOverlay?

    ///是否正在显示
    private var showing: Bool = false

    ///关联的cell
    private weak var cell: SwipeCell?
    
    public init(cell: SwipeCell) {
        self.cell = cell
        super.init()
    }
    
    public func setSwipeDirection(_ direction: SwipeDirection) {
        if direction != .none {
            if panGestureRecognizer == nil {
                let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                pan.delegate = self
                cell?.addGestureRecognizer(pan)
                panGestureRecognizer = pan
            }
            panGestureRecognizer?.isEnabled = true
        } else {
            panGestureRecognizer?.isEnabled = false
        }
    }
    
    public func setSwipeShow(_ show: Bool, direction: SwipeDirection, animated: Bool) {
        guard let cell = self.cell else {
            return
        }
        if showing == show || !cell.swipeDirection.contains(direction) {
            return
        }
        
        if show {
            showSnapShotViewIfNeeded()
            showSwipeButtonsIfNeeded(direction: direction)
            showSWipeButtons(animated: animated)
        } else {
            if snapshotView != nil {
                hideSwipeButtons(animated: animated)
            }
        }
    }

    public func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            setSwipeShow(false, direction: currentDirection, animated: false)
        }
    }
    
    public func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            setSwipeShow(false, direction: currentDirection, animated: false)
        }
    }
    
    // MARK: - Action

    ///点击快照
    @objc private func handleTapSnapshot() {
        hideSwipeButtons(animated: true)
    }

    ///平移
    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        guard let cell = self.cell else {
            return
        }
        
        if pan.state == .began && showing {
            let translation = pan.translation(in: cell)
            pan.setTranslation(CGPoint(maxTranslationX + translation.x, translation.y), in: cell)
        }
        
        translationX = pan.translation(in: cell).x
        let direction: SwipeDirection = translationX < 0 ? .left : .right
        
        switch pan.state {
        case .began, .changed :
            showSnapShotViewIfNeeded()
            showSwipeButtonsIfNeeded(direction: direction)
            layoutExtraViews()
            
        case .ended, .cancelled :
            //通过速度获取可能移到的位置
            let x = translationX + pan.velocity(in: cell).x
            var show = true
            switch currentDirection {
            case .left :
                show = x < maxTranslationX / 2
                
            case .right :
                show = x > maxTranslationX / 2
                
            default:
                break
            }
            
            if show {
                showSWipeButtons(animated: true)
            } else {
                hideSwipeButtons(animated: true)
            }
        default:
            break
        }
    }

    // MARK: - Pan

    ///显示快照
    private func showSnapShotViewIfNeeded() {
        if showing {
            return
        }
     
        guard let cell = self.cell else {
            return
        }
        
        if let cell = self.cell as? UITableViewCell {
            cell.isHighlighted = false
            cell.isSelected = false
        } else if let cell = self.cell as? UICollectionViewCell {
            cell.isHighlighted = false
        }
        
        showing = true
        if snapshotView == nil {
            let view = UIImageView()
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapSnapshot)))
            cell.addSubview(view)
            snapshotView = view
        }
        
        cell.bringSubviewToFront(snapshotView!)
        snapshotView?.frame = cell.bounds
        snapshotView?.image = UIImage.gkImageFromView(cell)
        
        for view in cell.subviews {
            if view != snapshotView {
                view.isHidden = true
            }
        }
        
        //添加覆盖物，防止多个滑动事件
        var container: UIView? = nil
        let cls: AnyClass = containerClass()
        
        var view = cell.superview
        while view != nil {
            if view!.isKind(of: cls) {
                container = view;
                break
            }
            view = view!.superview
        }
        
        if container != nil {
            if overlay == nil {
                let view = SwipeOverlay(frame: container!.bounds)
                container?.addSubview(view)
                overlay = view
            }
            overlay!.cell = cell
        }
    }

    private func containerClass() -> AnyClass {
        if self.cell is UITableViewCell {
            return UITableView.self
        } else if self.cell is UICollectionViewCell {
            return UICollectionView.self
        }
        return UIView.self
    }

    ///显示按钮
    private func showSwipeButtonsIfNeeded(direction: SwipeDirection) {
        
        if direction == currentDirection {
            return
        }
        
        guard let cell = self.cell else {
            return
        }
        
        currentDirection = direction
        assert(cell.delegate != nil, "\(cell.gkNameOfClass) delegate must not be nil")
        
        currentSwipeItems?.forEach({ (item) in
            item.view.removeFromSuperview()
        })
        
        var buttonTotalWidth: CGFloat = 0
        if cell.swipeDirection.contains(direction) {
            
            let buttons = cell.delegate!.swipeCell(cell, swipeButtonsForDirection: direction)
            var items = [SwipeItem]()
            for view in buttons {
                items.append(SwipeItem(view: view))
            }
            currentSwipeItems = items
            
            func addItem(_ item: SwipeItem) {
                let view = item.view
                cell.addSubview(view)
                buttonTotalWidth += view.gkWidth
                var frame = view.frame
                frame.origin.y = 0
                frame.size.height = cell.gkHeight
                if direction == .left {
                    frame.origin.x = cell.gkRight
                } else {
                    frame.origin.x = cell.gkLeft - view.gkWidth
                }
                view.frame = frame
                item.startFrame = frame
            }
            if direction == .right {
                for (_, item) in items.enumerated().reversed() {
                    addItem(item)
                }
            } else {
                for item in items {
                    addItem(item)
                }
            }
            
            var x: CGFloat = direction == .left ? cell.gkRight - buttonTotalWidth : cell.gkLeft;
            for item in items {
                var frame = item.startFrame
                frame.origin.x = x
                item.endFrame = frame
                
                x += frame.width
            }
        } else {
            currentSwipeItems = nil
        }
        
        maxTranslationX = direction == .left ? -buttonTotalWidth : buttonTotalWidth
    }

    private func hideSwipeButtons(animated: Bool) {
        showing = false
        
        guard let cell = self.cell else {
            return
        }
        let completon: ((Bool) -> Void) = { _ in
            
            self.currentDirection = .none
            self.maxTranslationX = 0
            self.translationX = 0
            
            self.overlay?.removeFromSuperview()
            self.overlay = nil
            
            if let items = self.currentSwipeItems {
                for item in items {
                    item.view.removeFromSuperview()
                }
            }
            self.currentSwipeItems = nil
            
            self.snapshotView?.removeFromSuperview()
            self.snapshotView = nil
            
            for view in cell.subviews {
                view.isHidden = false
            }
        }
        
        if cell.window != nil && cell.superview != nil && animated {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 0,
                options: .beginFromCurrentState,
                animations: {
                    self.snapshotView?.frame = cell.bounds
                    if let items = self.currentSwipeItems {
                        for item in items {
                            item.view.frame = item.startFrame
                        }
                    }
            }, completion: completon)
        } else {
            completon(true)
        }
    }

    private func showSWipeButtons(animated: Bool) {
        
        guard let cell = self.cell else {
            return
        }
        let animations: (() -> Void) = {
            self.snapshotView?.gkCenterX = cell.gkWidth / 2 + self.maxTranslationX
            if let items = self.currentSwipeItems {
                for item in items {
                    item.view.frame = item.endFrame
                }
            }
        }
  
        if cell.window != nil && cell.superview != nil && animated {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 0,
                options: .beginFromCurrentState,
                animations: animations)
        } else {
            animations()
        }
    }

    private func layoutExtraViews() {
        
        guard let items = self.currentSwipeItems, let cell = self.cell else {
            return
        }
        var translationX = self.translationX
        var extraWith: CGFloat = 0
        
        //当滑动超出范围时 添加阻尼系数
        let extra = abs(translationX) - abs(self.maxTranslationX)
        if extra > 0 {
            extraWith = extra * 0.3
            if translationX < 0 {
                extraWith = -extraWith
            }
            translationX = maxTranslationX + extraWith
        }
        
        snapshotView?.gkCenterX = cell.gkWidth / 2 + translationX
        var width: CGFloat = 0
        func layoutItem(_ item: SwipeItem) {
            var frame = item.startFrame
            let ratio: CGFloat = 1.0 - width / max(abs(maxTranslationX), abs(translationX))
            let extras: CGFloat = item.startFrame.width / maxTranslationX * extraWith
            if currentDirection == .left {
                frame.origin.x += ratio * translationX
            } else {
                frame.origin.x += ratio * translationX - extras
            }
            frame.size.width += extras
            item.view.frame = frame
            width += frame.width
        }
        
        if currentDirection == .left {
            for item in items {
                layoutItem(item)
            }
        } else {
            for (_, item) in items.enumerated().reversed() {
                layoutItem(item)
            }
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = panGestureRecognizer, let cell = self.cell, gestureRecognizer == pan {
            if let cell = self.cell as? UITableViewCell {
                if cell.isEditing {
                    return false
                }
            }
            
            let translation = pan.translation(in: self.cell)
            //垂直滑动
            if abs(translation.y) > abs(translation.x) {
                return false
            }
            return (translation.x < 0 && cell.swipeDirection.contains(.left))
                || (translation.x > 0 && cell.swipeDirection.contains(.right))
        }
        
        return true
    }
}
