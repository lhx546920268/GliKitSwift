//
//  PopoverMenu.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///弹窗菜单按钮信息
open class PopoverMenuItem: NSObject{
    
    ///标题
    public var title: String?
    
    ///按钮图标
    public var icon: UIImage?
    
    public init(title: String?, icon: UIImage?) {
     
        super.init()
        self.title = title
        self.icon = icon
    }
}

///弹窗按钮cell
open class PopoverMenuCell: UITableViewCell{
    
    ///按钮
    public lazy var button: Button = {
        
        let btn = Button()
        btn.contentHorizontalAlignment = .left
        btn.adjustsImageWhenDisabled = false;
        btn.adjustsImageWhenHighlighted = false
        btn.isUserInteractionEnabled = false;
        btn.backgroundColor = .clear;
        self.contentView.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        return btn
    }()
    
    ///分割线
    public lazy var divider: Divider = {
        
        let divider = Divider(vertical: false)
        self.contentView.addSubview(divider)
        
        divider.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(0)
        }
        
        return divider
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .gray
        self.selectedBackgroundView = UIView()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


/**
 弹窗菜单代理
 */
@objc public protocol PopoverMenuDelegate: PopoverDelegate{
    
    ///选择某一个
    @objc optional func popoverMenu(_ popoverMenu: PopoverMenu, didSelectAt index: Int)
}

/**
 弹窗菜单 contentInsets 将设成 0
 */
open class PopoverMenu: Popover, UITableViewDataSource, UITableViewDelegate {
    
    ///字体颜色
    public var textColor: UIColor = .black
    
    ///字体
    public var font = UIFont.systemFont(ofSize: 13)
    
    ///选中背景颜色
    public var selectedBackgroundColor = UIColor(white: 0.95, alpha: 1.0)
    
    ///图标和按钮的间隔
    public var iconTitleInterval: CGFloat = 0
    
    ///菜单行高
    public var rowHeight: CGFloat = 30
    
    ///菜单宽度 会根据按钮标题宽度，按钮图标和 内容边距获取宽度
    public var menuWidth: CGFloat = 0
    
    /// cell 内容边距 只有left和right生效
    public var cellContentInsets = UIEdgeInsets(0, 15, 0, 15)
    
    ///分割线颜色
    public var separatorColor = UIColor.gkSeparatorColor
    
    ///cell 分割线间距 只有left和right生效
    public var separatorInsets = UIEdgeInsets.zero
    
    ///按钮信息
    public var menuItems: Array<PopoverMenuItem>?{
        didSet{
            if self.superview != nil {
                tableView.reloadData()
            }
        }
    }
    
    ///标题
    public var titles: Array<String>?{
        set{
            if let titles = newValue {
                var items = Array<PopoverMenuItem>()
                for title in titles {
                    items.append(PopoverMenuItem(title: title, icon: nil))
                }
                self.menuItems = items;
            } else {
                self.menuItems = nil
            }
        }
        get{
            if let items = self.menuItems {
                var titles = Array<String>()
                for item in items {
                    if let title = item.title {
                        titles.append(title)
                    } else {
                        titles.append("")
                    }
                }
                return titles
            } else {
                return nil
            }
        }
    }
    
    ///点击某个按钮回调
    public var selectItemCallback: ((Int) -> Void)?
    
    ///菜单代理
    private var menuDelegate: PopoverMenuDelegate?{
        self.delegate as? PopoverMenuDelegate
    }
    
    ///按钮列表
    private lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = self.rowHeight
        tableView.separatorColor = self.separatorColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.registerClass(PopoverMenuCell.self)
        
        return tableView
    }()
    
    open override func initContentView() {
        
        contentView = tableView
        if let items = menuItems {
            tableView.frame = CGRect(0, 0, getMenuWidth(), CGFloat(items.count) * rowHeight)
        }
    }
    
    ///刷新数据
    private func reloadData(){
        
        if window != nil, let items = menuItems {
            tableView.frame = CGRect(0, 0, getMenuWidth(), CGFloat(items.count) * rowHeight)
            tableView.reloadData()
            redraw()
        }
    }
    
    ///通过标题获取菜单宽度
    private func getMenuWidth() -> CGFloat {
        
        if menuWidth == 0 {
            var contentWidth: CGFloat = 0
            if let items = menuItems {
                for item in items {
                    if let title = item.title {
                        let size = title.gkStringSize(font: font, with: UIScreen.gkWidth)
                        contentWidth = max(contentWidth, size.width + (item.icon?.size.width ?? 0) + iconTitleInterval)
                    }
                }
            }
            return contentWidth + cellContentInsets.width
        } else {
            return menuWidth
        }
    }
    
    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PopoverMenuCell.gkNameOfClass, for: indexPath) as! PopoverMenuCell
        
        cell.selectedBackgroundView?.backgroundColor = selectedBackgroundColor
        cell.button.titleLabel?.font = font
        cell.button.setTitleColor(textColor, for: .normal)
        cell.button.tintColor = textColor
        cell.button.gkLeftLayoutConstraint?.constant = cellContentInsets.left
        cell.button.gkRightLayoutConstraint?.constant = cellContentInsets.right
        
        let item = menuItems![indexPath.row]
        cell.button.setTitle(item.title, for: .normal)
        cell.button.setImage(item.icon, for: .normal)
        
        cell.divider.isHidden = indexPath.row == menuItems!.count - 1
        cell.divider.backgroundColor = separatorColor
        cell.divider.gkLeftLayoutConstraint?.constant = separatorInsets.left
        cell.divider.gkRightLayoutConstraint?.constant = separatorInsets.right
        
        cell.button.imagePadding = iconTitleInterval
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        menuDelegate?.popoverMenu?(self, didSelectAt: indexPath.row)
        
        selectItemCallback?(indexPath.row)
        dismiss(animated: true)
    }
}
