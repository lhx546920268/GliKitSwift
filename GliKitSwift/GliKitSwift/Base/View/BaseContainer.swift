//
//  BaseContainer.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/16.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import SnapKit

///大小自适应
public let wrapContent: CGFloat = -1;

///自动布局 安全区域
public struct SafeLayoutGuide: OptionSet {
    
    public let rawValue: UInt
    
    public init(rawValue: UInt){
        self.rawValue = rawValue
    }
    
    public static let none = SafeLayoutGuide(rawValue: 0)
    
    public static let top = SafeLayoutGuide(rawValue: 1)
    
    public static let left = SafeLayoutGuide(rawValue: 1 << 1)
    
    public static let bottom = SafeLayoutGuide(rawValue: 1 << 2)
    
    public static let right = SafeLayoutGuide(rawValue: 1 << 3)
    
    public static let all = SafeLayoutGuide(rawValue: top.rawValue | left.rawValue | bottom.rawValue | right.rawValue)
}

///自动布局 loading 范围
public struct OverlayArea: OptionSet {
    
    public let rawValue: UInt
    
    public init(rawValue: UInt){
        self.rawValue = rawValue
    }
    
    ///都不遮住 header 和 footer会看到得到
    public static let none = OverlayArea(rawValue: 0)
    
    ///pageloading视图将遮住header
    public static let pageLoadingTop = OverlayArea(rawValue: 1 << 1)
    
    ///pageloading视图将遮住footer
    public static let pageLoadingBottom = OverlayArea(rawValue: 1 << 2)
    
    ///空视图将遮住header
    public static let emptyViewTop = OverlayArea(rawValue: 1 << 3)
    
    ///空视图将遮住footer
    public static let emptyViewBottom = OverlayArea(rawValue: 1 << 4)
    
    ///遮住顶部
    public static let top = OverlayArea(rawValue: pageLoadingTop.rawValue | emptyViewTop.rawValue)
    
    ///遮住底部
    public static let bottom = OverlayArea(rawValue: pageLoadingBottom.rawValue | emptyViewBottom.rawValue)
    
    ///遮住所有
    public static let all = OverlayArea(rawValue: top.rawValue | bottom.rawValue)
}

/**
 基础容器视图
 */
open class BaseContainer: UIView {
    
    ///固定在顶部的视图
    public var topView: UIView?{
        didSet{
            if oldValue != self.topView {
                oldValue?.removeFromSuperview()
                layoutTopView()
            }
        }
    }

    ///固定在底部的视图
    public var bottomView: UIView?{
        didSet{
            if oldValue != self.bottomView {
                oldValue?.removeFromSuperview()
                layoutBottomView()
            }
        }
    }

    ///内容视图
    public var contentView: UIView?{
        didSet{
            if oldValue != self.contentView {
                oldValue?.removeFromSuperview()
                layoutConentView()
            }
        }
    }

    ///关联的viewController
    public private(set) weak var viewController: BaseViewController?

    ///自动布局 安全区域 default is 'GKSafeLayoutGuideTop' 如果是以弹窗的形式显示 必须设为none
    public var safeLayoutGuide = SafeLayoutGuide.top

    ///自动布局 loading 范围
    public var overlayArea = OverlayArea.top

    ///布局完成回调
    public var layoutSubviewsCompletion: (() -> Void)?
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutSubviewsCompletion?()
    }
    
    // MARK: - Init

    ///通过 UIViewController初始化
    public init(viewController: BaseViewController?){
        
        self.viewController = viewController
        super.init(frame: CGRect.zero)
        initParams()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initParams()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        initParams()
    }
    
    ///初始化
    private func initParams(){
        backgroundColor = .white
    }
}

///设置视图扩展
extension BaseContainer {
    
    /**
     设置顶部视图
     
     @param topView 顶部视图
     @param height 视图高度，GKWrapContent 为自适应
     */
    public func setTopView(topView: UIView?, height: CGFloat){
        if topView == self.topView {
            return
        }
        if topView != nil && height != wrapContent {
            topView?.snp.makeConstraints({ (maker) in
                maker.height.equalTo(height)
            })
        }
        self.topView = topView
    }

    /**
     设置底部视图
     
     @param bottomView 底部视图
     @param height 视图高度，GKWrapContent 为自适应
     */
    public func setBottomView(bottomView: UIView?, height: CGFloat){
        
        if bottomView != nil && height != wrapContent {
            bottomView?.snp.makeConstraints({ (maker) in
                maker.height.equalTo(height)
            })
        }
        self.bottomView = bottomView
    }
    
