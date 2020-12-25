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
    
    public static let none = SafeLayoutGuide([])
    
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
    public static let none = OverlayArea([])
    
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

///基础容器视图
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
public extension BaseContainer {
    
    /**
     设置顶部视图
     
     @param topView 顶部视图
     @param height 视图高度，GKWrapContent 为自适应
     */
    func setTopView(_ topView: UIView?, height: CGFloat){
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
    func setBottomView(_ bottomView: UIView?, height: CGFloat){
        
        if bottomView != nil && height != wrapContent {
            bottomView?.snp.makeConstraints({ (maker) in
                maker.height.equalTo(height)
            })
        }
        self.bottomView = bottomView
    }
    
    ///布局顶部视图
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
                    maker.top.equalTo(snp.top)
                }
                
                if viewController != nil && safeLayoutGuide.contains(.left) {
                    maker.leading.equalTo(viewController!.gkSafeAreaLayoutGuideLeft)
                } else {
                    maker.leading.equalTo(snp.leading)
                }
                
                if viewController != nil && safeLayoutGuide.contains(.right) {
                    maker.trailing.equalTo(viewController!.gkSafeAreaLayoutGuideRight)
                } else {
                    maker.trailing.equalTo(snp.trailing)
                }
            }
            
            if contentView != nil {
                contentView!.snp.updateConstraints { (maker) in
                    maker.top.equalTo(topView!.snp.bottom)
                }
            }
            
        }else{
            
            if contentView != nil {
                contentView!.snp.updateConstraints { (maker) in
                    if viewController != nil && safeLayoutGuide.contains(.top) {
                        maker.top.equalTo(viewController!.gkSafeAreaLayoutGuideTop)
                    } else {
                        maker.top.equalTo(snp.top)
                    }
                }
            }
        }
    }
    
    ///布局底部视图
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
                    maker.top.equalTo(snp.bottom)
                }
                
                if viewController != nil && safeLayoutGuide.contains(.left) {
                    maker.leading.equalTo(viewController!.gkSafeAreaLayoutGuideLeft)
                } else {
                    maker.leading.equalTo(snp.leading)
                }
                
                if viewController != nil && safeLayoutGuide.contains(.right) {
                    maker.trailing.equalTo(viewController!.gkSafeAreaLayoutGuideRight)
                } else {
                    maker.trailing.equalTo(snp.trailing)
                }
            }
            
            if contentView != nil {
                contentView!.snp.updateConstraints { (maker) in
                    maker.bottom.equalTo(bottomView!.snp.top)
                }
            }
            
        }else{
            
            if contentView != nil {
                contentView!.snp.updateConstraints { (maker) in
                    if viewController != nil && safeLayoutGuide.contains(.bottom) {
                        maker.bottom.equalTo(viewController!.gkSafeAreaLayoutGuideBottom)
                    } else {
                        maker.bottom.equalTo(snp.bottom)
                    }
                }
            }
        }
    }
    
    ///布局内容视图
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
                    maker.leading.equalTo(snp.leading)
                }
                
                if viewController != nil && safeLayoutGuide.contains(.right) {
                    maker.trailing.equalTo(viewController!.gkSafeAreaLayoutGuideRight)
                } else {
                    maker.trailing.equalTo(snp.trailing)
                }
                
                if topView != nil {
                    maker.top.equalTo(topView!.snp.bottom)
                } else {
                    if viewController != nil && safeLayoutGuide.contains(.top) {
                        maker.top.equalTo(viewController!.gkSafeAreaLayoutGuideTop)
                    } else {
                        maker.top.equalTo(snp.top)
                    }
                }
                
                if bottomView != nil {
                    maker.bottom.equalTo(bottomView!.snp.top)
                } else {
                    if viewController != nil && safeLayoutGuide.contains(.bottom) {
                        maker.bottom.equalTo(viewController!.gkSafeAreaLayoutGuideBottom)
                    } else {
                        maker.bottom.equalTo(snp.bottom)
                    }
                }
            }
        }
    }
}

///约束
public extension BaseContainer {
    
