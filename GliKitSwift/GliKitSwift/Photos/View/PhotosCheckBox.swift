//
//  PhotosCheckBox.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/28.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///相册选中
class PhotosCheckBox: UIView {
    
    ///是否选中
    public private(set) var checked: Bool = false
    
    ///选中文字字体
    var font: UIFont = .systemFont(ofSize: 12)
    
    ///选中的文字
    var checkedText: String? {
        didSet {
            if oldValue != checkedText {
                checkedTextSize = checkedText?.gkStringSize(font: font) ?? .zero
                setNeedsDisplay()
            }
        }
    }
    
    ///文字大小
    private var checkedTextSize: CGSize = .zero
    
    ///内边距
    var contentInsets: UIEdgeInsets = UIEdgeInsets.all(5)
    
    ///设置选中
    public func setChecked(_ checked: Bool, animated: Bool = false) {
        if self.checked != checked {
            self.checked = checked
            setNeedsDisplay()
            
            if checked && animated {
                let animation = CASpringAnimation(keyPath: "transform.scale")
                animation.fromValue = 0.7
                animation.toValue = 1.0
                animation.duration = 0.5
                layer.add(animation, forKey: "scale")
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initParams()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initParams()
    }
    
    func initParams(){
        isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            context.setShadow(offset: .zero, blur: 1, color: UIColor(white: 0.8, alpha: 0.5).cgColor)
            
            let lineWidth: CGFloat = 1.0
            context.setLineWidth(lineWidth)
            
            let radius: CGFloat = min(rect.width - contentInsets.left - contentInsets.right, rect.height - contentInsets.top - contentInsets.bottom) / 2.0
            let center = CGPoint(rect.width / 2, rect.height / 2)
            
            if checked {
                context.setFillColor(UIColor.gkThemeColor.cgColor)
                context.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
                context.fillPath()
                
                if let text = checkedText as NSString? {
                    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.gkThemeTintColor]
                    text.draw(at: CGPoint(center.x - checkedTextSize.width / 2, center.y - checkedTextSize.height / 2), withAttributes: attrs)
                }
            } else {
                context.addArc(center: center, radius: radius - lineWidth, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
                context.setStrokeColor(UIColor.gkThemeTintColor.cgColor)
                context.strokePath()
            }
            
            context.restoreGState()
        }
        
    }
}