    /**
     布局顶部视图
     */
    private func layoutTopView(){
        
        if let view = topView {
            
            if view.superview != self {
                view.removeFromSuperview()
                addSubview(view)
            }
            
            view.snp.makeConstraints { (maker) in
                
                if viewController != nil && safeLayoutGuide.contains(.top) {
                    maker.top.equalTo(viewController!.gkSafeAreaLayoutGuideTop)
                } else {
                    maker.top.equalTo(snp_top)
                }
                
                if viewController != nil && safeLayoutGuide.contains(.left) {
                    maker.leading.equalTo(viewController!.gkSafeAreaLayoutGuideLeft)
                } else {
                    maker.leading.equalTo(snp_leading)
                }
                
                if viewController != nil && safeLayoutGuide.contains(.right) {
                    maker.trailing.equalTo(viewController!.gkSafeAreaLayoutGuideRight)
                } else {
                    maker.trailing.equalTo(snp_trailing)
                }
            }
            
            if contentView != nil {
                contentView!.snp.updateConstraints { (maker) in
                    maker.top.equalTo(topView!.snp_bottom)
                }
            }
            
        }else{
            
            if contentView != nil {
                contentView!.snp.updateConstraints { (maker) in
                    if viewController != nil && safeLayoutGuide.contains(.top) {
                        maker.top.equalTo(viewController!.gkSafeAreaLayoutGuideTop)
                    } else {
                        maker.top.equalTo(snp_top)
                    }
                }
            }
        }
    }
    
    /**
     布局底部视图
     */
    private func layoutBottomView(){
        
        if let view = bottomView {
         
            if view.superview != self {
                view.removeFromSuperview()
                addSubview(view)
            }
            
            view.snp.makeConstraints { (maker) in
                
                if viewController != nil && safeLayoutGuide.contains(.bottom) {
                    maker.bottom.equalTo(viewController!.gkSafeAreaLayoutGuideBottom)
                } else {
                    maker.top.equalTo(snp_bottom)
                }
                
                if viewController != nil && safeLayoutGuide.contains(.left) {
                    maker.leading.equalTo(viewController!.gkSafeAreaLayoutGuideLeft)
                } else {
                    maker.leading.equalTo(snp_leading)
                }
                
                if viewController != nil && safeLayoutGuide.contains(.right) {
                    maker.trailing.equalTo(viewController!.gkSafeAreaLayoutGuideRight)
                } else {
                    maker.trailing.equalTo(snp_trailing)
                }
            }
            
            if contentView != nil {
                contentView!.snp.updateConstraints { (maker) in
                    maker.bottom.equalTo(bottomView!.snp_top)
                }
            }
            
        }else{
            
            if contentView != nil {
                contentView!.snp.updateConstraints { (maker) in
                    if viewController != nil && safeLayoutGuide.contains(.bottom) {
                        maker.bottom.equalTo(viewController!.gkSafeAreaLayoutGuideBottom)
                    } else {
                        maker.bottom.equalTo(snp_bottom)
                    }
                }
            }
        }
    }
    
    /**
     布局内容视图
     */
    private func layoutConentView(){
        
        if let view = contentView {

            if(view.superview != self){
                view.removeFromSuperview()
                addSubview(view)
            }
            
            view.snp.makeConstraints { (maker) in
                if viewController != nil && safeLayoutGuide.contains(.left) {
                    maker.leading.equalTo(viewController!.gkSafeAreaLayoutGuideLeft)
                } else {
                    maker.leading.equalTo(snp_leading)
                }
                
                if viewController != nil && safeLayoutGuide.contains(.right) {
                    maker.trailing.equalTo(viewController!.gkSafeAreaLayoutGuideRight)
                } else {
                    maker.trailing.equalTo(snp_trailing)
                }
                
                if topView != nil {
                    maker.top.equalTo(topView!.snp_bottom)
                } else {
                    if viewController != nil && safeLayoutGuide.contains(.top) {
                        maker.top.equalTo(viewController!.gkSafeAreaLayoutGuideTop)
                    } else {
                        maker.top.equalTo(snp_top)
                    }
                }
                
                if bottomView != nil {
                    maker.bottom.equalTo(bottomView!.snp_top)
                } else {
                    if viewController != nil && safeLayoutGuide.contains(.bottom) {
                        maker.bottom.equalTo(viewController!.gkSafeAreaLayoutGuideBottom)
                    } else {
                        maker.bottom.equalTo(snp_bottom)
                    }
                }
            }
        }
    }
}
