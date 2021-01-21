//
//  TabBarController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/2.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///tabBar控制器协议
public protocol TabBarControllerProtocol: AnyObject {
    
    ///当前显示的 viewController
    var selectedViewController: UIViewController? {
        get
    }
}

extension UITabBarController: TabBarControllerProtocol {
    
}

///选项卡按钮信息
public struct TabBarItemInfo {
    
    ///按钮标题
    public let title: String?
    
    ///按钮未选中图标 当selectedImage 为nil时，使用 UIImageRenderingModeAlwaysTemplate
    public let normalImage: UIImage?
    
    ///按钮选中图标
    public let selectedImage: UIImage?
    
    ///关联的
    public let viewController: UIViewController?
    
    init(title: String? = nil,
         normalImage: UIImage? = nil,
         selectedImage: UIImage? = nil,
         viewController: UIViewController? = nil) {
        self.title = title
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        self.viewController = viewController
    }
}


///选项卡控制器代理
@objc public protocol TabBarControllerDelegate: NSObjectProtocol {
    
    ///是否可以选择某个按钮
    @objc optional func tabBarController(_ tabBarController: TabBarController, shouldSelectAt index: Int) -> Bool
    
    ///选中某个
    @objc optional func tabBarController(_ tabBarController: TabBarController, didSelectAt index: Int)
    
}

///选项卡控制器
open class TabBarController: BaseViewController, TabBarControllerProtocol, TabBarDelegate {
    
    ///选中的
    public var selectedViewController: UIViewController? {
        get{
            if let infos = itemInfos, selectedItemIndex < infos.count {
                return infos[selectedItemIndex].viewController
            }
            
            return nil
        }
    }
    
    ///正常颜色
    public var normalColor: UIColor = UIColor.gkColorFromHex("95959a") {
        didSet{
            if oldValue != normalColor {
                if let items = self.items {
                    for i in 0 ..< items.count {
                        if i != tabBar.selectedIndex {
                            let item = items[i]
                            item.imageView.tintColor = normalColor
                            item.textLabel.textColor = normalColor
                        }
                    }
                }
            }
        }
    }
    
    ///选中颜色
    public var selectedColor: UIColor = UIColor.gkThemeColor {
        didSet{
            if oldValue != selectedColor {
                if let items = self.items {
                    if tabBar.selectedIndex < items.count {
                        let item = items[tabBar.selectedIndex]
                        item.imageView.tintColor = selectedColor
                        item.textLabel.textColor = selectedColor
                    }
                }
            }
        }
    }
    
    ///字体
    public var font: UIFont = .systemFont(ofSize: 12) {
        didSet{
            if oldValue != font {
                if let items = self.items {
                    for item in items {
                        item.textLabel.font = font
                    }
                }
            }
        }
    }
    
    ///选中的下标
    public var selectedIndex: Int {
        set{
            if _selectedIndex != newValue {
                _selectedIndex = selectedIndex
                tabBar.selectedIndex = newValue
                _selectedIndex = tabBar.selectedIndex
            }
        }
        get{
            _selectedIndex
        }
    }
    private var _selectedIndex: Int = NSNotFound
    
    ///选项卡按钮
    public private(set) var items: [TabBarItem]?
    
    ///选项卡按钮信息
    public var itemInfos: [TabBarItemInfo]? {
        didSet {
            
        }
    }
    
    ///选项卡
    public private(set) lazy var tabBar: TabBar = {
        let tabBar = TabBar(items: items)
        tabBar.delegate = self
        tabBar.snp.makeConstraints { (make) in
            make.height.equalTo(gkTabBarHeight)
        }
        
        return tabBar
    }()
    
    ///代理
    public weak var delegate: TabBarControllerDelegate?
    
    ///标签栏隐藏状态
    private var tabBarHidden: Bool = false
    
    // MARK: - public method
    
