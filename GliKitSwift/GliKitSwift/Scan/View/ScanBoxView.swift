//
//  ScanBoxView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/5.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///扫描框
class ScanBoxView: UIView {
    
    ///四角线条宽度
    @NeedDisplayWrapper
    var cornerLineWidth: CGFloat = 5
    
    ///边角位置
    enum CornerPosition {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    };
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            context.setLineWidth(cornerLineWidth)
            context.setStrokeColor(UIColor.gkThemeColor.cgColor)
            
            drawCorner(in: context, position: .topLeft)
            drawCorner(in: context, position: .topRight)
            drawCorner(in: context, position: .bottomLeft)
            drawCorner(in: context, position: .bottomRight)
            
            context.strokePath()
            context.restoreGState()
        }
    }
    
    ///绘制扫描区域边角
    private func drawCorner(in context: CGContext, position: CornerPosition) {
        var size = CGSize(20, 20)
        var point: CGPoint = .zero
        
        switch position {
        case .topLeft :
            size.width += point.x
            size.height += point.y
            
            context.move(to: CGPoint(point.x, size.height))
            context.addLine(to: point)
            context.addLine(to: CGPoint(size.width, point.y))
            
        case .bottomLeft :
            point.y += gkHeight - size.height
            size.width += point.x
            size.height += point.y
            
            context.move(to: point)
            context.addLine(to: CGPoint(point.x, size.height))
            context.addLine(to: CGPoint(size.width, size.height))
            
        case .topRight :
            point.x += gkWidth - size.width
            size.width += point.x
            size.height += point.y
            
            context.move(to: point)
            context.addLine(to: CGPoint(size.width, point.y))
            context.addLine(to: CGPoint(size.width, size.height))
        case .bottomRight :
            point.x += gkWidth - size.width
            point.y += gkHeight - size.height
            size.width += point.x
            size.height += point.y
            
            context.move(to: CGPoint(point.x, size.height))
            context.addLine(to: CGPoint(size.width, size.height))
            context.addLine(to: CGPoint(size.width, point.y))
        }
    }
}
