//
//  Button.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/2.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

/**
 Button 图标位置
 */
public enum ButtonImagePosition{
    
    ///左边 系统默认
    case left
    
    ///图标在文字右边
    case right
    
    ///图标在文字顶部
    case top
    
    ///图标在文字底部
    case bottom
}

/**
 自定义按钮  可设置按钮图标位置和间距，图标显示大小
 @warning UIControlContentHorizontalAlignmentFill 和 UIControlContentVerticalAlignmentFill 将忽略
 */
open class Button: UIButton {
    
    ///图标位置
    @NeedLayoutWrapper
    public var imagePosition: ButtonImagePosition = .left
    
    ///图标和文字间隔
    @NeedLayoutWrapper
    public var imagePadding: CGFloat = 0
    
    ///图标大小
    @NeedLayoutWrapper
    public var imageSize: CGSize = CGSize.zero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initParams()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initParams()
    }
    
    private func initParams(){
        _imagePosition.view = self
        _imagePadding.view = self
        _imageSize.view = self
    }
    
    override open var intrinsicContentSize: CGSize{
        get{
            var size = super.intrinsicContentSize
            
            if self.shouldChange() {
                let imageSize = self.currentImageSize()
                let titleSize = self.currentTitleSize()
                
                var width = size.width
                var height = size.height
                
                switch self.imagePosition {
                case .left, .right :
                    width = imageSize.width + self.imagePadding + titleSize.width + self.contentEdgeInsets.left + self.contentEdgeInsets.right
                    height = max(imageSize.height, titleSize.height) + self.contentEdgeInsets.top + self.contentEdgeInsets.bottom
                    
                case .top, .bottom :
                    width = max(imageSize.width, titleSize.width) + self.contentEdgeInsets.left + self.contentEdgeInsets.right
                    height = imageSize.height + self.imagePadding + titleSize.height + self.contentEdgeInsets.top + self.contentEdgeInsets.bottom
                }
                
                size = CGSize(width: width, height: height)
            }
            
            return size
        }
    }
    
    override open func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        
        var rect = super.imageRect(forContentRect: contentRect)
        
        if !shouldChange(){
            return rect
        }
        
        let titleSize = self.currentTitleSize()
        let imageSize = self.currentImageSize()
        rect.size.width = imageSize.width
        rect.size.height = imageSize.height
        
        var padding: CGFloat = 0
        var position = ButtonImagePosition.left;
        switch self.imagePosition {
        case .left :
            padding = 0;
            position = .right
            
        case .right :
            padding = self.imagePadding
            position = .left
            
        case .top :
            padding = 0;
            position = .bottom
            
        case .bottom :
            padding = self.imagePadding
            position = .top
            
        }
        
        return setup(rect: rect, contentRect: contentRect, anotherSize: titleSize, insets: self.imageEdgeInsets, padding: padding, position: position)
    }
    
    override open func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        
        let rect = super.titleRect(forContentRect: contentRect)
        
        if !shouldChange() {
            return rect
        }
        
        return setup(rect: rect, contentRect: contentRect, anotherSize: self.currentImageSize(), insets: self.titleEdgeInsets, padding: self.imagePadding, position: self.imagePosition)
    }
    
    ///设置rect
    private func setup(rect: CGRect, contentRect: CGRect, anotherSize: CGSize, insets: UIEdgeInsets, padding: CGFloat, position: ButtonImagePosition) -> CGRect{
        
        let horizontal = self.currentContentHorizontalAlignment()
        let vertical = self.contentVerticalAlignment
        var frame = rect
        
        switch position {
        case .left, .right :
            switch vertical {
            case .top :
                frame.origin.y = self.contentEdgeInsets.top + insets.top
                
            case .center :
                frame.origin.y = contentRect.origin.y + (contentRect.size.height - rect.size.height) / 2.0 + insets.top - insets.bottom
                
            case .bottom :
                frame.origin.y = contentRect.size.height - rect.size.height - self.contentEdgeInsets.bottom - insets.bottom;
                
            default:
                break
            }
            
        case .top :
            switch vertical {
            case .top :
                frame.origin.y = self.contentEdgeInsets.top + anotherSize.height + insets.top + padding
                
            case .center :
                frame.origin.y = contentRect.origin.y + (contentRect.size.height - (anotherSize.height + padding + rect.size.height)) / 2.0 + insets.top - insets.bottom + anotherSize.height + padding
                
            case .bottom :
                frame.origin.y = contentRect.size.height - rect.size.height - self.contentEdgeInsets.bottom - insets.bottom
                
            default:
                break
            }
            
        case .bottom :
            switch vertical {
            case .top :
                frame.origin.y = self.contentEdgeInsets.top + insets.top
                
            case .center :
                frame.origin.y = contentRect.origin.y + (contentRect.size.height - (anotherSize.height + padding + rect.size.height)) / 2.0 + insets.top - insets.bottom
                
            case .bottom :
                frame.origin.y = contentRect.size.height - rect.size.height - self.contentEdgeInsets.bottom - insets.bottom
                
            default:
                break
            }
            
        }
        
        switch position {
        case .left :
            
            switch horizontal {
            case .left :
                frame.origin.x = self.contentEdgeInsets.left + anotherSize.width + insets.left + padding
                
            case .center :
                frame.origin.x = (contentRect.size.width - (anotherSize.width + padding + rect.size.width)) / 2.0 + insets.left - insets.right + anotherSize.width + padding
                
            case .right :
                frame.origin.x = contentRect.size.width - rect.size.width - self.contentEdgeInsets.right - insets.right
                
            default:
                break
            }
            
        case .right :
            switch horizontal {
            case .left :
                frame.origin.x = self.contentEdgeInsets.left + insets.left
                
            case .center :
                frame.origin.x = (contentRect.size.width - (anotherSize.width + padding + rect.size.width)) / 2.0 + insets.left - insets.right
                
            case .right :
                frame.origin.x = contentRect.size.width - rect.size.width - self.contentEdgeInsets.right - insets.right
                
            default:
                break
            }
            
        case .top, .bottom :
            switch horizontal {
            case .left:
                frame.origin.x = self.contentEdgeInsets.left + insets.left;
                
            case .center :
                frame.origin.x = (contentRect.size.width - rect.size.width) / 2.0 + insets.left - insets.right;
                
            case .right :
                frame.origin.x = contentRect.size.width - rect.size.width - self.contentEdgeInsets.right - insets.right;
                
            default:
                break
            }
            
        }
        
        return frame
    }
    
    ///是否需要
    private func shouldChange() -> Bool{
        
        if contentHorizontalAlignment == .fill || contentVerticalAlignment == .fill {
            return false
        }
        
        if self.imagePosition == .left && self.imagePadding == 0 && self.imageSize == CGSize.zero {
            return false
        }
        
        return true
    }
    
    ///获取图标大小
    private func currentImageSize() -> CGSize{
        
        if let image = self.currentImage{
            return self.imageSize == CGSize.zero ? image.size : self.imageSize
        } else {
            return CGSize.zero
        }
    }
    
    ///获取当前标题大小
    private func currentTitleSize() -> CGSize{
        
        if let attributedTitle = self.currentAttributedTitle {
            return attributedTitle.gkBounds()
        }
        
        if let title = self.currentTitle, let font = self.titleLabel?.font {
            return title.gkStringSize(font: font)
        }
        
        return CGSize.zero
    }
    
    ///获取当前水平对齐方式
    private func currentContentHorizontalAlignment() -> ContentHorizontalAlignment{
        var horizontal = contentHorizontalAlignment
        
        if #available(iOS 11, *) {
            if horizontal == .leading {
                horizontal = .left
            } else if horizontal == .trailing {
                horizontal = .right
            }
        }
        
        return horizontal
    }
    
}
