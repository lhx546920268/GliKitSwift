//
//  Popover.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/7.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///弹出窗口箭头方向
public enum PopoverArrowDirection{
    
    ///向左
    case left
    
    ///向上
    case top
    
    ///向右
    case right
    
    ///向下
    case bottom
}

///弹出窗口代理
@objc public protocol PopoverDelegate: NSObjectProtocol{
    
    ///弹出窗口将要显示
    @objc optional func popoverWillShow(_ popover: Popover)
    
    ///弹出窗口已经显示
    @objc optional func popoverDidShow(_ popover: Popover)
    
    ///弹出窗口将要消失
    @objc optional func popoverWillDismiss(_ popover: Popover)
    
    ///弹出窗口已经消失
    @objc optional func popoverDidDismiss(_ popover: Popover)
}

///无色透明视图 点击时关闭弹窗窗口
open class PopoverOverlay : UIView{

    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.isUserInteractionEnabled = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

///无色透明视图 点击时关闭弹窗窗口
open class Popover: UIView, UIGestureRecognizerDelegate {
    
    ///背景颜色
    public var fillColor: UIColor = .white{
        didSet{
            if !oldValue.isEqualToColor(self.fillColor) {
                setNeedsDisplay()
            }
        }
    }
    
    ///边框颜色
    public var strokeColor: UIColor = .clear {
        didSet{
            if !oldValue.isEqualToColor(self.strokeColor) {
                setNeedsDisplay()
            }
        }
    }
    
    ///边框线条宽度
    public var strokeWidth: CGFloat = 0 {
        didSet{
            if oldValue != self.strokeWidth {
                setNeedsDisplay()
            }
        }
    }
    
    ///圆角
    public var cornerRadius: CGFloat = 0 {
        didSet{
            if oldValue != self.cornerRadius {
                setNeedsDisplay()
            }
        }
    }
    
    ///顶部偏移量
    public var offset: CGFloat = 0{
        didSet{
            if oldValue != self.offset {
                redraw()
            }
        }
    }
    
    ///箭头和 relatedRect 的间距
    public var arrowMargin: CGFloat = 3{
        didSet{
            if oldValue != self.arrowMargin {
                redraw()
            }
        }
    }
    
    ///弹窗距离父视图的最小边距
    public var mininumMargin: CGFloat = 10{
        didSet{
            if oldValue != self.mininumMargin {
                redraw()
            }
        }
    }
    
    ///内容边距
    public var contentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8){
        didSet{
            if oldValue != self.contentInsets, let contentView = self.contentView {
                var frame = self.frame;
                frame.size.width = contentView.gkWidth + self.contentInsets.left + self.contentInsets.right
                frame.size.height = contentView.gkHeight + self.contentInsets.right + self.contentInsets.left
                self.frame = frame
                
                adjustContentView()
            }
        }
    }
    
    ///箭头尖角坐标
    public var arrowPoint: CGPoint = .zero{
        didSet{
            if oldValue != self.arrowPoint {
                redraw()
            }
        }
    }
    
    ///箭头大小
    public var arrowSize = CGSize(width: 15, height: 10){
        didSet{
            if oldValue != self.arrowSize {
                redraw()
            }
        }
    }
    
    ///箭头方向
    public private(set) var arrowDirection: PopoverArrowDirection = .top
    
    ///是否正在显示
    public private(set) var isShowing = false
    
    ///内容视图 设置的内容视图要有确定的大小 设置后会自动 addSubview
    public var contentView: UIView?{
        didSet{
            
            oldValue?.removeFromSuperview()
            if let view = self.contentView {
                view.layer.masksToBounds = true
                view.layer.cornerRadius = self.cornerRadius
                addSubview(view)
            }
        }
    }
    
    ///透明视图
    public lazy var overlay: PopoverOverlay = {
        
        let overlay = PopoverOverlay()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        overlay.addGestureRecognizer(tap)
        
        return overlay
    }()
    
    ///代理
    public weak var delegate: PopoverDelegate?
    
    ///动画起始位置
    private var originalPoint: CGPoint = .zero
    
