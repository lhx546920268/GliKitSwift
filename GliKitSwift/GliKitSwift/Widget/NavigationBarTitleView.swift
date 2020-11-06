//
//  NavigationBarTitleView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/5.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///iOS 11.0后 导航栏的标题栏， 在ios11后 导航栏的图层结构已发生变化，使用这个可以调整标题栏大小
///titleView内部有子视图使用约束时才需要
open class NavigationBarTitleView: UIView {
    
    ///内容视图 子视图都添加到这里
    public let contentView: UIView = UIView(frame: CGRect(0, 0, UIScreen.gkWidth, 30))
    
    ///内容大小
    private var _contentSize: CGSize = .zero
    public var contentSize: CGSize {
        set{
            if !newValue.equalTo(_contentSize) {
                _contentSize = newValue
                invalidateIntrinsicContentSize()
            }
        }
        get{
            if _contentSize.equalTo(.zero) {
                var width = UIScreen.gkWidth
                if let view = navigationItem?.leftBarButtonItem?.customView {
                    width -= view.gkWidth + marginForItem
                }
                
                if let view = navigationItem?.rightBarButtonItem?.customView {
                    width -= view.gkWidth + marginForItem
                }
                
                return CGSize(width, gkHeight)
            }
            
            return _contentSize
        }
    }
    
    ///关联的item
    public private(set) weak var navigationItem: UINavigationItem?
    
    ///和导航栏按钮的间距
    public var marginForItem: CGFloat {
        UIApplication.gkNavigationBarMarginForItem
    }
    
    ///和屏幕的间距
    public var marginForScreen: CGFloat {
        UIApplication.gkNavigationBarMarginForScreen
    }
    
    init(item: UINavigationItem) {
        navigationItem = item
        super.init(frame: contentView.frame)
        
        clipsToBounds = false
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var intrinsicContentSize: CGSize {
        let size = contentSize
        if size.hasZeroOrNegative {
            return UIView.layoutFittingExpandedSize
        }
        return size
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        let size = contentSize
        bounds = CGRect(0, 0, size.width, size.height)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        var width = gkWidth
        var frame = CGRect(0, 0, 0, gkHeight)
        
        if navigationItem?.leftBarButtonItem != nil {
            frame.origin.x = -marginForItem
            width += marginForItem
        } else {
            frame.origin.x = UIApplication.gkNavigationBarMargin - marginForScreen
            width -= UIApplication.gkNavigationBarMargin - marginForScreen
        }
        
        if navigationItem?.rightBarButtonItem != nil {
            width += marginForItem
        } else {
            width -= UIApplication.gkNavigationBarMargin - marginForScreen
        }
        
        frame.size.width = width
        contentView.frame = frame
    }
}