    /**
     设置选项卡边缘值
     *@param badgeValue 边缘值 @"" 为红点，要隐藏使用 nil
     *@param index 下标
     */
    public func setBadgeValue(_ badgeValue: String?, for index: Int) {
        tabBar.setBadgeValue(badgeValue, for: index)
    }
    
    ///获取指定的viewController
    public func viewController(for index: Int) -> UIViewController? {
        if let infos = self.itemInfos, index < infos.count {
            return infos[index].viewController
        }
        
        return nil
    }
    
    ///获取指定的item
    public func item(for index: Int) -> TabBarItem? {
        return items?[index]
    }
    
    ///设置tabBar 隐藏状态
    public func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        if tabBarHidden == hidden {
            return
        }
        
        tabBarHidden = hidden
        if animated {
            tabBar.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.tabBar.transform = hidden ? CGAffineTransform(translationX: 0, y: self.tabBar.gkHeight) : .identity
            } completion: { (_) in
                self.tabBar.isHidden = hidden
            }
        } else {
            self.tabBar.isHidden = hidden
        }
    }
    
    // MARK: - view
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        container?.safeLayoutGuide = .none
        view.backgroundColor = .white
        if itemInfos?.count ?? 0 > 0 {
            selectedIndex = 0
        }
    }
    
    private func initItems() {
        if let infos = self.itemInfos {
            //创建选项卡按钮
            var items: [TabBarItem] = []
            for info in infos {
                let item = TabBarItem()
                item.textLabel.textColor = normalColor
                item.textLabel.font = font
                item.textLabel.text = info.title
                item.imageView.image = info.normalImage
                
                items.append(item)
                info.viewController?.gkHasTabBar = true
            }
            
            tabBar.items = items
            
            if self.isViewLoaded {
                selectedIndex = 0
            }
        }
    }
    
    // MARK: - TabBarDelegate
    
    public func tabBar(_ tabBar: TabBar, didSelectItemAt index: Int) {
        selectedItemIndex = index
    }
    
    public func tabBar(_ tabBar: TabBar, shouldSelectItemAt index: Int) -> Bool {
        if let infos = itemInfos {
            let info = infos[index]
            let should: Bool = info.viewController != nil
            return delegate?.tabBarController?(self, shouldSelectAt: index) ?? should
        }
        
        return false
    }
    
    // MARK: - private method
    
    //设置item 选中
    private func setSelected(_ selected: Bool, for index: Int) {
        if let items = self.items, index < items.count, let infos = self.itemInfos {
            let item = items[index]
            let info = infos[index]
            
            if selected {
                item.imageView.tintColor = selectedColor
                item.textLabel.textColor = selectedColor
                
                if info.selectedImage != nil {
                    item.imageView.image = info.selectedImage
                }
            } else {
                item.imageView.tintColor = normalColor
                item.textLabel.textColor = normalColor
                item.imageView.image = info.normalImage
            }
        }
    }
    
    //设置选中的
    private var selectedItemIndex: Int = NSNotFound {
        didSet {
            if oldValue != selectedItemIndex {
                //以前的viewController
                let oldViewController = viewController(for: oldValue)
                setSelected(false, for: oldValue)
                setSelected(true, for: selectedItemIndex)
                
                if var viewController = selectedViewController {
                    //移除以前的viewController
                    oldViewController?.view.removeFromSuperview()
                    oldViewController?.removeFromParent()
                    
                    if viewController.view.superview == nil {
                        addChild(viewController)
                        contentView = viewController.view
                        
                        tabBar.removeFromSuperview()
                        if let nav = viewController as? UINavigationController {
                            viewController = nav.viewControllers.first!
                        }
                        
                        viewController.view.addSubview(tabBar)
                        tabBar.snp.makeConstraints { (make) in
                            make.leading.trailing.bottom.equalTo(0)
                        }
                    }
                }
                _selectedIndex = selectedItemIndex
                delegate?.tabBarController?(self, didSelectAt: _selectedIndex)
            }
        }
    }
}