    ///气泡出现的位置
    private var relatedRect: CGRect = .zero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        isOpaque = false
        clipsToBounds = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     显示弹出窗口
     *@param view 父视图
     *@param rect 触发菜单的按钮在 父视图中的位置大小，可用UIView 或 UIWindow 中的converRectTo 来转换
     *@param animated 是否动画
     *@param overlay 是否使用点击空白处关闭菜单
     */
    public func showInView(_ view: UIView, rect: CGRect, animated: Bool, overlay: Bool = true){
        
        if isShowing {
            return
        }
        
        relatedRect = rect
        delegate?.popoverWillShow?(self)
        
        if contentView == nil {
            initContentView()
        }
        
        
        let toFrame = setupFrame(fromView: view)
        
        if overlay {
            
            var frame = view.bounds
            frame.origin.y += offset
            self.overlay.frame = frame
            view.addSubview(self.overlay)
        }
        
        if animated {
            self.alpha = 0;
            self.overlay.alpha = 0
        }
        view.addSubview(self)
        isShowing = true
        
        if animated {
            
            var anchorPoint: CGPoint = .zero
            
            switch arrowDirection {
            case .top :
                anchorPoint.x = (originalPoint.x - toFrame.origin.x) / toFrame.width
                
            case .left :
                anchorPoint.y = (originalPoint.y - toFrame.origin.y) / toFrame.height
                
            case .right :
                anchorPoint.y = (originalPoint.y - toFrame.origin.y) / toFrame.height
                anchorPoint.x = 1.0
                
            case .bottom :
                anchorPoint.x = (originalPoint.x - toFrame.origin.x) / toFrame.width
                anchorPoint.y = 1.0
            }
            
            self.layer.anchorPoint = anchorPoint
            self.transform = CGAffineTransform.identity
            self.frame = toFrame
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.25, animations: {
                if overlay {
                    self.overlay.alpha = 1.0
                }
                self.alpha = 1.0
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { (_) in
                
                self.delegate?.popoverDidShow?(self)
            }
            
        }else{
            
            self.frame = toFrame
            self.delegate?.popoverDidShow?(self)
        }
    }
    
    ///设置菜单的位置
    private func setupFrame(fromView view: UIView) -> CGRect{
        
        if let contentView = self.contentView {
            
            let rect = relatedRect
            var contentSize = contentView.bounds.size
            contentSize.width += contentInsets.left + contentInsets.right
            contentSize.height += contentInsets.top + contentInsets.bottom
            
            let relateX = rect.origin.x
            let relateY = rect.origin.y
            let relateWidth = rect.width
            let relateHeight = rect.height
            
            let superWidth = view.frame.size.width
            let superHeight = view.frame.size.height - offset
            
            let margin = mininumMargin
            let scale: CGFloat = 2.0 / 3.0
            
            var resultRect: CGRect
            
            //尖角宽度
            let arrowWidth = arrowSize.width
            let arrowHeight = arrowSize.height
            
            if (superHeight - (relateY + relateHeight)) * scale > contentSize.height {
                arrowDirection = .top
                
                var x = relateX + relateWidth * 0.5 - contentSize.width * 0.5
                x = x < margin ? margin : x
                x = x + margin + contentSize.width > superWidth ? superWidth - contentSize.width - margin : x
                let y = relateY + relateHeight + arrowMargin
                
                resultRect = CGRect(x: x, y: y, width: contentSize.width, height: contentSize.height + arrowHeight)
                arrowPoint = CGPoint(x: min(relateX - x + relateWidth * 0.5, resultRect.origin.x + resultRect.width - cornerRadius - arrowSize.width), y: 0)
                originalPoint = CGPoint(x: x + arrowPoint.x, y: y)
            }else if (superHeight - (relateY + relateHeight)) * scale < contentSize.height {
                arrowDirection = .bottom
                
                var x = relateX + relateWidth * 0.5 - contentSize.width * 0.5
                x = x < margin ? margin : x
                x = x + margin + contentSize.width > superWidth ? superWidth - contentSize.width - margin : x
                let y = relateY - arrowMargin - contentSize.height - arrowHeight
                
                resultRect = CGRect(x: x, y: y, width: contentSize.width, height: contentSize.height + arrowHeight)
                arrowPoint = CGPoint(x: min(relateX - x + relateWidth * 0.5, resultRect.origin.x + resultRect.width - cornerRadius - arrowSize.width), y: resultRect.height)
                originalPoint = CGPoint(x: x + arrowPoint.x, y: y + resultRect.height)
            }else{
                if superWidth - (relateX + relateWidth) < contentSize.width {
                    arrowDirection = .right
                    
                    let x = relateX - arrowMargin - contentSize.width - arrowWidth;
                    var y = relateY + relateHeight * 0.5 - contentSize.height * 0.5
                    y = y < margin ? margin : y
                    y = y + margin + contentSize.height > superHeight ? superHeight - contentSize.height - margin : y;
                    
                    resultRect = CGRect(x: x, y: y, width: contentSize.width + arrowHeight, height:contentSize.height)
                    arrowPoint = CGPoint(x: resultRect.width, y: min(relateY - y + relateHeight * 0.5, resultRect.origin.y + resultRect.height - cornerRadius - arrowSize.width))
                    originalPoint = CGPoint(x: x + resultRect.width, y: y + arrowPoint.y)
                }else{
                    arrowDirection = .left
                    
                    let x = relateX + relateWidth + arrowMargin
                    var y = relateY + relateHeight * 0.5 - contentSize.height * 0.5
                    y = y < margin ? margin : y
                    y = y + margin + contentSize.height > superHeight ? superHeight - contentSize.height - margin : y
                    
                    resultRect = CGRect(x: x, y: y, width: contentSize.width + arrowHeight, height: contentSize.height)
                    arrowPoint = CGPoint(x: 0, y: min(relateY - y + relateHeight * 0.5, resultRect.origin.y + resultRect.height - cornerRadius - arrowSize.width))
                    originalPoint = CGPoint(x: x, y: y + arrowPoint.y)
                }
            }
            
            adjustContentView()
            
            return resultRect
        }
        
        return .zero
    }
    
    /**
     关闭弹出窗口
     *@param animated 是否动画
     */
    public func dismiss(animated: Bool = true){
        
        if !isShowing {
            return
        }
        
        delegate?.popoverWillDismiss?(self)
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                
                self.alpha = 0
                self.overlay.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { (_) in
                self.delegate?.popoverDidDismiss?(self)
                self.overlay.removeFromSuperview()
                self.removeFromSuperview()
            }
        } else {
            delegate?.popoverDidDismiss?(self)
            overlay.removeFromSuperview()
            removeFromSuperview()
        }
    }
    
