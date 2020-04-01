//
//  MenuBar.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/1.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///默认高度
public let GKMenuBarHeight: CGFloat = 40.0

///菜单条样式
public enum MenuBarStyle{
    
    ///自动检测
    case autoDetect
    
    ///按钮的宽度和标题宽度对应，多余的可滑动
    case fit
    
    ///按钮的宽度根据按钮数量和菜单宽度等分，不可滑动
    case fill
};

///菜单条代理
@objc public protocol MenuBarDelegate: NSObjectProtocol{
    
    ///点击某个item
    @objc optional func menuBar(_ menuBar: MenuBar, didSelectItemAt index: Int)

    ///取消选择某个按钮
    @objc optional func menuBar(_ menuBar: MenuBar, didDeselectItemAt index: Int)

    ///点击高亮的按钮
    @objc optional func menuBar(_ menuBar: MenuBar, didSelectHighlightedItemAt index: Int)

    ///是否可以点击某个按钮 default is 'YES'
    @objc optional func menuBar(_ menuBar: MenuBar, shouldSelectItemAt index: Int) -> Bool
}

///菜单条基类 不要直接使用这个 继承，或者使用 TabMenuBar
open class MenuBar: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{

    ///按钮容器
    public private(set) lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.scrollsToTop = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.didInitCollectionView(collectionView)
        addSubview(collectionView)
        
        return collectionView
    }()
    
    ///内容间距
    public var contentInset = UIEdgeInsets.zero

    ///是否显示菜单顶部分割线
    public var displayTopDivider = false

    ///菜单底部分割线
    public var displayBottomDivider = false

    // MARK: - 下划线

    ///按钮选中下划线颜色
    public private(set) lazy var indicator: UIView = {
        let view = UIView()
        view.backgroundColor = self.indicatorColor;
        self.collectionView.addSubview(view)
        
        return view
    }()

    ///按钮选中下划线高度
    public var indicatorHeight: CGFloat = 2

    ///按钮选中下划线颜色
    public var indicatorColor = UIColor.gkThemeColor

    ///下划线是否填满 GKMenuBarStyle.fill 有效
    public var indicatorShouldFill = false

    //MARK: - 按钮样式

    ///样式 默认自动检测 要计算完成才能确定 layoutSubviews
    public var style = MenuBarStyle.autoDetect

    ///当前样式
    public private(set) var currentStyle = MenuBarStyle.autoDetect

    ///按钮间 只有 MenuBarStyle.fit 生效
    public var itemInterval: CGFloat = 5

    ///按钮宽度延伸 left + right
    public var itemPadding: CGFloat = 10

    ///内容宽度
    public var contentWidth: CGFloat{
        get{
            
        }
    }

    //MARK: - 其他

    ///当前选中的菜单按钮下标
    public var selectedIndex: Int = 0

    ///设置 selectedIndex 是否调用代理
    public var callDelegateWhenSetSelectedIndex = false

    ///计算完成回调 layoutSubviews 后
    public var measureCompletion: (() -> Void)?

    ///代理回调
    public weak var delegate: MenuBarDelegate?

    /**
     按钮信息 设置此值会导致菜单重新加载数据
     */
    @property(nonatomic, copy, nullable) NSArray<GKMenuBarItem*> *items;

    // MARK: - Init

    /**
     构造方法
     *@param items 按钮信息
     *@return 一个实例
     */
    - (instancetype)initWithItems:(nullable NSArray<GKMenuBarItem*> *) items;

    /**
     构造方法
     *@param frame 位置大小
     *@param items 按钮信息
     *@return 一个实例
     */
    - (instancetype)initWithFrame:(CGRect)frame items:(nullable NSArray<GKMenuBarItem*> *) items;

    // MARK: - 子类重写

    /**
     已经创建collectionView，将要addSubview
     */
        
    open func didInitCollectionView(_ collectionView: UICollectionView){
        
    }

    /**
     子类计算 item大小
     @return 返回总宽度
     */
    - (CGFloat)onMeasureItems;

    /**
     选中某个item
     */
    - (void)onSelectItemAtIndex:(NSUInteger) index oldIndex:(NSUInteger) oldIndex;

    // MARK: - 设置

    /**
     *设置选中的菜单按钮
     *@param selectedIndex 菜单按钮下标
     *@param flag 是否动画
     */
    - (void)setSelectedIndex:(NSUInteger) selectedIndex animated:(BOOL) flag;

    /**
     设置将要到某个item的偏移量比例

     @param percent 比例 0 ~ 1.0
     @param index 将要到的下标
     */
    - (void)setPercent:(float) percent forIndex:(NSUInteger) index;
}