    ///顶部约束 如果有topView，就是 topView.mas_bottom，否则如果包含safeLayoutGuide.top，就是 safeAreaTop，否则就是self.mas_top
    var topItem: ConstraintItem {
        get{
            if topView != nil {
                return topView!.snp.bottom
            }
            if viewController != nil && safeLayoutGuide.contains(.top) {
                return viewController!.gkSafeAreaLayoutGuideTop
            } else {
                return snp.top
            }
        }
    }

    ///底部约束 如果有bottomView，就是 bottomView.mas_top
    ///如果包含safeLayoutGuide.bottom，就是 safeAreaBottom
    ///否则就是self.mas_bottom，如果有tabBar 还会减去 tabBar.height
    var bottomItem: ConstraintItem {
        get{
            if bottomView != nil {
                return bottomView!.snp.top
            }
            if viewController != nil && safeLayoutGuide.contains(.bottom) {
                return viewController!.gkSafeAreaLayoutGuideBottom
            } else {
                return snp.bottom
            }
        }
    }

    ///底部约束偏移量
    var bottomOffset: CGFloat {
        get{
            if let vc = self.viewController {
                if vc.gkHasTabBar && bottomView != nil {
                    return -vc.gkTabBarHeight
                }
            }
            
            return 0
        }
    }

    ///左边约束 如果包含safeLayoutGuide.left，就是 safeAreaLeft，否则就是self.mas_leading
    var leftItem: ConstraintItem {
        get{
            if safeLayoutGuide.contains(.left) && viewController != nil {
                return viewController!.gkSafeAreaLayoutGuideLeft
            }else{
                return snp.leading
            }
        }
    }

    ///右边约束 如果包含safeLayoutGuide.right，就是 safeAreaRight，否则就是self.mas_trail
    var rightItem: ConstraintItem {
        get{
            if safeLayoutGuide.contains(.right) && viewController != nil {
                return viewController!.gkSafeAreaLayoutGuideRight
            }else{
                return snp.trailing
            }
        }
    }
}

///空视图 loading
public extension BaseContainer {
    
    override func layoutEmtpyView() {
        if gkShowEmptyView {
            if let emptyView = gkEmptyView, emptyView.superview == nil {
                if let delegate = viewController {
                    delegate.emptyViewWillAppear(emptyView)
                }
      
                addSubview(emptyView)
                emptyView.snp.makeConstraints { (make) in
                    make.leading.equalTo(leftItem)
                    make.trailing.equalTo(rightItem)
                    
                    if topView != nil && !overlayArea.contains(.emptyViewTop) {
                        make.top.equalTo(topView!.snp.bottom)
                    } else {
                        if viewController != nil && safeLayoutGuide.contains(.top) {
                            make.top.equalTo(viewController!.gkSafeAreaLayoutGuideTop)
                        } else {
                            make.top.equalTo(self)
                        }
                    }
                    
                    if bottomView != nil && !overlayArea.contains(.emptyViewBottom) {
                        make.bottom.equalTo(bottomView!.snp.top)
                    } else {
                        if viewController != nil && safeLayoutGuide.contains(.bottom) {
                            make.bottom.equalTo(viewController!.gkSafeAreaLayoutGuideBottom).offset(bottomOffset)
                        } else {
                            make.bottom.equalTo(self).offset(bottomOffset)
                        }
                    }
                }
            }
        }
    }
    
    override func layoutPageLoadingView() {
        gkPageLoadingView?.snp.makeConstraints({ (make) in
            let insets = gkPageLoadingViewInsets
            make.leading.equalTo(leftItem).offset(insets.left)
            make.trailing.equalTo(rightItem).offset(insets.right)
            
            if topView != nil && !overlayArea.contains(.pageLoadingTop) {
                make.top.equalTo(topView!.snp.bottom)
            } else {
                let hasNavigationBar = !(viewController?.navigationController?.isNavigationBarHidden ?? true)
                if viewController != nil && hasNavigationBar && safeLayoutGuide.contains(.top) {
                    make.top.equalTo(viewController!.gkSafeAreaLayoutGuideTop).offset(insets.top)
                } else {
                    make.top.equalTo(self).offset(insets.top)
                }
            }
            
            if bottomView != nil && !overlayArea.contains(.pageLoadingBottom) {
                make.bottom.equalTo(bottomView!.snp.top).offset(-insets.bottom)
            } else {
                make.bottom.equalTo(self).offset(bottomOffset).offset(bottomOffset - insets.bottom)
            }
        })
    }
}