    ///初始化内容视图 子类重写
    open func initContentView(){
        fatalError("\(self.gkNameOfClass) 必须实现 initContentView")
    }
    
    ///调整contentView rect
    private func adjustContentView(){
        
        if let contentView = self.contentView {
            var frame = contentView.frame
            frame.origin.x = contentInsets.left
            frame.origin.y = contentInsets.top
            
            switch arrowDirection {
            case .left :
                frame.origin.x += arrowSize.height
            case .top :
                frame.origin.y += arrowSize.height
            default:
                break;
            }
            
            contentView.frame = frame
        }
    }
    
    ///重新绘制
    public func redraw(){
        
        if self.superview != nil {
            self.frame = setupFrame(fromView: self.superview!)
            setNeedsDisplay()
        }
    }
    
    open override func draw(_ rect: CGRect) {
        
        if let context = UIGraphicsGetCurrentContext() {
            
            //尖角宽度
            let arrowWidth = arrowSize.width
            let arrowHeight = arrowSize.height
            
            var rectangular: CGRect
            let lineWidth = strokeWidth
            
            //设置绘制属性
            let cornerRadius = self.cornerRadius //矩形圆角
            context.setStrokeColor(strokeColor.cgColor)
            context.setFillColor(fillColor.cgColor)
            context.setLineWidth(lineWidth)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            
            //设置位置
            var arrowPoint: CGPoint
            var arrowPoint1: CGPoint
            var arrowPoint2: CGPoint
            
            switch arrowDirection {
            case .top :
                arrowPoint = CGPoint(self.arrowPoint.x, self.arrowPoint.y + lineWidth / 2.0)
                arrowPoint1 = CGPoint(x: arrowPoint.x - arrowWidth * 0.5, y: arrowPoint.y + arrowHeight)
                arrowPoint2 = CGPoint(x: arrowPoint.x + arrowWidth * 0.5, y: arrowPoint.y + arrowHeight)
                rectangular = CGRect(x: lineWidth, y: arrowHeight, width: self.bounds.width - lineWidth * 2.0, height: self.bounds.height - arrowHeight - lineWidth)
                
                let rectangularBottom = rectangular.height + rectangular.origin.y //矩形 height + y
                let rectangularRight = rectangular.origin.x + rectangular.width //矩形 width + x
                
                //绘制尖角左边
                context.move(to: arrowPoint)
                context.addLine(to: arrowPoint1)
                
                //绘制圆角矩形
                //向左边连接
                context.addLine(to: CGPoint(x: rectangular.origin.x + cornerRadius, y: rectangular.origin.y))
                
                //绘制左边圆角
                context.addArc(tangent1End: CGPoint(x: rectangular.origin.x, y: rectangular.origin.y), tangent2End: CGPoint(x: rectangular.origin.x, y: cornerRadius + rectangular.origin.y), radius: cornerRadius)
                
                //向下连接
                context.addLine(to: CGPoint(rectangular.origin.x, rectangularBottom - cornerRadius))
                
                //绘制左下角圆角
                context.addArc(tangent1End: CGPoint(rectangular.origin.x, rectangularBottom), tangent2End: CGPoint(rectangular.origin.x + cornerRadius, rectangularBottom), radius: cornerRadius)
                
                //向右边连接
                context.addLine(to: CGPoint(rectangularRight - cornerRadius, rectangularBottom))
                
                //绘制右下角圆角
                context.addArc(tangent1End: CGPoint(rectangularRight, rectangularBottom), tangent2End: CGPoint(rectangularRight, rectangularBottom - cornerRadius), radius: cornerRadius)
                
                //向上连接
                context.addLine(to: CGPoint(rectangularRight, rectangular.origin.y + cornerRadius))
                //绘制右上角圆角
                context.addArc(tangent1End: CGPoint(rectangularRight, rectangular.origin.y), tangent2End: CGPoint(rectangularRight - cornerRadius, rectangular.origin.y), radius: cornerRadius)
                
                //向尖角右下角连接
                context.addLine(to: arrowPoint2)
                context.addLine(to: arrowPoint)
                
            case .bottom :
                arrowPoint = CGPoint(self.arrowPoint.x, self.arrowPoint.y - lineWidth / 2.0)
                arrowPoint1 = CGPoint(arrowPoint.x - arrowWidth * 0.5, arrowPoint.y - arrowHeight)
                arrowPoint2 = CGPoint(arrowPoint.x + arrowWidth * 0.5, arrowPoint.y - arrowHeight)
                rectangular = CGRect(lineWidth, 0, self.bounds.width - lineWidth * 2.0, self.bounds.height - arrowHeight - lineWidth)
                
                let rectangularBottom = rectangular.height + rectangular.origin.y //矩形 height + y
                let rectangularRight = rectangular.origin.x + rectangular.width //矩形 width + x
                
                
                //绘制尖角 左边
                context.move(to: arrowPoint)
                context.addLine(to: arrowPoint1)
                
                //绘制圆角矩形
                //向左边连接
                context.addLine(to: CGPoint(rectangular.origin.x + cornerRadius, rectangularBottom))
                
                //绘制左下角圆角
                context.addArc(tangent1End: CGPoint(rectangular.origin.x, rectangularBottom), tangent2End: CGPoint(rectangular.origin.x, rectangularBottom - cornerRadius), radius: cornerRadius)
                
                //向上连接
                context.addLine(to: CGPoint(rectangular.origin.x, rectangular.origin.y + cornerRadius))
                
                //绘制左上角角圆角
                context.addArc(tangent1End: CGPoint(rectangular.origin.x, rectangular.origin.y), tangent2End: CGPoint(rectangular.origin.x + cornerRadius, rectangular.origin.y), radius: cornerRadius)
                
                //向右边连接
                context.addLine(to: CGPoint(rectangularRight - cornerRadius, rectangular.origin.y))
                
                //绘制右上角圆角
                context.addArc(tangent1End: CGPoint(rectangularRight, rectangular.origin.y), tangent2End: CGPoint(rectangularRight, rectangular.origin.y + cornerRadius), radius: cornerRadius)
                
                //向下连接
                context.addLine(to: CGPoint(rectangularRight, rectangularBottom - cornerRadius))
                
                //绘制右下角圆角
                context.addArc(tangent1End: CGPoint(rectangularRight, rectangularBottom), tangent2End: CGPoint(rectangularRight - cornerRadius, rectangularBottom), radius: cornerRadius)
                
                //向尖角右上角连接
                context.addLine(to: arrowPoint2)
                context.addLine(to: arrowPoint)
                
            case .left :
                arrowPoint = CGPoint(self.arrowPoint.x + lineWidth / 2.0, self.arrowPoint.y)
                arrowPoint1 = CGPoint(arrowPoint.x + arrowHeight, arrowPoint.y + arrowWidth * 0.5)
                arrowPoint2 = CGPoint(arrowPoint.x + arrowHeight, arrowPoint.y - arrowWidth * 0.5)
                rectangular = CGRect(arrowHeight, lineWidth, self.bounds.width - lineWidth - arrowHeight, self.bounds.height - lineWidth)
                
                let rectangularBottom = rectangular.height + rectangular.origin.y //矩形 height + y
                let rectangularRight = rectangular.origin.x + rectangular.width //矩形 width + x
                
                //绘制尖角下面
                context.move(to: arrowPoint)
                context.addLine(to: arrowPoint1)
                
                //绘制圆角矩形
                //向下连接
                context.addLine(to: CGPoint(rectangular.origin.x , rectangularBottom - cornerRadius))
                
                //绘制左下角圆角
                context.addArc(tangent1End: CGPoint(rectangular.origin.x, rectangularBottom), tangent2End: CGPoint(rectangular.origin.x + cornerRadius, rectangularBottom), radius: cornerRadius)
                
                //向右连接
                context.addLine(to: CGPoint(rectangularRight - cornerRadius, rectangularBottom))
                
                //绘制右下角圆角
                context.addArc(tangent1End: CGPoint(rectangularRight, rectangularBottom), tangent2End: CGPoint(rectangularRight, rectangularBottom - cornerRadius), radius: cornerRadius)
                
                //向上连接
                context.addLine(to: CGPoint(rectangularRight, rectangular.origin.y + cornerRadius))
                
                //绘制右上角圆角
                context.addArc(tangent1End: CGPoint(rectangularRight, rectangular.origin.y), tangent2End: CGPoint(rectangularRight - cornerRadius, rectangular.origin.y), radius: cornerRadius)
                
                //向左连接
                context.addLine(to: CGPoint(rectangular.origin.x + cornerRadius, rectangular.origin.y))
                
                //绘制左上角圆角
                context.addArc(tangent1End: CGPoint(rectangular.origin.x, rectangular.origin.y), tangent2End: CGPoint(rectangular.origin.x, rectangular.origin.y + cornerRadius), radius: cornerRadius)
                
                //向尖角上面连接
                context.addLine(to: arrowPoint2)
                context.addLine(to: arrowPoint)
                
            case .right :
                arrowPoint = CGPoint(self.arrowPoint.x - lineWidth / 2.0, self.arrowPoint.y)
                arrowPoint1 = CGPoint(arrowPoint.x - arrowHeight, arrowPoint.y + arrowWidth * 0.5)
                arrowPoint2 = CGPoint(arrowPoint.x - arrowHeight, arrowPoint.y - arrowWidth * 0.5)
                rectangular = CGRect(0, lineWidth, self.bounds.width - lineWidth - arrowHeight, self.bounds.height - lineWidth * 2)
                
                let rectangularBottom = rectangular.height + rectangular.origin.y //矩形 height + y
                let rectangularRight = rectangular.origin.x + rectangular.width //矩形 width + x
                
                //绘制尖角下面
                context.move(to: arrowPoint)
                context.addLine(to: arrowPoint1)
                
                //绘制圆角矩形
                //向右下连接
                context.addLine(to: CGPoint(rectangularRight, rectangularBottom - cornerRadius))
                
                //绘制右下角圆角
                context.addArc(tangent1End: CGPoint(rectangularRight, rectangularBottom), tangent2End: CGPoint(rectangularRight - cornerRadius, rectangularBottom), radius: cornerRadius)
                
                //向左连接
                context.addLine(to: CGPoint(rectangular.origin.x - cornerRadius, rectangularBottom))
                
                //绘制左下角圆角
                context.addArc(tangent1End: CGPoint(rectangular.origin.x, rectangularBottom), tangent2End: CGPoint(rectangular.origin.x, rectangularBottom - cornerRadius), radius: cornerRadius)
                
                //向左上连接
                context.addLine(to: CGPoint(rectangular.origin.x, rectangular.origin.y - cornerRadius))
                
                //绘制左上角圆角
                context.addArc(tangent1End: CGPoint(rectangular.origin.x, rectangular.origin.y), tangent2End: CGPoint(rectangular.origin.x + cornerRadius, rectangular.origin.y), radius: cornerRadius)
                
                //向上连接
                context.addLine(to: CGPoint(rectangularRight - cornerRadius, rectangular.origin.y))
                
                //绘制右上角圆角
                context.addArc(tangent1End: CGPoint(rectangularRight, rectangular.origin.y), tangent2End: CGPoint(rectangularRight, rectangular.origin.y - cornerRadius), radius: cornerRadius)
                
                //向尖角上面连接
                context.addLine(to: arrowPoint2)
                context.addLine(to: arrowPoint)
            }
            
            context.drawPath(using: .fillStroke)
        }
    }
    
    // MARK: - Overlay
    
    ///点击背景透明视图
    @objc private func handleTap(){
        dismiss()
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let contentView = self.contentView {
            let point = gestureRecognizer.location(in: overlay)
            if contentView.frame.contains(point) {
                return false
            }
        }
        return true
    }
}
