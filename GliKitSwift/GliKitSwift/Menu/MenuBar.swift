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
    public private(set) var collectionView: UICollectionView!
    
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
        self.gkWidth - self.contentInset.left - self.contentInset.right
    }

    //MARK: - 其他

    ///当前选中的菜单按钮下标
    private var _selectedIndex: Int = 0
    public var selectedIndex: Int{
        set{
            self.setSelectedIndex(newValue, animated: false)
        }
        get{
            _selectedIndex
        }
    }

    ///设置 selectedIndex 是否调用代理
    public var callDelegateWhenSetSelectedIndex = false

    ///计算完成回调 layoutSubviews 后
    public var measureCompletion: (() -> Void)?

    ///代理回调
    public weak var delegate: MenuBarDelegate?
    
    ///是否可以调用代理
    private var callDelegateEnable: Bool {
        isClickItem || callDelegateWhenSetSelectedIndex
    }

    ///按钮信息 设置此值会导致菜单重新加载数据
    public var items: [MenuBarItem]?
    
    ///是否是点击按钮
    private var isClickItem = false

    ///是否已经可以计算item
    private var measureEnable = false

    // MARK: - Init
    
    /**
    构造方法
    *@param frame 位置大小
    *@param items 按钮信息
    *@return 一个实例
    */
    public init(frame: CGRect = .zero, items: [MenuBarItem]?) {
        super.init(frame: frame)
        self.items = items
        initViews()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    ///初始化
    private func initViews(){
        
        backgroundColor = .white
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collectionView
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.scrollsToTop = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        didInitCollectionView(collectionView)
        addSubview(collectionView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.gkWidth > 0 && self.gkHeight > 0 && collectionView.bounds.size != self.bounds.size {
            collectionView.frame = self.bounds
            measureEnable = true
            
            reloadData()
            layoutIndicator()
        }
    }

    ///刷新数据
    private func reloadData(){
        
        if(measureEnable){
            measureItems()
            collectionView.reloadData()
        }
    }
    
    ///测量item
    private func measureItems(){
        
        if !measureEnable {
            return
        }

        let totalWidth = onMeasureItems()
        
        switch style {
        case .autoDetect :
            currentStyle = totalWidth > self.contentWidth ? .fit : .fill
            
            default :
            currentStyle = style
        }
        
        measureCompletion?()
    }
    
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
    open func onMeasureItems() -> CGFloat{
        fatalError("子类必须实现 onMeasureItems")
    }

    ///选中某个item
    open func onSelectItemAt(_ index: Int, oldIndex: Int){
        
    }

    // MARK: - 设置

    /**
     *设置选中的菜单按钮
     *@param selectedIndex 菜单按钮下标
     *@param animated 是否动画
     */
    open func setSelectedIndex(_ selectedIndex: Int, animated: Bool = false){
        
        if let items = self.items {
            if selectedIndex >= items.count {
                return
            }
            
            if _selectedIndex == selectedIndex {
                if callDelegateEnable {
                    delegate?.menuBar?(self, didSelectHighlightedItemAt: selectedIndex)
                }
                return;
            }
            
            let oldIndex = _selectedIndex
            _selectedIndex = selectedIndex
            
            onSelectItemAt(_selectedIndex, oldIndex: oldIndex)
            layoutIndicator(animated: animated)
            scrollToVisibleRect(animated: animated)

            if oldIndex < items.count && callDelegateEnable {
                delegate?.menuBar?(self, didDeselectItemAt: oldIndex)
            }
            
            if callDelegateEnable {
                delegate?.menuBar?(self, didSelectItemAt: _selectedIndex)
            }
        }
    }

    /**
     设置将要到某个item的偏移量比例

     @param percent 比例 0 ~ 1.0
     @param index 将要到的下标
     */
    open func setPercent(_ percent: CGFloat, for index: Int){
        
        if measureEnable && indicatorHeight > 0, let items = self.items {
            
            assert(index < items.count, "MenuBar setPercent: forIndex:，index \(index) 已越界")
            
            var percent = percent
            if percent > 1.0 {
                percent = 1.0
            }else if percent < 0 {
                percent = 0
            }
            
            var frame = indicator.frame
            
            let x = indicatorXForIndex(_selectedIndex)
            let offset = percent * (indicatorXForIndex(index) - x)
            
            let item1 = items[_selectedIndex]
            let item2 = items[index]
            
            frame.origin.x = x + offset
            frame.size.width = item1.itemWidth + (item2.itemWidth - item1.itemWidth) * percent
            
            indicator.frame = frame
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !measureEnable {
            return 0
        }
        return items?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return contentInset
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items![indexPath.item]
        return CGSize(width: item.itemWidth, height: collectionView.gkHeight - contentInset.top - contentInset.bottom)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return currentStyle == .fill ? 0 : itemInterval
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("\(self.gkNameOfClass) 必须重写 \(NSStringFromSelector(#function))")
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let enable = delegate?.menuBar?(self, shouldSelectItemAt: indexPath.item) ?? true
        if enable {
            isClickItem = true
            setSelectedIndex(indexPath.item, animated: true)
            isClickItem = false
        }
    }
    
    // MARK: - 分割线

    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        //绘制分割线
        if displayTopDivider || self.displayBottomDivider {
            
            if let context = UIGraphicsGetCurrentContext() {
                context.saveGState()
                
                context.setStrokeColor(UIColor.gkSeparatorColor.cgColor)
                context.setLineWidth(UIApplication.gkSeparatorHeight)
                
                let offset = UIApplication.gkSeparatorHeight / 2.0
                
                if displayTopDivider {
                    context.move(to: CGPoint(x: 0, y: offset))
                    context.addLine(to: CGPoint(x: rect.size.width, y: offset))
                }
                
                if displayBottomDivider {
                    context.move(to: CGPoint(x: 0, y: rect.size.height - offset))
                    context.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height - offset))
                }
                
                context.strokePath()
                context.restoreGState()
            }
        }
    }

    ///获取下划线x轴位置
    private func indicatorXForIndex(_ index: Int) -> CGFloat{
        
        var x: CGFloat = 0
        if let cell = itemForIndex(index), let item = items?[index] {
            
            if cell.frame != CGRect.zero {
                x = cell.gkLeft + (cell.gkWidth - item.itemWidth) / 2.0;
            } else {
                x = contentInset.left;
                var itemInterval: CGFloat = 0
                if currentStyle == .fit {
                    itemInterval = self.itemInterval
                }
                
                for i in 0 ..< index {
                    if let barItem = items?[i] {
                        x += barItem.itemWidth + itemInterval
                    }
                }
            }
        }
        
        return x
    }
    

    ///设置下划线的位置
    private func layoutIndicator(animated: Bool = false){
        
        if !measureEnable {
            return
        }
        
        if indicatorHeight > 0 {
            
            if let item = items?[selectedIndex] {
                var frame = indicator.frame
                
                frame.origin.x = indicatorXForIndex(selectedIndex)
                frame.size.height = indicatorHeight;
                frame.origin.y = self.gkHeight - indicatorHeight
                
                if currentStyle == .fill && indicatorShouldFill {
                    frame.size.width = item.itemWidth
                } else {
                    frame.size.width = item.contentSize.width + itemPadding
                }
                
                if animated {
                    UIView.animate(withDuration: 0.25) {
                        self.indicator.frame = frame
                    }
                } else {
                    indicator.frame = frame
                }
            }
        }
    }
    
    ///滚动到可见位置
    private func scrollToVisibleRect(animated: Bool = false){
        
        if selectedIndex >= items?.count ?? 0 || currentStyle != .fit || !measureEnable {
            return
        }
        
        collectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }

    ///通过下标获取按钮
    private func itemForIndex(_ index: Int) -> UICollectionViewCell? {
        
        if index >= items?.count ?? 0 || !measureEnable {
            return nil
        }
        
        let indexPath = IndexPath(item: index, section: 0)
        var cell = collectionView.cellForItem(at: indexPath)
        
        if cell == nil {
            cell = collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        return cell
    }
}
