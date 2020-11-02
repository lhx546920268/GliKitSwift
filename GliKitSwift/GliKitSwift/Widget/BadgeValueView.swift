//
//  BadgeValueView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/2.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///角标视图
public class BadgeValueView: UIView {
    
    ///是否自动调整大小
    public var shouldAutoAdjustSize: Bool = true
    
    ///角标最小大小
    @CallbackWrapper
    public var minimumSize: CGSize = CGSize(15, 15)
    
    ///内容边距
    @CallbackWrapper
    public var contentInsets: UIEdgeInsets = UIEdgeInsets(3, 5)
    
    ///内部填充颜色
    @NeedDisplayWrapper
    public var fillColor: UIColor = .red
    
    ///边界颜色
    @NeedDisplayWrapper
    public var strokeColor: UIColor = .clear
    
    ///字体颜色
    @NeedDisplayWrapper
    public var textColor: UIColor = .white
    
    ///字体
    @CallbackWrapper
    public var font: UIFont = .boldSystemFont(ofSize: 9)
    
    ///当前要显示的字符
    public var value: String? {
        didSet{
            
            isZero = false
            if let _value = value {
                if _value.isInteger {
                    let num: Int = Swift.max(_value.intValue, 0)
                    isZero = num == 0
                    if num < max {
                        value = num.toString
                    } else {
                        value = shouldDisplayPlusSign ? "\(max)+" : max.toString
                    }
                }
            }
            
            refresh()
        }
    }
    
    ///是否是0
    private var isZero: Bool = false
    
    ///是否要显示加号 当达到最大值时
    @CallbackWrapper
    public var shouldDisplayPlusSign: Bool = false
    
    ///是否隐藏当 value = 0 时
    public var hideWhenZero: Bool = true
    
    ///显示的最大数字
    public var max: Int = 99
    
    ///是否是一个点
    @CallbackWrapper
    public var isPoint: Bool = false
    
    ///点的半径 当 isPoint = true 时有效
    @CallbackWrapper
    public var pointRadius: CGFloat = 4
    
    ///内容大小
    private var contentSize: CGSize = .zero {
        didSet{
            if oldValue != contentSize {
                if shouldAutoAdjustSize {
                    bounds = CGRect(0, 0 , contentSize.width, contentSize.height)
                }
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    ///文字大小
    public var textSize: CGSize = .zero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initParams()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initParams()
    }
    
    func initParams(){
        backgroundColor = .clear
        isUserInteractionEnabled = false
        isHidden = true
        
        let callback: VoidCallback = { [weak self] in
            self?.refresh()
        }
        
        _contentInsets.callback = callback
        _minimumSize.callback = callback
        _shouldDisplayPlusSign.callback = callback
        _isPoint.callback = callback
        _pointRadius.callback = callback
        _font.callback = callback
        
        _fillColor.view = self
        _strokeColor.view = self
        _textColor.view = self
    }
    
    public override var intrinsicContentSize: CGSize {
        contentSize
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            
            let width = rect.width
            let height = rect.height
            
            context.setFillColor(fillColor.cgColor)
            context.setStrokeColor(strokeColor.cgColor)
            context.setLineWidth(1)
            
            if isPoint {
                context.addArc(center: CGPoint(width / 2, height / 2), radius: pointRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
                context.fillPath()
            } else {
                let path = UIBezierPath(roundedRect: rect, cornerRadius: height / 2)
                context.addPath(path.cgPath)
                context.drawPath(using: .fillStroke)
                
                //绘制文字
                if let text = value as NSString? {
                    let point = CGPoint((width - textSize.width) / 2, (height - textSize.height) / 2)
                    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: textColor]
                    text.draw(at: point, withAttributes: attrs)
                }
            }
        }
    }
    
    // MARK: - private method
    
    
    ///刷新
    private func refresh() {
        if value == nil && !isPoint {
            isHidden = true
            return
        }
        
        isHidden = hideWhenZero && isZero && !isPoint
        
        var contentSize: CGSize
        if isPoint {
            contentSize = CGSize(pointRadius * 2, pointRadius * 2)
        } else {
            textSize = value?.gkStringSize(font: font) ?? .zero
            
            let width: CGFloat = textSize.width + contentInsets.width
            let height: CGFloat = textSize.height + contentInsets.height
            
            contentSize = CGSize(Swift.max(width, height), height)
            if contentSize.width < minimumSize.width {
                contentSize.width = minimumSize.width
            }
            
            if contentSize.height < minimumSize.height {
                contentSize.height = minimumSize.height
            }
        }
        
        self.contentSize = contentSize
        setNeedsDisplay()
    }
}
